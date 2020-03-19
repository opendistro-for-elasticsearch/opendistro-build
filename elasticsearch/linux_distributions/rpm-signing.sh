/github/home/bin/aws s3 cp s3://opendistro-docs/github-actions/pgp-private-key .
/github/home/bin/aws s3 cp s3://opendistro-docs/github-actions/pgp-public-key .
          
gpg --import pgp-public-key
gpg --allow-secret-key-import --import pgp-private-key
          
ls -ltr /github/home/.gnupg/
          
rpm --import pgp-public-key
          
rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'
          
echo "%_signature gpg" >> /github/home/.rpmmacros
echo "%_gpg_path /github/home/.gnupg" >> /github/home/.rpmmacros
echo "%_gpg_name OpenDistroForElasticsearch" >> /github/home/.rpmmacros
echo "%_gpg /usr/bin/gpg" >> /github/home/.rpmmacros

#Setup a directory structure on your local machine that mimics the one in S3.
mkdir artifacts-repo
cd artifacts-repo
mkdir yum
mkdir -p downloads/rpms
#Sync the remote yum repo to your local directory. *Before you do this, ensure you export the correct set of AWS credentials.*
/github/home/bin/aws s3 sync s3://artifacts.opendistroforelasticsearch.amazon.com/yum/ yum/
rm -rf yum/staging
/github/home/bin/aws s3 sync s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/rpms/ downloads/rpms/
#Add signatures to the new RPMs and copy them over to the Repo.
yum install -y expect
yum install -y rpm-sign
chmod +x elasticsearch/linux_distributions/scripts/rpm-addsign.exp
echo "Adding sign to the rpms with the passphrase $passphrase"
for VARIABLE in downloads/rpms/*/*.rpm
do
        ../elasticsearch/linux_distributions/scripts/rpm-addsign.exp $VARIABLE $passphrase
done
echo "Verifying the signing"
find downloads -name *.rpm | xargs -n1 rpm --checksig
find downloads -name *.rpm | xargs -n1 -I{} cp {} yum/noarch
yum install -y createrepo
createrepo -v --update --deltas yum/noarch --max-delta-rpm-size=1000000000
gpg --detach-sign --armor --batch --yes  --passphrase $passphrase yum/noarch/repodata/repomd.xml
/github/home/bin/aws s3 sync yum/ s3://artifacts.opendistroforelasticsearch.amazon.com/yum/staging
/github/home/bin/aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/yum/staging/*"
