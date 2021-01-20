#!/bin/bash

# Please do not change this comment
# Script will download even when artifacts are not fully available
# Requires yq v4.0.0+

set -e
CATEGORY=$1; echo CATEGORY $CATEGORY; if [ -z "$CATEGORY" ]; then echo "Please enter plugin category as parameter: elasticsearch/kibana"; exit 1; fi
ARCHTECTURE="x64"; if [ ! -z "$2" ]; then ARCHITECTURE=$2; fi; echo ARCHITECTURE $ARCHITECTURE
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
MANIFEST_FILE=$ROOT/manifest.yml
ES_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --es`; echo ES_VERSION: $ES_VERSION
OD_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --od`; echo OD_VERSION: $OD_VERSION
S3_RELEASE_BASEURL=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE`
S3_RELEASE_FINAL_BUILD=`yq eval '.urls.ODFE.releases_final_build' $MANIFEST_FILE | sed 's/\///g'`
S3_RELEASE_BUCKET=`echo $S3_RELEASE_BASEURL | awk -F '/' '{print $3}'`

PLUGIN_DIR="$REPO_ROOT/$CATEGORY/docker/build/$CATEGORY/plugins"
PLUGIN_PATH=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE | sed "s/^.*$S3_RELEASE_BUCKET\///g"`

if [ -z "$S3_RELEASE_FINAL_BUILD" ]
then
  S3_RELEASE_BUILD=`aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}" --query 'Contents[].[Key]' --output text | awk -F '/' '{print $3}' | uniq | tail -n 1`
  echo Latest: $S3_RELEASE_BUILD
else
  S3_RELEASE_BUILD=$S3_RELEASE_FINAL_BUILD
  echo Final: $S3_RELEASE_BUILD
fi


# Please DO NOT change the orders, they have dependencies
PLUGINS_ARRAY=( `${REPO_ROOT}/release-tools/scripts/plugins-info.sh ${CATEGORY}-plugins plugin_basename` )

rm -rf $PLUGIN_DIR
mkdir -p $PLUGIN_DIR

for index in ${!PLUGINS_ARRAY[@]}
do
  if echo ${PLUGINS_ARRAY[$index]} | grep -i reports
  then
    plugin_latest=`aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}/${S3_RELEASE_BUILD}/${CATEGORY}-plugins" --query 'Contents[].[Key]' --output text \
                   | grep -v sha512 | grep ${PLUGINS_ARRAY[$index]} | grep zip | grep linux | grep "$ARCHITECTURE" | sort | tail -n 1`
  else
    plugin_latest=`aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}/${S3_RELEASE_BUILD}/${CATEGORY}-plugins" --query 'Contents[].[Key]' --output text \
                   | grep -v sha512 | grep ${PLUGINS_ARRAY[$index]} | grep zip | sort | tail -n 1`
  fi

  if [ ! -z "$plugin_latest" ]
  then
    echo "downloading $plugin_latest"
    echo `echo $plugin_latest | awk -F '/' '{print $NF}'` >> ${PLUGIN_DIR}/plugins_${CATEGORY}.list
    aws s3 cp "s3://${S3_RELEASE_BUCKET}/${plugin_latest}" "${PLUGIN_DIR}" --quiet; echo $?
  fi
done

ls -ltr $PLUGIN_DIR
