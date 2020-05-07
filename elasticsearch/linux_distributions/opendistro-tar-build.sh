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
ES_VERSION=$(../bin/version-info --es)
OD_VERSION=$(../bin/version-info --od)
OD_PLUGINVERSION=$OD_VERSION.0
PACKAGE=opendistroforelasticsearch
ROOT=$(dirname "$0")
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-linux-x86_64.tar.gz
#Untar
tar -xzf elasticsearch-oss-$ES_VERSION-linux-x86_64.tar.gz 
rm -rf elasticsearch-oss-$ES_VERSION-linux-x86_64.tar.gz
#Install Plugin
for plugin_path in opendistro-sql/opendistro_sql-$OD_PLUGINVERSION.zip opendistro-alerting/opendistro_alerting-$OD_PLUGINVERSION.zip opendistro-job-scheduler/opendistro-job-scheduler-$OD_PLUGINVERSION.zip opendistro-security/opendistro_security-$OD_PLUGINVERSION.zip performance-analyzer/opendistro_performance_analyzer-$OD_PLUGINVERSION.zip opendistro-index-management/opendistro_index_management-$OD_PLUGINVERSION.zip opendistro-knn/opendistro-knn-$OD_PLUGINVERSION.zip opendistro-anomaly-detection/opendistro-anomaly-detection-$OD_PLUGINVERSION.zip;
do
    elasticsearch-$ES_VERSION/bin/elasticsearch-plugin install --batch "https://d3g5vo6xdbdb9a.cloudfront.net/downloads/elasticsearch-plugins/$plugin_path"; \
done

cp opendistro-tar-install.sh elasticsearch-$ES_VERSION
mv elasticsearch-$ES_VERSION $PACKAGE-$OD_VERSION

echo "validating that plugins has been installed"
basedir=$PWD/$PACKAGE-$OD_VERSION/plugins
arr=("$basedir/opendistro-job-scheduler" "$basedir/opendistro_alerting" "$basedir/opendistro_performance_analyzer" "$basedir/opendistro_security" "$basedir/opendistro_sql" "$basedir/opendistro_index_management" "$basedir/opendistro-knn" "$basedir/opendistro-anomaly-detection")
for d in "${arr[@]}"; do
    echo "$d" 
    if [ -d "$d" ]; then
        echo "directoy "$d" is present"
    else
        echo "ERROR: "$d" is not present"
        exit 1;
    fi
done
echo "validated that plugins has been installed"

rm -rf tarfiles
mkdir tarfiles
TARGET_DIR="$ROOT/tarfiles"
tar -vczf $TARGET_DIR/$PACKAGE-$OD_VERSION.tar.gz $PACKAGE-$OD_VERSION
sha512sum $TARGET_DIR/$PACKAGE-$OD_VERSION.tar.gz  > $TARGET_DIR/$PACKAGE-$OD_VERSION.tar.gz.sha512
sha512sum -c $TARGET_DIR/$PACKAGE-$OD_VERSION.tar.gz.sha512
echo " CHECKSUM FILE "
echo "$(cat $TARGET_DIR/$PACKAGE-$OD_VERSION.tar.gz.sha512)"
rm -rf $PACKAGE-$OD_VERSION
