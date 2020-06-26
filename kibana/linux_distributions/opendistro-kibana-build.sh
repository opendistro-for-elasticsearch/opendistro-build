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

# Description:
# This script generates packages for opendistro-for-elasticsearch-kibana.

# Node-JS binaries under kibana/node which is being used while installing / removing plugin

# if [[ "$OSTYPE" == "darwin"* ]]; then
#   echo "Run this script in Linux machine as node binary shipped in Kibana is for Linux platform"
#   exit 1
# fi

set -e

# Initialize directories
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
ES_VERSION=`$REPO_ROOT/bin/version-info --es`; echo $ES_VERSION
OD_VERSION=`$REPO_ROOT/bin/version-info --od`; echo $OD_VERSION
PACKAGE_TYPE=$1
S3_BUCKET="artifacts.opendistroforelasticsearch.amazon.com"
ARTIFACTS_URL="https://d3g5vo6xdbdb9a.cloudfront.net"
PACKAGE_NAME="opendistroforelasticsearch-kibana"
TARGET_DIR="$ROOT/target"

# Please DO NOT change the orders, they have dependencies
PLUGINS=`$REPO_ROOT/bin/plugins-info kibana`

basedir="${ROOT}/${PACKAGE_NAME}/plugins"
PLUGINS_CHECKS=`$REPO_ROOT/bin/plugins-info kibana | awk -F '/' '{print $2}' | sed "s@^@$basedir\/@g"`

echo $ROOT

if [ -z "$PLUGINS" ]; then
  echo "Provide plugin list to install (separated by space)"
  exit 1
fi

# If the input is set, but it's set to neither rpm nor deb, then exit.
if [ -n $PACKAGE_TYPE ] && [ "$PACKAGE_TYPE" != "rpm" ] && [ "$PACKAGE_TYPE" != "deb" ] && [ "$PACKAGE_TYPE" != "tar" ]; then
  printf "You entered %s. Please enter 'rpm' to build rpm or 'deb' or 'tar' to build deb or nothing to build both.\n" "$PACKAGE_TYPE"
  exit 1
fi

# Prepare target directories
mkdir $TARGET_DIR
mkdir $PACKAGE_NAME

# Downloading Kibana oss
echo "Downloading kibana oss"
curl -Ls "https://artifacts.elastic.co/downloads/kibana/kibana-oss-$ES_VERSION-linux-x86_64.tar.gz" | tar --strip-components=1 -zxf - --directory $PACKAGE_NAME

