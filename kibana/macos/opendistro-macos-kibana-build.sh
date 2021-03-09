#!/bin/bash

# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

# Description:
# This script generates packages for opendistro-for-elasticsearch-kibana.

# Node-JS binaries under kibana/node which is being used while installing / removing plugin


set -e

# Initialize directories
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
MANIFEST_FILE=$REPO_ROOT/release-tools/scripts/manifest.yml
ES_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --es`; echo ES_VERSION: $ES_VERSION
OD_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --od`; echo OD_VERSION: $OD_VERSION
S3_RELEASE_BASEURL=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE`
S3_RELEASE_FINAL_BUILD=`yq eval '.urls.ODFE.releases_final_build' $MANIFEST_FILE | gsed 's/\///g'`
S3_RELEASE_BUCKET=`echo $S3_RELEASE_BASEURL | awk -F '/' '{print $3}'`
PACKAGE_TYPE="tar"; echo PACKAGE_TYPE $PACKAGE_TYPE
PACKAGE_NAME="opendistroforelasticsearch-kibana"
TARGET_DIR="$ROOT/target"
PLATFORM="macos"; echo PLATFORM $PLATFORM
ARCHITECTURE="x64"; if [ ! -z "$2" ]; then ARCHITECTURE=$3; fi; echo ARCHITECTURE $ARCHITECTURE
KIBANA_URL=`yq eval '.urls.KIBANA.'$PLATFORM'_'$ARCHITECTURE'' $MANIFEST_FILE`


# Please DO NOT change the orders, they have dependencies
PLUGINS=`$REPO_ROOT/release-tools/scripts/plugins-info.sh kibana-plugins plugin_basename`
PLUGINS_ARRAY=($PLUGINS )
PLUGIN_PATH=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE | gsed "s/^.*$S3_RELEASE_BUCKET\///g"`

basedir="${ROOT}/${PACKAGE_NAME}/plugins"

echo $ROOT

if [ -z "$S3_RELEASE_FINAL_BUILD" ]
then
  S3_RELEASE_BUILD=`aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}" --query 'Contents[].[Key]' --output text | awk -F '/' '{print $3}' | uniq | tail -n 1`
  echo Latest: $S3_RELEASE_BUILD
else
  S3_RELEASE_BUILD=$S3_RELEASE_FINAL_BUILD
  echo Final: $S3_RELEASE_BUILD
fi

if [ -z "$PLUGINS" ]; then
  echo "Provide plugin list to install (separated by space)"
  exit 1
fi

# Prepare target directories
rm -rf $TARGET_DIR
rm -rf $PACKAGE_NAME
mkdir -p $TARGET_DIR
mkdir -p $PACKAGE_NAME

# Downloading Kibana oss
echo "Downloading kibana oss"
basename $KIBANA_URL
curl -Ls $KIBANA_URL | tar --strip-components=1 -zxf - --directory $PACKAGE_NAME

# Install required plugins
echo "installing open distro plugins"
rm -rf /tmp/plugins
mkdir -p /tmp/plugins
for index in ${!PLUGINS_ARRAY[@]}
do
  plugin_latest=`(aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}/$S3_RELEASE_BUILD/kibana-plugins" --query 'Contents[].[Key]' --output text | grep -v sha512 |grep ${PLUGINS_ARRAY[$index]} |grep zip) || (echo None)`
  plugin_counts=`echo $plugin_latest | gsed 's/.zip[ ]*/.zip\n/g' | gsed '/^$/d' | wc -l`
  echo "plugin count: $plugin_counts"
  if [ "$plugin_counts" -gt 1 ]
  then
    plugin_latest=`(echo $plugin_latest | gsed 's/.zip[ ]*/.zip\n/g' | gsed '/^$/d' | grep "$PLATFORM" | grep "$ARCHITECTURE") || (echo None)`
  fi
  if [ "$plugin_latest" != "None" ]
  then
    echo "downloading $plugin_latest"
    plugin_path=${PLUGINS_ARRAY[$index]}
    echo "plugin path:  $plugin_path"
    aws s3 cp "s3://${S3_RELEASE_BUCKET}/$plugin_latest" "/tmp/plugins" --quiet; echo $?
    plugin=`echo $plugin_latest | awk -F '/' '{print $NF}'`
    echo "installing $plugin"
    $PACKAGE_NAME/bin/kibana-plugin --allow-root install file:/tmp/plugins/$plugin
  fi
done

# List Plugins
echo "List available plugins"
ls -lrt $basedir

# Replace kibana.yml with default opendistro yml
cp config/kibana.yml $PACKAGE_NAME/config

echo "building artifact: ${PACKAGE_TYPE}"

# Generating tar
rm -rf $TARGET_DIR/*tar*
echo "generating tar"
tar -czf $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION-$PLATFORM-$ARCHITECTURE.tar.gz $PACKAGE_NAME
cd $TARGET_DIR
shasum -a 512 $PACKAGE_NAME-$OD_VERSION-$PLATFORM-$ARCHITECTURE.tar.gz > $PACKAGE_NAME-$OD_VERSION-$PLATFORM-$ARCHITECTURE.tar.gz.sha512
shasum -a 512 -c $PACKAGE_NAME-$OD_VERSION-$PLATFORM-$ARCHITECTURE.tar.gz.sha512
echo " CHECKSUM FILE "
echo "$(cat $PACKAGE_NAME-$OD_VERSION-$PLATFORM-$ARCHITECTURE.tar.gz.sha512)"
cd $ROOT

# Upload to S3
ls -ltr $TARGET_DIR
tar_artifact=`ls $TARGET_DIR/*.tar.gz`
tar_checksum_artifact=`ls $TARGET_DIR/*.tar.gz.sha512`
echo "Staging destination : s3://$S3_RELEASE_BUCKET/${PLUGIN_PATH}${OD_VERSION}/odfe/"
aws s3 cp $tar_artifact s3://$S3_RELEASE_BUCKET/${PLUGIN_PATH}${OD_VERSION}/odfe/
aws s3 cp $tar_checksum_artifact s3://$S3_RELEASE_BUCKET/${PLUGIN_PATH}${OD_VERSION}/odfe/
