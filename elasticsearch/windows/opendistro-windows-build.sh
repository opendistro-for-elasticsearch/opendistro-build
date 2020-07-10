#!/bin/bash
set -e

REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
ES_VERSION=`$REPO_ROOT/bin/version-info --es`; echo $ES_VERSION
OD_VERSION=`$REPO_ROOT/bin/version-info --od`; echo $OD_VERSION
S3_BUCKET="artifacts.opendistroforelasticsearch.amazon.com"
ARTIFACTS_URL="https://d3g5vo6xdbdb9a.cloudfront.net"
PACKAGE_NAME="opendistroforelasticsearch"
TARGET_DIR="$ROOT/target"

# Please DO NOT change the orders, they have dependencies
PLUGINS=`$REPO_ROOT/bin/plugins-info windows`

basedir="${ROOT}/elasticsearch-${ES_VERSION}/plugins"
#PLUGINS_CHECKS=`$REPO_ROOT/bin/plugins-info zip | awk -F '/' '{print $2}' | sed "s@^@$basedir\/@g"`

mkdir -p $TARGET_DIR
mkdir -p $PACKAGE_NAME-$OD_VERSION

# Download windowss oss for copying batch files
wget -nv https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip ; echo $?

# Unzip the oss
unzip -q elasticsearch-oss-$ES_VERSION-windows-x86_64.zip
rm -rf elasticsearch-oss-$ES_VERSION-windows-x86_64.zip

# Install plugins
for plugin_path in $PLUGINS
do
  plugin_latest=`aws s3api list-objects --bucket $S3_BUCKET --prefix "downloads/elasticsearch-plugins/${plugin_path}-${OD_VERSION}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
  echo "installing $plugin_latest"
  $ROOT/elasticsearch-$ES_VERSION/bin/elasticsearch-plugin install --batch "${ARTIFACTS_URL}/${plugin_latest}"; \
done

# List Plugins
echo "List available plugins"
ls -lrt $basedir

bash $ROOT/elasticsearch-$ES_VERSION/plugins/opendistro_security/tools/install_demo_configuration.sh -y -i -s
cat $ROOT/elasticsearch-$ES_VERSION/config/elasticsearch.yml
cp -r elasticsearch-$ES_VERSION/* $PACKAGE_NAME-$OD_VERSION/

# Making zip
echo "Generating zip"
zip -q -r $TARGET_DIR/odfe-$OD_VERSION.zip $PACKAGE_NAME-$OD_VERSION
ls -ltr

# Build Exe
wget -nv https://download-gcdn.ej-technologies.com/install4j/install4j_unix_8_0_4.tar.gz
tar -xzf install4j_unix_8_0_4.tar.gz
aws s3 cp s3://odfe-windows/ODFE.install4j .
echo $?

# Build the exe
install4j8.0.4/bin/install4jc -d $TARGET_DIR -D sourcedir=./$PACKAGE_NAME-$OD_VERSION,version=$OD_VERSION --license="L-M8-AMAZON_DEVELOPMENT_CENTER_INDIA_PVT_LTD#50047687020001-3rhvir3mkx479#484b6" ./ODFE.install4j

ls -ltr $TARGET_DIR

# Upload top S3
aws s3 cp $TARGET_DIR/*.exe s3://$S3_BUCKET/downloads/odfe-windows/staging/odfe-executable/
aws s3 cp $TARGET_DIR/*.zip s3://$S3_BUCKET/downloads/odfe-windows/staging/odfe-window-zip/
aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/downloads/*"
