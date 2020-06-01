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


# Initialize directories
ROOT=`pwd`
PACKAGE_TYPE=$1
PACKAGE_NAME="opendistroforelasticsearch-kibana"
TARGET_DIR="$ROOT/target"
ES_VERSION=$(../bin/version-info --es)
OD_VERSION=$(../bin/version-info --od)
ARTIFACTS_URL="https://d3g5vo6xdbdb9a.cloudfront.net"

# Please DO NOT change the orders, they have dependencies
PLUGINS="opendistro-sql-workbench/opendistro-sql-workbench-$OD_VERSION \
         opendistro-anomaly-detection/opendistro-anomaly-detection-kibana-$OD_VERSION \
         opendistro-security/opendistro_security_kibana_plugin-$OD_VERSION \
         opendistro-alerting/opendistro-alerting-$OD_VERSION \
         opendistro-index-management/opendistro_index_management_kibana-$OD_VERSION"

basedir="${ROOT}/${PACKAGE_NAME}/plugins"
PLUGINS_CHECKS="${basedir}/opendistro-sql-workbench \
                ${basedir}/opendistro-anomaly-detection-kibana \
                ${basedir}/opendistro_security \
                ${basedir}/opendistro-alerting \
                ${basedir}/opendistro_index_management_kibana"

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
  plugin_latest=`aws s3api list-objects --bucket artifacts.opendistroforelasticsearch.amazon.com --prefix "downloads/kibana-plugins/${plugin_path}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
  echo "installing $plugin_latest"
  $PACKAGE_NAME/bin/kibana-plugin --allow-root install "${ARTIFACTS_URL}/${plugin_latest}"
done

# Validation
echo "validating that plugins has been installed"
ls -lrt $basedir

for d in $PLUGINS_CHECKS; do
  echo "$d"
  if [ -d "$d" ]; then
    echo "directoy "$d" is present"
  else
    echo "ERROR: "$d" is not present"
    exit 1;
  fi
done

echo "Results: validated that plugins has been installed"

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
fi

if [ $# -eq 0 ] || [ "$PACKAGE_TYPE" = "tar" ]; then
  rm -rf $TARGET_DIR/*tar*
  echo "generating tar"
  tar -czf $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz $PACKAGE_NAME
  #tar -tzvf $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz
  sha512sum $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz  > $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz.sha512
  sha512sum -c $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz.sha512
  echo " CHECKSUM FILE "
  echo "$(cat $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz.sha512)"
fi