# Install required plugins
echo "installing open distro plugins"
for plugin_path in $PLUGINS
do
  plugin_latest=`aws s3api list-objects --bucket $S3_BUCKET --prefix "downloads/kibana-plugins/${plugin_path}-${OD_VERSION}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
  echo "installing $plugin_latest"
  $PACKAGE_NAME/bin/kibana-plugin --allow-root install "${ARTIFACTS_URL}/${plugin_latest}"
done

# List Plugins
echo "List available plugins"
ls -lrt $basedir

# Replace kibana.yml with default opendistro yml
cp config/kibana.yml $PACKAGE_NAME/config

echo "building artifact: ${PACKAGE_TYPE}"

if [ $# -eq 0 ] || [ "$PACKAGE_TYPE" = "rpm" ]; then
  echo "generating rpm"
  fpm --force \
      -t rpm \
      --package $TARGET_DIR/NAME-$OD_VERSION.TYPE \
      -s dir \
      --name $PACKAGE_NAME \
      --description "Explore and visualize your Elasticsearch data" \
      --version $OD_VERSION \
      --url https://aws.amazon.com/ \
      --vendor "Amazon Web Services, Inc." \
      --maintainer "Opendistro Team <opendistroforelasticsearch@amazon.com>" \
      --license "ASL 2.0" \
      --conflicts kibana \
      --after-install $ROOT/scripts/post_install.sh \
      --before-install $ROOT/scripts/pre_install.sh \
      --before-remove $ROOT/scripts/pre_remove.sh \
      --after-remove $ROOT/scripts/post_remove.sh \
      --config-files /etc/kibana/kibana.yml \
      --template-value user=kibana \
      --template-value group=kibana \
      --template-value optimizeDir=/usr/share/kibana/optimize \
      --template-value configDir=/etc/kibana \
      --template-value pluginsDir=/usr/share/kibana/plugins \
      --template-value dataDir=/var/lib/kibana \
      --exclude usr/share/kibana/config \
      --exclude usr/share/kibana/data \
      --architecture x86_64 \
      --rpm-os linux \
      $ROOT/opendistroforelasticsearch-kibana/=/usr/share/kibana/ \
      $ROOT/opendistroforelasticsearch-kibana/config/=/etc/kibana/ \
      $ROOT/opendistroforelasticsearch-kibana/data/=/var/lib/kibana/ \
      $ROOT/service_templates/sysv/etc/=/etc/ \
      $ROOT/service_templates/systemd/etc/=/etc/

      # Upload to S3
      ls -ltr $TARGET_DIR
      rpm_artifact=`ls $TARGET_DIR/*.rpm`
      aws s3 cp $rpm_artifact s3://$S3_BUCKET/downloads/rpms/opendistroforelasticsearch-kibana/
      aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/downloads/*"

fi

if [ $# -eq 0 ] || [ "$PACKAGE_TYPE" = "deb" ]; then
  echo "generating deb"
  fpm --force \
      -t deb \
      --package $TARGET_DIR/NAME-$OD_VERSION.TYPE \
      -s dir \
      --name $PACKAGE_NAME \
      --description "Explore and visualize your Elasticsearch data" \
      --version $OD_VERSION \
      --url https://aws.amazon.com/ \
      --vendor "Amazon Web Services, Inc." \
      --maintainer "Opendistro Team <opendistroforelasticsearch@amazon.com>" \
      --license "ASL 2.0" \
      --conflicts kibana \
      --after-install $ROOT/scripts/post_install.sh \
      --before-install $ROOT/scripts/pre_install.sh \
      --before-remove $ROOT/scripts/pre_remove.sh \
      --after-remove $ROOT/scripts/post_remove.sh \
      --config-files /etc/kibana/kibana.yml \
      --template-value user=kibana \
      --template-value group=kibana \
      --template-value optimizeDir=/usr/share/kibana/optimize \
      --template-value configDir=/etc/kibana \
      --template-value pluginsDir=/usr/share/kibana/plugins \
      --template-value dataDir=/var/lib/kibana \
      --exclude usr/share/kibana/config \
      --exclude usr/share/kibana/data \
      --architecture amd64 \
      $ROOT/opendistroforelasticsearch-kibana/=/usr/share/kibana/ \
      $ROOT/opendistroforelasticsearch-kibana/config/=/etc/kibana/ \
      $ROOT/opendistroforelasticsearch-kibana/data/=/var/lib/kibana/ \
      $ROOT/service_templates/sysv/etc/=/etc/ \
      $ROOT/service_templates/systemd/etc/=/etc/

      # Upload to S3
      ls -ltr $TARGET_DIR
      deb_artifact=`ls $TARGET_DIR/*.deb`
      aws s3 cp $deb_artifact s3://$S3_BUCKET/downloads/debs/opendistroforelasticsearch-kibana/
      aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/downloads/*"

fi

if [ $# -eq 0 ] || [ "$PACKAGE_TYPE" = "tar" ]; then

  # Generating tar
  rm -rf $TARGET_DIR/*tar*
  echo "generating tar"
  tar -czf $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz $PACKAGE_NAME
  #tar -tzvf $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz
  cd $TARGET_DIR
  shasum -a 512 $PACKAGE_NAME-$OD_VERSION.tar.gz > $PACKAGE_NAME-$OD_VERSION.tar.gz.sha512
  shasum -a 512 -c $PACKAGE_NAME-$OD_VERSION.tar.gz.sha512
  echo " CHECKSUM FILE "
  echo "$(cat $PACKAGE_NAME-$OD_VERSION.tar.gz.sha512)"
  cd $ROOT

  # Upload to S3
  ls -ltr $TARGET_DIR
  tar_artifact=`ls $TARGET_DIR/*.tar.gz`
  tar_checksum_artifact=`ls $TARGET_DIR/*.tar.gz.sha512`
  aws s3 cp $tar_artifact s3://$S3_BUCKET/downloads/tarball/opendistroforelasticsearch-kibana/
  aws s3 cp $tar_checksum_artifact s3://$S3_BUCKET/downloads/tarball/opendistroforelasticsearch-kibana/
  aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/downloads/*"

fi
