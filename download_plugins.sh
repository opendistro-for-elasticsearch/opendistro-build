#!/bin/bash
set -e
ROOT=`pwd`
cd elasticsearch/bin
OD_VERSION=`./version-info --od`
cd $ROOT/elasticsearch
PLUGIN_DIR="docker/build/elasticsearch/plugins"

PLUGINS="opendistro-alerting/opendistro_alerting-$OD_VERSION \
         opendistro-anomaly-detection/opendistro-anomaly-detection-$OD_VERSION \
         opendistro-index-management/opendistro_index_management-$OD_VERSION \
         opendistro-job-scheduler/opendistro-job-scheduler-$OD_VERSION \
         opendistro-knn/opendistro-knn-$OD_VERSION \
         opendistro-security/opendistro_security-$OD_VERSION \
         opendistro-sql/opendistro_sql-$OD_VERSION \
         performance-analyzer/opendistro_performance_analyzer-$OD_VERSION"


echo "$OD_VERSION"
mkdir $PLUGIN_DIR

for plugin_path in $PLUGINS
do
  plugin_latest=`aws s3api list-objects --bucket artifacts.opendistroforelasticsearch.amazon.com --prefix "downloads/elasticsearch-plugins/${plugin_path}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
  echo "installing $plugin_latest"
  aws s3 cp "s3://artifacts.opendistroforelasticsearch.amazon.com/${plugin_latest}" "${PLUGIN_DIR}" --quiet
done
