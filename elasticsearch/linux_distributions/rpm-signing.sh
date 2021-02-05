#!/bin/bash

set -e

REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
MANIFEST_FILE=$REPO_ROOT/release-tools/scripts/manifest.yml
ES_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --es`; echo ES_VERSION: $ES_VERSION
OD_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --od`; echo OD_VERSION: $OD_VERSION
S3_PROD_BASEURL=`yq eval '.urls.ODFE.prod' $MANIFEST_FILE`
S3_PROD_BUCKET=`echo $S3_PROD_BASEURL | awk -F '/' '{print $3}'`
S3_RELEASE_BASEURL=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE`
S3_RELEASE_BUCKET=`echo $S3_RELEASE_BASEURL | awk -F '/' '{print $3}'`
S3_RELEASE_FINAL_BUILD=`yq eval '.urls.ODFE.releases_final_build' $MANIFEST_FILE | sed 's/\///g'`
PLUGIN_PATH=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE | sed "s/^.*$S3_RELEASE_BUCKET\///g"`
PASSPHRASE=$1; if [ -z "$PASSPHRASE" ]; then echo "Please enter passphrase as a parameter"; exit 1; fi
ACTION=$2; if [ ! -z "$ACTION" ]; then echo "About to sync staging to prod repo! Wait for 30 seconds"; sleep 30; fi

REPO_BASEDIR="$ROOT/artifacts-repo"
REPO_YUMDIR="$REPO_BASEDIR/yum"
REPO_RPMSDIR="$REPO_BASEDIR/rpms"

if [ "$ACTION" = "prod-sync" ]
then
  aws s3 sync ${S3_PROD_BASEURL}staging/yum/ ${S3_PROD_BASEURL}yum/ --quiet; echo $?
  aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/yum/*"
  exit 0
fi


if [ -z "$S3_RELEASE_FINAL_BUILD" ]
then
  S3_RELEASE_BUILD=`aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}" --query 'Contents[].[Key]' --output text | awk -F '/' '{print $3}' | uniq | tail -n 1`
  echo Latest: $S3_RELEASE_BUILD
else
  S3_RELEASE_BUILD=$S3_RELEASE_FINAL_BUILD
  echo Final: $S3_RELEASE_BUILD
fi

# Check storage
df -h

# Copy pgp keys
aws s3 cp s3://opendistro-docs/github-actions/pgp-private-key . --quiet
aws s3 cp s3://opendistro-docs/github-actions/pgp-public-key . --quiet

# Import pgp keys
# Our keys only work with gpg1 not gpg2+
echo "import pgp keys"
gpg --version
gpg --quiet --import pgp-public-key
gpg --quiet --allow-secret-key-import --import pgp-private-key

echo HOME $HOME
#ls -l ~/.gnupg/

echo "rpm import keys"
rpm --quiet --import pgp-public-key
rpm --quiet -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'

echo "%_signature gpg" >> ~/.rpmmacros
echo "%_gpg_path ~/.gnupg" >> ~/.rpmmacros
echo "%_gpg_name OpenDistroForElasticsearch" >> ~/.rpmmacros
echo "%_gpg /usr/bin/gpg" >> ~/.rpmmacros

# Setup a directory structure on your local machine that mimics the one in S3.
mkdir -p $REPO_YUMDIR/
mkdir -p $REPO_RPMSDIR/

# Sync the remote yum repo to your local directory. *Before you do this, ensure you export the correct set of AWS credentials.*
echo "Sync yum"
aws s3 sync ${S3_PROD_BASEURL}staging/yum/ $REPO_YUMDIR/ --quiet; echo $?
echo "Sync rpms"
aws s3 sync ${S3_RELEASE_BASEURL}${OD_VERSION}/${S3_RELEASE_BUILD}/elasticsearch-plugins/ $REPO_RPMSDIR/ --exclude "*" --include "*.rpm"  --quiet; echo $?
aws s3 sync ${S3_RELEASE_BASEURL}${OD_VERSION}/${S3_RELEASE_BUILD}/opendistro-libs/ $REPO_RPMSDIR/ --exclude "*" --include "*.rpm"  --quiet; echo $?
aws s3 sync ${S3_RELEASE_BASEURL}${OD_VERSION}/odfe/ $REPO_RPMSDIR/ --exclude "*" --include "*.rpm"  --quiet; echo $?


# Rename rpms to remove build numbers
for pkg in `ls $REPO_RPMSDIR | grep -i build`
do
  mv $REPO_RPMSDIR/$pkg $REPO_RPMSDIR/`echo $pkg | sed 's/-build-[0-9]*//g'`
done

echo $REPO_YUMDIR/; ls -l $REPO_YUMDIR/
echo $REPO_RPMSDIR/; ls -l $REPO_RPMSDIR/
df -h

# Add signatures to the new RPMs and copy them over to the Repo.
sudo yum install -y expect rpm-sign
echo "Adding sign to the rpms in $REPO_RPMSDIR with the PASSPHRASE"

for rpm_package in `ls $REPO_RPMSDIR/`
do
  echo "Signing $rpm_package"
  ./rpm-addsign.exp $REPO_RPMSDIR/$rpm_package $PASSPHRASE
  echo "Signing complete #################################"
done

# Verify the signing
echo "Verifying the signing"
find $REPO_RPMSDIR -name *.rpm | xargs -n1 rpm --checksig
find $REPO_RPMSDIR -name *.rpm | xargs -n1 -I{} cp {} $REPO_YUMDIR/noarch

# Create repo and sync back to the S3
# createrepo 0.10.0+ has removed support of --deltas
# See their changelog and this ticket for more information
# https://bugzilla.redhat.com/show_bug.cgi?id=1538650
# Many repos will force a higher version during installation despite specifying 0.9.9 due to
# Package createrepo is obsoleted by createrepo_c, trying to install createrepo_c-0.12.2-2...... instead
# sudo yum list createrepo --showduplicates
# sudo yum install -y createrepo-0.9.9* # This doesnt work as 0.12.0 will still install as of 20200121
echo "Install createrepo packages"
aws s3 sync ${S3_PROD_BASEURL}downloads/utils/ ./ --exclude "*" --include "createrepo*" --quiet; echo $?
ls -l | grep createrepo
sudo yum install -y `ls | grep -i createrepo`

echo "createrepo update now"
createrepo -v --update --deltas $REPO_YUMDIR/noarch --max-delta-rpm-size=1000000000
gpg --detach-sign --armor --batch --yes  --passphrase $PASSPHRASE $REPO_YUMDIR/noarch/repodata/repomd.xml

echo "Sync rpms back to the repo"
aws s3 sync $REPO_YUMDIR/ ${S3_PROD_BASEURL}staging/yum/ --quiet; echo $?
aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/staging/yum/*"


