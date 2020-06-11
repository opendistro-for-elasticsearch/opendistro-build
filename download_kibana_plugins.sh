#!/bin/bash
set -e
ROOT=`pwd`
cd kibana/bin
OD_VERSION=`./version-info --od`
cd $ROOT/kibana
PLUGIN_DIR="docker/build/kibana/plugins"

# Please DO NOT change the orders, they have dependencies
PLUGINS="opendistro-sql-workbench/opendistro-sql-workbench-$OD_VERSION \
         opendistro-anomaly-detection/opendistro-anomaly-detection-kibana-$OD_VERSION \
         opendistro-security/opendistro_security_kibana_plugin-$OD_VERSION \
         opendistro-alerting/opendistro-alerting-$OD_VERSION \
         opendistro-index-management/opendistro_index_management_kibana-$OD_VERSION"

echo "$OD_VERSION"
mkdir $PLUGIN_DIR

for plugin_path in $PLUGINS
do
  plugin_latest=`aws s3api list-objects --bucket artifacts.opendistroforelasticsearch.amazon.com --prefix "downloads/kibana-plugins/${plugin_path}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
  echo "downloading $plugin_latest"
  echo `echo $plugin_latest | awk -F '/' '{print $NF}'` >> $PLUGIN_DIR/plugins_kibana.list
  aws s3 cp "s3://artifacts.opendistroforelasticsearch.amazon.com/${plugin_latest}" "${PLUGIN_DIR}" --quiet; echo $?
done

ls -ltr $PLUGIN_DIR
