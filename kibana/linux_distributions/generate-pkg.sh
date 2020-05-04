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


#initialize directories
ROOT=$(dirname "$0")
cd $ROOT
mkdir target opendistroforelasticsearch-kibana

PACKAGE_TYPE=$1

# If the input is set, but it's set to neither rpm nor deb, then exit.
if [[ -n $PACKAGE_TYPE ]] && [[ "$PACKAGE_TYPE" != "rpm" ]] && [[ "$PACKAGE_TYPE" != "deb" ]] && [[ "$PACKAGE_TYPE" != "tar" ]]; then
	printf "You entered %s. Please enter 'rpm' to build rpm or 'deb' or 'tar' to build deb or nothing to build both.\n" "$PACKAGE_TYPE"
	exit 1
fi

PACKAGE_NAME=opendistroforelasticsearch-kibana
TARGET_DIR="$ROOT/target"
ES_VERSION=$(../bin/version-info --es)
OPENDISTRO_VERSION=$(../bin/version-info --od)
ARTIFACTS_URL=https://d3g5vo6xdbdb9a.cloudfront.net
PLUGINS="opendistro-sql-kibana/sql-kibana-$OPENDISTRO_VERSION.0.zip opendistro-anomaly-detection/opendistro-anomaly-detection-kibana-$OPENDISTRO_VERSION.0.zip opendistro-security/opendistro_security_kibana_plugin-$OPENDISTRO_VERSION.0.zip opendistro-alerting/opendistro-alerting-$OPENDISTRO_VERSION.0.zip opendistro-index-management/opendistro_index_management_kibana-$OPENDISTRO_VERSION.0.zip"

if [ -z "$PLUGINS" ]; then
    echo "Provide plugin list to install (separated by space)"
    exit 1
fi

#Downloading Kibana oss
echo "Downloading oss kibana"
cd opendistroforelasticsearch-kibana;
curl -Ls "https://artifacts.elastic.co/downloads/kibana/kibana-oss-$ES_VERSION-linux-x86_64.tar.gz" | tar --strip-components=1 -zxf -

#Install required plugins
echo "installing open distro plugins"
for plugin in $PLUGINS
do
  echo "installing $plugin"
  bin/kibana-plugin --allow-root install "$ARTIFACTS_URL/downloads/kibana-plugins/$plugin"
done
# Navigate to root directory
cd ..
#Replace kibana.yml with default opendistro yml
cp -f config/kibana.yml $PACKAGE_NAME/config

if [ $# -eq 0 ] || [ $PACKAGE_TYPE == "rpm" ]; then
  echo "generating rpm"
  fpm --force \
      -t rpm \
      --package $TARGET_DIR/NAME-$OPENDISTRO_VERSION.TYPE \
      -s dir \
      --name $PACKAGE_NAME \
      --description "Explore and visualize your Elasticsearch data" \
      --version $OPENDISTRO_VERSION \
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

if [ $# -eq 0 ] || [ $PACKAGE_TYPE == "deb" ]; then
echo "generating deb"
fpm --force \
    -t deb \
    --package $TARGET_DIR/NAME-$OPENDISTRO_VERSION.TYPE \
    -s dir \
    --name $PACKAGE_NAME \
    --description "Explore and visualize your Elasticsearch data" \
    --version $OPENDISTRO_VERSION \
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

if [ $# -eq 0 ] || [ $PACKAGE_TYPE == "tar" ]; then
rm -rf $TARGET_DIR/*tar*
echo "generating tar"
    tar -vczf $TARGET_DIR/$PACKAGE_NAME-$OPENDISTRO_VERSION.tar.gz $PACKAGE_NAME
    shasum -a 512 $TARGET_DIR/$PACKAGE_NAME-$OPENDISTRO_VERSION.tar.gz  > $TARGET_DIR/$PACKAGE_NAME-$OPENDISTRO_VERSION.tar.gz.sha512
    shasum -a 512 -c $TARGET_DIR/$PACKAGE_NAME-$OPENDISTRO_VERSION.tar.gz.sha512
fi
