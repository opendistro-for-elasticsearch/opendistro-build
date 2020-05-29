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
ROOT=`pwd`
plugin_arr=()
ES_VERSION=$(../bin/version-info --es)
OD_VERSION=$(../bin/version-info --od)
ARTIFACTS_URL=https://d3g5vo6xdbdb9a.cloudfront.net
PACKAGE_NAME="opendistroforelasticsearch"
TARGET_DIR="$ROOT/target"


# Untar
tar -xzf elasticsearch-oss-$ES_VERSION-linux-x86_64.tar.gz 
rm -rf elasticsearch-oss-$ES_VERSION-linux-x86_64.tar.gz

# Please DO NOT change the orders, they have dependencies
PLUGINS="opendistro-sql/opendistro_sql-$OD_VERSION \
         opendistro-alerting/opendistro_alerting-$OD_VERSION \
         opendistro-job-scheduler/opendistro-job-scheduler-$OD_VERSION \
         opendistro-security/opendistro_security-$OD_VERSION \
         performance-analyzer/opendistro_performance_analyzer-$OD_VERSION \
         opendistro-index-management/opendistro_index_management-$OD_VERSION \
         opendistro-knn/opendistro-knn-$OD_VERSION \
         opendistro-anomaly-detection/opendistro-anomaly-detection-$OD_VERSION"

echo $ROOT

if [ -z "$PLUGINS" ]; then
  echo "Provide plugin list to install (separated by space)"
  exit 1
fi

# Prepare target directories
mkdir $TARGET_DIR

# Downloading ES oss
curl -Ls https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-linux-x86_64.tar.gz | tar --strip-components=1 -zxf - --directory "${PACKAGE_NAME}-${OD_VERSION}"
cp opendistro-tar-install.sh $PACKAGE_NAME-$OD_VERSION

# Install Plugin
for plugin_path in $PLUGINS
do
  plugin_latest=`aws s3api list-objects --bucket artifacts.opendistroforelasticsearch.amazon.com --prefix "downloads/elasticsearch-plugins/${plugin_path}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
  echo "installing $plugin_latest"
  $PACKAGE_NAME-$OD_VERSION/bin/elasticsearch-plugin install --batch "${ARTIFACTS_URL}/${plugin_latest}"; \
  basedir="${PACKAGE_NAME}-${OD_VERSION}/plugins"
  plugin_item=`echo $plugin_path|awk -F/ '{print $2}'`
  plugin_arr+=( "${basedir}/${plugin_item}" )
done

# Validation
echo "validating that plugins has been installed"

for d in "${plugin_arr[@]}"; do
  echo "$d" 
  if [ -d "$d" ]; then
    echo "directoy "$d" is present"
  else
    echo "ERROR: "$d" is not present"
    exit 1;
  fi
done

echo "Results: validated that plugins has been installed"

echo "generating tar"

tar -czf $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz $PACKAGE_NAME-$OD_VERSION
#tar -tavf $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz
sha512sum $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz  > $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz.sha512
sha512sum -c $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz.sha512
echo " CHECKSUM FILE "
echo "$(cat $TARGET_DIR/$PACKAGE_NAME-$OD_VERSION.tar.gz.sha512)"
rm -rf $PACKAGE_NAME-$OD_VERSION
