#!/bin/bash

# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
#Download opensourceversion

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
PLUGINS=`$REPO_ROOT/bin/plugins-info zip`

basedir="${ROOT}/${PACKAGE_NAME}-${OD_VERSION}/plugins"
#PLUGINS_CHECKS=`$REPO_ROOT/bin/plugins-info zip | awk -F '/' '{print $2}' | sed "s@^@$basedir\/@g"`

echo $ROOT

if [ -z "$PLUGINS" ]; then
  echo "Provide plugin list to install (separated by space)"
  exit 1
fi

# Prepare target directories
mkdir ${PACKAGE_NAME}-${OD_VERSION}
mkdir $TARGET_DIR

# Downloading ES oss
echo "Downloading ES oss"
wget -nv https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-linux-x86_64.tar.gz ; echo $?
tar -xzf elasticsearch-oss-$ES_VERSION-linux-x86_64.tar.gz --strip-components=1 --directory "${PACKAGE_NAME}-${OD_VERSION}" && rm -rf elasticsearch-oss-$ES_VERSION-linux-x86_64.tar.gz
cp -v opendistro-tar-install.sh $PACKAGE_NAME-$OD_VERSION

# Install Plugin
for plugin_path in $PLUGINS
do
  plugin_latest=`aws s3api list-objects --bucket $S3_BUCKET --prefix "downloads/elasticsearch-plugins/${plugin_path}-${OD_VERSION}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
  echo "installing $plugin_latest"
  $PACKAGE_NAME-$OD_VERSION/bin/elasticsearch-plugin install --batch "${ARTIFACTS_URL}/${plugin_latest}"; \
done

# List Plugins
echo "List available plugins"
ls -lrt $basedir

# Move performance-analyzer-rca folder
cp -r $PACKAGE_NAME-$OD_VERSION/plugins/opendistro_performance_analyzer/performance-analyzer-rca $PACKAGE_NAME-$OD_VERSION
chmod -R 755 ${PACKAGE_NAME}-${OD_VERSION}/performance-analyzer-rca
# Move agent script directly into ES_HOME/bin
mv $PACKAGE_NAME-$OD_VERSION/bin/opendistro_performance_analyzer/performance-analyzer-agent-cli $PACKAGE_NAME-$OD_VERSION/bin
rm -rf $PACKAGE_NAME-$OD_VERSION/bin/opendistro_performance_analyzer
# Make sure the data folder exists and is writable
mkdir -p ${PACKAGE_NAME}-${OD_VERSION}/data
chmod 755 ${PACKAGE_NAME}-${OD_VERSION}/data/

# Download Knn lib
knnlib_latest=`aws s3api list-objects --bucket $S3_BUCKET --prefix "downloads/opendistro-libs/opendistro-knnlib/opendistro-knnlib-$OD_VERSION" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
echo "downloading $knnlib_latest"
aws s3 cp "s3://artifacts.opendistroforelasticsearch.amazon.com/${knnlib_latest}" ./
unzip opendistro-knnlib*.zip
mkdir -p $PACKAGE_NAME-$OD_VERSION/plugins/opendistro-knn/knn-lib/ 
mv -v opendistro-knnlib*/libKNNIndex*.so $PACKAGE_NAME-$OD_VERSION/plugins/opendistro-knn/knn-lib/ 

# Tar generation
echo "generating tar"
tar -czf $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz $PACKAGE_NAME-$OD_VERSION
#tar -tavf $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz
cd $TARGET_DIR
shasum -a 512 $PACKAGE_NAME-$OD_VERSION.tar.gz > $PACKAGE_NAME-$OD_VERSION.tar.gz.sha512
shasum -a 512 -c $PACKAGE_NAME-$OD_VERSION.tar.gz.sha512
echo " CHECKSUM FILE: "
echo "$(cat $PACKAGE_NAME-$OD_VERSION.tar.gz.sha512)"
cd $ROOT
rm -rf $PACKAGE_NAME-$OD_VERSION

# Upload to S3
ls -ltr $TARGET_DIR
tar_artifact=`ls $TARGET_DIR/*.tar.gz`
tar_checksum_artifact=`ls $TARGET_DIR/*.tar.gz.sha512`
aws s3 cp $tar_artifact s3://$S3_BUCKET/downloads/tarball/opendistro-elasticsearch/
aws s3 cp $tar_checksum_artifact s3://$S3_BUCKET/downloads/tarball/opendistro-elasticsearch/
aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/downloads/*"

