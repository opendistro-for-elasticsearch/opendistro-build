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
#Download opensourceversion

set -e

REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
MANIFEST_FILE=$REPO_ROOT/release-tools/scripts/manifest.yml
ES_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --es`; echo ES_VERSION: $ES_VERSION
OD_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --od`; echo OD_VERSION: $OD_VERSION
S3_RELEASE_BASEURL=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE`
S3_RELEASE_FINAL_BUILD=`yq eval '.urls.ODFE.releases_final_build' $MANIFEST_FILE | sed 's/\///g'`
S3_RELEASE_BUCKET=`echo $S3_RELEASE_BASEURL | awk -F '/' '{print $3}'`
PLATFORM="macos"; echo PLATFORM $PLATFORM
ARCHITECTURE="x64"; if [ ! -z "$1" ]; then ARCHITECTURE=$1; fi; echo ARCHITECTURE $ARCHITECTURE
ES_URL=`yq eval '.urls.ES.'$PLATFORM'_'$ARCHITECTURE'' $MANIFEST_FILE`
ES_ARTIFACT=`basename $ES_URL`

# knnlib version only for tar distros here
knnlib_version=`$REPO_ROOT/release-tools/scripts/plugin_parser.sh opendistro-knnlib plugin_version`; echo knnlib_version: $knnlib_version 

# Please DO NOT change the orders, they have dependencies
PLUGINS=`$REPO_ROOT/release-tools/scripts/plugins-info.sh elasticsearch-plugins plugin_basename`
PLUGINS_ARRAY=( $PLUGINS )
PLUGIN_PATH=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE | sed "s/^.*$S3_RELEASE_BUCKET\///g"`
PACKAGE_NAME="opendistroforelasticsearch"
WORK_DIR="${PACKAGE_NAME}-${OD_VERSION}"
TARGET_DIR="$ROOT/target"
basedir="${ROOT}/$WORK_DIR/plugins"

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
mkdir $WORK_DIR
mkdir $TARGET_DIR

# Downloading ES oss
echo "Downloading ES oss"
wget -nv $ES_URL; echo $?
tar -xzf $ES_ARTIFACT --strip-components=1 --directory "$WORK_DIR" && rm -rf $ES_ARTIFACT
cp -v opendistro-tar-install.sh $WORK_DIR

# Install Plugin
rm -rf /tmp/plugins
mkdir -p /tmp/plugins

for index in ${!PLUGINS_ARRAY[@]}
do
  plugin_latest=`(aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}/$S3_RELEASE_BUILD/elasticsearch-plugins" --query 'Contents[].[Key]' --output text | grep -v sha512 | grep ${PLUGINS_ARRAY[$index]} | grep zip) || (echo None)` 
  plugin_counts=`echo $plugin_latest | sed 's/.zip[ ]*/.zip\n/g' | sed '/^$/d' | wc -l`
  
  if [ "$plugin_counts" -gt 1 ]
  then
    plugin_latest=`echo $plugin_latest | sed 's/.zip[ ]*/.zip\n/g' | sed '/^$/d' | grep "$PLATFORM" | grep "$ARCHITECTURE"`
  fi
  
  if [ "$plugin_latest" != "None" ]
  then
    echo "downloading $plugin_latest"
    plugin_path=${PLUGINS_ARRAY[$index]}
    echo "plugin path:  $plugin_path"
    aws s3 cp "s3://${S3_RELEASE_BUCKET}/${plugin_latest}" "/tmp/plugins" --quiet; echo $?
    plugin=`echo $plugin_latest | awk -F '/' '{print $NF}'`
    echo "installing $plugin"
    $WORK_DIR/bin/elasticsearch-plugin install --batch file:/tmp/plugins/$plugin; \
  fi
done


# List Plugins
echo "List available plugins"
ls -lrt $basedir

# Move performance-analyzer-rca folder
perf_dir=`ls -p $basedir | grep performance`
rca_dir=`ls -p $basedir/$perf_dir | grep rca/`
cp -r $WORK_DIR/plugins/$perf_dir$rca_dir $WORK_DIR
chmod -R 755 $WORK_DIR/$rca_dir

# Move agent script directly into ES_HOME/bin
perf_analyzer=`ls -p $WORK_DIR/bin/ | grep performance`
mv $WORK_DIR/bin/$perf_analyzer/performance-analyzer-agent-cli $WORK_DIR/bin
rm -rf $WORK_DIR/bin/opendistro-performance-analyzer

# Make sure the data folder exists and is writable
mkdir -p $WORK_DIR/data
chmod 755 $WORK_DIR/data/

# Download Knn lib
# Get knnlib artifact information from Manifest
knnlib_is_rc=`$REPO_ROOT/release-tools/scripts/plugin_parser.sh opendistro-knnlib release_candidate`; echo knnlib_is_rc $knnlib_is_rc
knnlib_basename=`$REPO_ROOT/release-tools/scripts/plugin_parser.sh opendistro-knnlib plugin_basename`; echo knnlib_basename $knnlib_basename
if $knnlib_is_rc
then
  echo "aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix ${PLUGIN_PATH}${OD_VERSION}/$S3_RELEASE_BUILD/opendistro-libs/"
  knnlib_latest=`aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}/$S3_RELEASE_BUILD/opendistro-libs/" --query 'Contents[].[Key]' --output text \
                 | grep -v sha512 | grep "$knnlib_basename" | grep zip | grep "$PLATFORM" | grep "$ARCHITECTURE"`
  echo "downloading $knnlib_latest"
  aws s3 cp "s3://${S3_RELEASE_BUCKET}/$knnlib_latest" ./
  unzip ${knnlib_basename}*.zip
  mkdir -p $WORK_DIR/plugins/opendistro-knn/knn-lib/
  mv -v opendistro-knnlib*/libKNNIndex*.jnilib $WORK_DIR/plugins/opendistro-knn/knn-lib/
fi

# Tar generation
echo "generating tar"
tar -czf $TARGET_DIR/$WORK_DIR-$PLATFORM-$ARCHITECTURE.tar.gz $WORK_DIR
cd $TARGET_DIR
shasum -a 512 $WORK_DIR-$PLATFORM-$ARCHITECTURE.tar.gz > $WORK_DIR-$PLATFORM-$ARCHITECTURE.tar.gz.sha512
shasum -a 512 -c $WORK_DIR-$PLATFORM-$ARCHITECTURE.tar.gz.sha512
echo " CHECKSUM FILE: "
echo "$(cat $WORK_DIR-$PLATFORM-$ARCHITECTURE.tar.gz.sha512)"
cd $ROOT
rm -rf $WORK_DIR

# Upload to S3
ls -ltr $TARGET_DIR
tar_artifact=`ls $TARGET_DIR/*.tar.gz`
tar_checksum_artifact=`ls $TARGET_DIR/*.tar.gz.sha512`
echo "Staging destination : s3://$S3_RELEASE_BUCKET/${PLUGIN_PATH}${OD_VERSION}/odfe/"
aws s3 cp $tar_artifact s3://$S3_RELEASE_BUCKET/${PLUGIN_PATH}${OD_VERSION}/odfe/
aws s3 cp $tar_checksum_artifact s3://$S3_RELEASE_BUCKET/${PLUGIN_PATH}${OD_VERSION}/odfe/

