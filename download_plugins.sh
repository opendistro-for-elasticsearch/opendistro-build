#!/bin/bash

# Please do not change this comment
# Script will download even when artifacts are not fully available
#set -e
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
ES_VERSION=`$REPO_ROOT/bin/version-info --es`; echo ES_VERSION: $ES_VERSION
OD_VERSION=`$REPO_ROOT/bin/version-info --od`; echo OD_VERSION: $OD_VERSION
IS_CUT=`$REPO_ROOT/bin/version-info --is-cut`; echo IS_CUT: $IS_CUT
S3_BUCKET="artifacts.opendistroforelasticsearch.amazon.com"
PLUGIN_DIR="docker/build/elasticsearch/plugins"
plugin_version=$OD_VERSION

# Please DO NOT change the orders, they have dependencies
PLUGINS=`$REPO_ROOT/bin/plugins-info elasticsearch zip --require-install-true`
PLUGINS_ARRAY=( $PLUGINS )
CUT_VERSIONS=`$REPO_ROOT/bin/plugins-info elasticsearch cutversion --require-install-true`
CUT_VERSIONS_ARRAY=( $CUT_VERSIONS )

cd $ROOT/elasticsearch
mkdir $PLUGIN_DIR

for index in ${!PLUGINS_ARRAY[@]}
do
  if [ "$IS_CUT" = "true" ]
  then
    plugin_version=${CUT_VERSIONS_ARRAY[$index]}
  fi

  plugin_path=${PLUGINS_ARRAY[$index]}
  plugin_latest=`aws s3api list-objects --bucket $S3_BUCKET --prefix "downloads/elasticsearch-plugins/${plugin_path}-${plugin_version}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`

  if [ "$plugin_path" != "none" ]
  then
    echo "downloading $plugin_latest"
    (echo $plugin_latest | grep -qhi 'None') || (echo `echo $plugin_latest | awk -F '/' '{print $NF}'` >> $PLUGIN_DIR/plugins.list)
    aws s3 cp "s3://${S3_BUCKET}/${plugin_latest}" "${PLUGIN_DIR}" --quiet; echo $?
  fi
done

ls -ltr $PLUGIN_DIR
