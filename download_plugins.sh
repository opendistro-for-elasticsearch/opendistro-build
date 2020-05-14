#!/bin/bash
CURRENT_NO_PLUGINS=6
plugin_arr=()
unavailable_plugin=()
available_plugin=()
PLUGINS="opendistro-anomaly-detection/opendistro-anomaly-detection opendistro-sql/opendistro_sql opendistro-alerting/opendistro_alerting opendistro-job-scheduler/opendistro-job-scheduler opendistro-security/opendistro_security performance-analyzer/opendistro_performance_analyzer opendistro-index-management/opendistro_index_management opendistro-knn/opendistro-knn"

cd elasticsearch/bin
ls -ltr
OD_VERSION=`./version-info --od`
echo "$OD_VERSION"
cd ..

mkdir docker/build/elasticsearch/plugins

for item in $PLUGINS
  do
     plugin_folder=`echo $item|awk -F/ '{print $1}'`
     plguin_item=`echo $item|awk -F/ '{print $2}'`
     plugin_arr+=( $plguin_item )
     aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/elasticsearch-plugins/$plugin_folder/ docker/build/elasticsearch/plugins/ --recursive --exclude "*" --include "$plguin_item-$OD_VERSION*"
  done
