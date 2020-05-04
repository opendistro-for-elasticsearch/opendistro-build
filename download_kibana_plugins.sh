#!/bin/bash
CURRENT_NO_PLUGINS=4
plugin_arr=()
unavailable_plugin=()
available_plugin=()
PLUGINS="opendistro-anomaly-detection/opendistro-anomaly-detection-kibana opendistro-security/opendistro_security_kibana_plugin opendistro-alerting/opendistro-alerting opendistro-index-management/opendistro_index_management_kibana opendistro-sql-kibana/sql-kibana"
cd kibana/bin
ls -ltr
OD_VERSION=`./version-info --od`
echo "$OD_VERSION"
cd ..

mkdir docker/build/kibana/plugins

for item in $PLUGINS
  do
     plugin_folder=`echo $item|awk -F/ '{print $1}'`
     plguin_item=`echo $item|awk -F/ '{print $2}'`
     plugin_arr+=( $plguin_item )
     aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/kibana-plugins/$plugin_folder/ docker/build/kibana/plugins/ --recursive --exclude "*" --include "$plguin_item-$OD_VERSION*"
  done
