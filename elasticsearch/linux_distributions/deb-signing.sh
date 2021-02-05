#!/bin/bash

set -e

OLDIFS=$IFS
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

REPO_DOWNLOADSDIR="$ROOT/downloads"
REPO_DEBSDIR="$ROOT/debs"

if [ "$ACTION" = "prod-sync" ]
then
  aws s3 sync ${S3_PROD_BASEURL}staging/apt/ ${S3_PROD_BASEURL}apt/ --quiet; echo $?
  aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/apt/*"
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

# Our keys only work with gpg1 not gpg2+
echo "deb http://repo.aptly.info/ squeeze main" | sudo tee -a /etc/apt/sources.list.d/aptly.list
sudo apt-get install -y gnupg1
sudo apt install -y gpgv1

# Install necessary utilities
wget -qO - https://www.aptly.info/pubkey.txt | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install -y aptly

# Copy pgp keys
aws s3 cp s3://opendistro-docs/github-actions/pgp-private-key . --quiet
aws s3 cp s3://opendistro-docs/github-actions/pgp-public-key . --quiet

# Remove existing gpg2
# Do not move this block it has to be right before GPG Import
echo "Remove gpg2"
sudo mv `which gpg` /usr/bin/gpg2 || echo No gpg2 exist
ln -s /usr/bin/gpg1 /usr/bin/gpg

# Import pgp keys
echo "import pgp keys"
gpg --version
gpg --quiet --import pgp-public-key
gpg --quiet --allow-secret-key-import --import pgp-private-key

# Create local repo
aptly repo create -distribution=stable -component=main odfe-release
mkdir -p $REPO_DOWNLOADSDIR/debs
mkdir -p $REPO_DEBSDIR

# Sync artifacts
echo "Sync apt"
aws s3 sync ${S3_PROD_BASEURL}downloads/debs $REPO_DOWNLOADSDIR/debs --quiet; echo $?
echo "Sync debs"
aws s3 sync ${S3_RELEASE_BASEURL}${OD_VERSION}/${S3_RELEASE_BUILD}/elasticsearch-plugins/ $REPO_DEBSDIR/ --exclude "*" --include "*.deb"  --quiet; echo $?
aws s3 sync ${S3_RELEASE_BASEURL}${OD_VERSION}/${S3_RELEASE_BUILD}/opendistro-libs/ $REPO_DEBSDIR/ --exclude "*" --include "*.deb"  --quiet; echo $?
aws s3 sync ${S3_RELEASE_BASEURL}${OD_VERSION}/odfe/ $REPO_DEBSDIR/ --exclude "*" --include "*.deb"  --quiet; echo $?

# Rename debs to remove build numbers
for pkg in `ls $REPO_DEBSDIR | grep -i build`
do
  mv -v $REPO_DEBSDIR/$pkg $REPO_DEBSDIR/`echo $pkg | sed 's/-build-[0-9]*//g'`
done

# List artifacts
echo $REPO_DOWNLOADSDIR/; ls -l $REPO_DOWNLOADSDIR/*
echo $REPO_DEBSDIR/; ls -l $REPO_DEBSDIR
df -h

# Move newly added debs to the corresponding repo folders
for plugin_dir in `ls $REPO_DOWNLOADSDIR/debs`
do
  echo plugin_dir $plugin_dir
  pkg=`(ls $REPO_DEBSDIR | grep -E "$plugin_dir-[.0-9]+") || echo None`
  pkg_num=`echo $pkg | wc -w`
  if [ "$pkg" != "None" ]
  then
    echo "####################################"
    if [ "$pkg_num" -gt 1 ]
    then
      IFS=$OLDIFS
      for pkg_temp in `echo $pkg`
      do
        echo movemul $pkg_temp
        mv -v $REPO_DEBSDIR/$pkg_temp $REPO_DOWNLOADSDIR/debs/$plugin_dir/
      done
    else
      echo move $pkg
      mv -v $REPO_DEBSDIR/$pkg $REPO_DOWNLOADSDIR/debs/$plugin_dir/
    fi
  fi
done

# Check if all the debs are moved to the local repo folders
# If new, create folder then move
echo $REPO_DEBSDIR/; ls -l $REPO_DEBSDIR; debs_count=`ls $REPO_DEBSDIR | wc -l`
if [ "$debs_count" -ne 0 ]
then
  for pkg_new in `ls $REPO_DEBSDIR`
  do
    plugin_dir_new=`echo $pkg_new | sed 's/-[.0-9]*.deb//g'`
    mkdir -p $REPO_DOWNLOADSDIR/debs/$plugin_dir_new
    echo "####################################"
    echo move new $pkg_new
    mv -v $REPO_DEBSDIR/$pkg_new $REPO_DOWNLOADSDIR/debs/$plugin_dir_new/
  done
fi
echo $REPO_DOWNLOADSDIR/; ls -l $REPO_DOWNLOADSDIR/*
echo $REPO_DEBSDIR/; ls -l $REPO_DEBSDIR

# Add debs to local repo and create snapshot
# Note: aptly will pull all the debs from your folders
# And recreate folder structure based on file basename in metadata
echo "Create local repo and snapshot for debs"
aptly repo add odfe-release $REPO_DOWNLOADSDIR
aptly repo show -with-packages odfe-release
aptly snapshot create opendistroforelasticsearch from repo odfe-release
aptly snapshot list

# Publish snapshot
echo "Publish snapshot"
aptly publish snapshot -batch=true -passphrase=$passphrase opendistroforelasticsearch

echo HOME $HOME
#ls -l ~/.gnupg/
ls -l ~/.aptly/public/pool/
ls -l ~/.aptly/public/pool/*/*

echo "Sync debs back to the repo"
#aws s3 sync $REPO_DOWNLOADSDIR/debs ${S3_PROD_BASEURL}downloads/debs  --quiet; echo $?
aws s3 sync ~/.aptly/public/ ${S3_PROD_BASEURL}staging/apt/ --quiet; echo $?
aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/downloads/debs/*"
aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/staging/apt/*"


