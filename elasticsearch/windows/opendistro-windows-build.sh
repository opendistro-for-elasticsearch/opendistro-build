#!/bin/bash
set -e

PLATFORM="windows"; if [ ! -z "$1" ]; then PLATFORM=$1; fi; echo PLATFORM $PLATFORM
ARCHITECTURE="x64"; if [ ! -z "$2" ]; then ARCHITECTURE=$2; fi; echo ARCHITECTURE $ARCHITECTURE
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
MANIFEST_FILE=$REPO_ROOT/release-tools/scripts/manifest.yml
ES_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --es`; echo ES_VERSION: $ES_VERSION
OD_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --od`; echo OD_VERSION: $OD_VERSION
S3_RELEASE_BASEURL=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE`
S3_RELEASE_FINAL_BUILD=`yq eval '.urls.ODFE.releases_final_build' $MANIFEST_FILE | sed 's/\///g'`
S3_RELEASE_BUCKET=`echo $S3_RELEASE_BASEURL | awk -F '/' '{print $3}'`
PLUGIN_PATH=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE | sed "s/^.*$S3_RELEASE_BUCKET\///g"`
PREBUILD_URL=`yq eval ".urls.ES.${PLATFORM}_${ARCHITECTURE}" $MANIFEST_FILE`
PREBUILD_NAME=`basename $PREBUILD_URL`; echo PREBUILD_NAME $PREBUILD_NAME

PLUGIN_DIR=$ROOT/plugins
TARGET_DIR=$ROOT/target
WORK_DIR=opendistroforelasticsearch-$OD_VERSION

# Set rc build
if [ -z "$S3_RELEASE_FINAL_BUILD" ]
then
  S3_RELEASE_BUILD=`aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}" --query 'Contents[].[Key]' --output text | awk -F '/' '{print $3}' | uniq | tail -n 1`
  echo Latest: $S3_RELEASE_BUILD
else
  S3_RELEASE_BUILD=$S3_RELEASE_FINAL_BUILD
  echo Final: $S3_RELEASE_BUILD
fi

# Please DO NOT change the orders, they have dependencies
PLUGINS_ARRAY=( `${REPO_ROOT}/release-tools/scripts/plugins-info.sh elasticsearch-plugins plugin_basename` )

# Download windowss oss for copying batch files
wget -nv $PREBUILD_URL ; echo $?

# Create corresponding directories
mkdir -p $PLUGIN_DIR
mkdir -p $TARGET_DIR
mkdir -p $WORK_DIR

# Unzip the oss
unzip -q $PREBUILD_NAME
mv -v elasticsearch-${ES_VERSION}/* $WORK_DIR
rm -v -rf $PREBUILD_NAME
rm -v -rf elasticsearch-${ES_VERSION}

# Exception List (space separation)
EXCEPTION_LIST="knn performance"

for index in ${!PLUGINS_ARRAY[@]}
do
  plugin_latest=`(aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}/${S3_RELEASE_BUILD}/elasticsearch-plugins" --query 'Contents[].[Key]' --output text \
                 | grep -v sha512 | grep ${PLUGINS_ARRAY[$index]} | grep zip) || (echo None)`
  plugin_counts=`echo $plugin_latest | sed 's/.zip[ ]*/.zip\n/g' | sed '/^$/d' | wc -l`

  if [ "$plugin_counts" -gt 1 ]
  then
    plugin_latest=`echo $plugin_latest | sed 's/.zip[ ]*/.zip\n/g' | sed '/^$/d' | grep "$PLATFORM" | grep "$ARCHITECTURE"`
  fi

  # Skip entries on the exception list here
  exception_present="false"
  for plugin_exception in $EXCEPTION_LIST
  do
    if echo $plugin_latest | grep -qi $plugin_exception
    then
      exception_present="true"
      break
    fi
  done

  if [ "$plugin_latest" != "None" ] && [ "$exception_present" = "false"  ]
  then
    echo "#################################################################################"
    echo "downloading $plugin_latest"
    plugin_tempname=`echo $plugin_latest | awk -F '/' '{print $NF}'`
    aws s3 cp "s3://${S3_RELEASE_BUCKET}/${plugin_latest}" "${PLUGIN_DIR}" --quiet; echo $?

    echo "installing ${PLUGIN_DIR}/${plugin_tempname}"
    $WORK_DIR/bin/elasticsearch-plugin install --batch "file://${PLUGIN_DIR}/${plugin_tempname}"

    echo "#################################################################################"
  fi
done

# List Plugins
echo "List available plugins"
ls -l $WORK_DIR/plugins

bash $WORK_DIR/plugins/opendistro_security/tools/install_demo_configuration.sh -y -i -s

# Making zip
echo "Generating zip"
zip -q -r $TARGET_DIR/opendistroforelasticsearch-$OD_VERSION-$PLATFORM-$ARCHITECTURE.zip $WORK_DIR
ls -l $TARGET_DIR

# Get exe buildtool
wget -nv https://download-gcdn.ej-technologies.com/install4j/install4j_unix_8_0_4.tar.gz
tar -xzf install4j_unix_8_0_4.tar.gz
aws s3 cp s3://$S3_RELEASE_BUCKET/odfe-windows/ODFE.install4j .
echo $?

# Build the exe
install4j8.0.4/bin/install4jc -d $TARGET_DIR -D sourcedir=./$WORK_DIR,version=$OD_VERSION --license=$install4j_license ./ODFE.install4j
mv -v $TARGET_DIR/*.exe $TARGET_DIR/opendistroforelasticsearch-$OD_VERSION-$PLATFORM-$ARCHITECTURE.exe

# List installed plugins
ls -l $TARGET_DIR

# Upload top S3
aws s3 cp $TARGET_DIR/*.exe ${S3_RELEASE_BASEURL}${OD_VERSION}/odfe/
aws s3 cp $TARGET_DIR/*.zip ${S3_RELEASE_BASEURL}${OD_VERSION}/odfe/
