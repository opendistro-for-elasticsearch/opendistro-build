#!/bin/bash
set -e

REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
ES_VERSION=`$REPO_ROOT/bin/version-info --es`; echo $ES_VERSION
OD_VERSION=`$REPO_ROOT/bin/version-info --od`; echo $OD_VERSION
S3_BUCKET="artifacts.opendistroforelasticsearch.amazon.com"
ARTIFACTS_URL="https://d3g5vo6xdbdb9a.cloudfront.net"
PACKAGE_NAME="opendistroforelasticsearch-kibana"
TARGET_DIR="$ROOT/target"

mkdir $TARGET_DIR

# Downloading tar from s3
aws s3 cp "s3://${S3_BUCKET}/downloads/tarball/${PACKAGE_NAME}/${PACKAGE_NAME}-${OD_VERSION}.tar.gz" . --quiet ; echo $0

# Untar the tar artifact
tar -xzf $PACKAGE_NAME-$OD_VERSION.tar.gz
rm -rf $PACKAGE_NAME-$OD_VERSION.tar.gz

# Download windowss oss for copying batch files
wget -nv https://artifacts.elastic.co/downloads/kibana/kibana-oss-$ES_VERSION-windows-x86_64.zip

# Unzip the oss
unzip -q kibana-oss-$ES_VERSION-windows-x86_64.zip
rm -rf kibana-oss-$ES_VERSION-windows-x86_64.zip

# Copy all the bat files in the bin directory and node.exe
BAT_FILES=`ls kibana-$ES_VERSION-windows-x86_64/bin/*.bat`
cp -v $BAT_FILES $PACKAGE_NAME/bin
cp -v kibana-$ES_VERSION-windows-x86_64/node/node.exe $PACKAGE_NAME/node
rm -rf kibana-oss-$ES_VERSION-windows-x86_64

# Making zip
zip -q -r $TARGET_DIR/odfe-$OD_VERSION-kibana.zip $PACKAGE_NAME
ls -ltr

# Download install4j software
wget -nv https://download-gcdn.ej-technologies.com/install4j/install4j_unix_8_0_4.tar.gz

# Untar
tar -xzf install4j_unix_8_0_4.tar.gz
rm -rf install4j_unix_8_0_4.tar.gz

# Download the .install4j file from s3
aws s3 cp s3://odfe-windows/ODFE-Kibana.install4j . --quiet ; echo $0

 #Build the exe
install4j8.0.4/bin/install4jc -d $TARGET_DIR -D sourcedir=./$PACKAGE_NAME,version=$OD_VERSION --license="L-M8-AMAZON_DEVELOPMENT_CENTER_INDIA_PVT_LTD#50047687020001-3rhvir3mkx479#484b6" ./ODFE-Kibana.install4j
ls -ltr $TARGET_DIR

# Copy to s3
aws s3 cp $TARGET_DIR/*.exe s3://$S3_BUCKET/downloads/odfe-windows/staging/odfe-executable/
aws s3 cp $TARGET_DIR/*.zip s3://$S3_BUCKET/downloads/odfe-windows/staging/odfe-window-zip/
aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/downloads/*"
