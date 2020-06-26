#!/bin/bash

# Please do not change this comment
# Script will download even when artifacts are not fully available
#set -e
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
ES_VERSION=`$REPO_ROOT/bin/version-info --es`; echo $ES_VERSION
OD_VERSION=`$REPO_ROOT/bin/version-info --od`; echo $OD_VERSION
S3_BUCKET="artifacts.opendistroforelasticsearch.amazon.com"
PLUGIN_DIR="docker/build/elasticsearch/plugins"

# Please DO NOT change the orders, they have dependencies
PLUGINS=`$REPO_ROOT/bin/plugins-info zip`
echo PLUGINS $PLUGINS

cd $ROOT/elasticsearch
mkdir $PLUGIN_DIR

for plugin_path in $PLUGINS
do
  plugin_latest=`aws s3api list-objects --bucket $S3_BUCKET --prefix "downloads/elasticsearch-plugins/${plugin_path}-${OD_VERSION}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
  echo "downloading $plugin_latest"
  (echo $plugin_latest | grep -qhi 'None') || (echo `echo $plugin_latest | awk -F '/' '{print $NF}'` >> $PLUGIN_DIR/plugins.list)
  aws s3 cp "s3://${S3_BUCKET}/${plugin_latest}" "${PLUGIN_DIR}" --quiet; echo $?
done

ls -ltr $PLUGIN_DIR
