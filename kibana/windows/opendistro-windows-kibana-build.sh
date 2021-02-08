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
PREBUILD_URL=`yq eval ".urls.KIBANA.${PLATFORM}_${ARCHITECTURE}" $MANIFEST_FILE`
PREBUILD_NAME=`basename $PREBUILD_URL`; echo PREBUILD_NAME $PREBUILD_NAME
PREBUILD_NAME_NOEXT=`echo $PREBUILD_NAME | sed 's/.zip//g'`
PACKAGE_NAME_PREBUILD=`echo $PREBUILD_NAME_NOEXT | sed 's/oss-//g'`
PACKAGE_NAME="opendistroforelasticsearch-kibana"

TARGET_DIR=$ROOT/target
PLUGIN_DIR=$ROOT/plugins

# Set rc build
if [ -z "$S3_RELEASE_FINAL_BUILD" ]
then
  S3_RELEASE_BUILD=`aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}" --query 'Contents[].[Key]' --output text | awk -F '/' '{print $3}' | uniq | tail -n 1`
  echo Latest: $S3_RELEASE_BUILD
else
  S3_RELEASE_BUILD=$S3_RELEASE_FINAL_BUILD
  echo Final: $S3_RELEASE_BUILD
fi

mkdir -p $TARGET_DIR
mkdir -p $PLUGIN_DIR

# Downloading tar from s3
# Kibana windows is based on linux tarball
aws s3 cp "${S3_RELEASE_BASEURL}${OD_VERSION}/odfe/${PACKAGE_NAME}-${OD_VERSION}-linux-${ARCHITECTURE}.tar.gz" . --quiet ; echo $0

# Untar the tar artifact
tar -xzf ${PACKAGE_NAME}-${OD_VERSION}-linux-${ARCHITECTURE}.tar.gz
rm -rf ${PACKAGE_NAME}-${OD_VERSION}-linux-${ARCHITECTURE}.tar.gz
ls -l

# Please DO NOT change the orders, they have dependencies
echo "Re-install Windows specific version of Kibana Plugins"
PLUGINS_ARRAY=( `${REPO_ROOT}/release-tools/scripts/plugins-info.sh kibana-plugins plugin_basename` )

for index in ${!PLUGINS_ARRAY[@]}
do
  plugin_latest=`(aws s3api list-objects --bucket $S3_RELEASE_BUCKET --prefix "${PLUGIN_PATH}${OD_VERSION}/${S3_RELEASE_BUILD}/kibana-plugins" --query 'Contents[].[Key]' --output text \
                 | grep -v sha512 | grep ${PLUGINS_ARRAY[$index]} | grep zip) || (echo None)`
  plugin_counts=`echo $plugin_latest | sed 's/.zip[ ]*/.zip\n/g' | sed '/^$/d' | wc -l`

  if [ "$plugin_counts" -gt 1 ]
  then
    plugin_latest=`echo $plugin_latest | sed 's/.zip[ ]*/.zip\n/g' | sed '/^$/d' | grep "$PLATFORM" | grep "$ARCHITECTURE"`
    if [ "$plugin_latest" != "None" ]
    then
      echo "downloading $plugin_latest"
      aws s3 cp "s3://${S3_RELEASE_BUCKET}/${plugin_latest}" "${PLUGIN_DIR}" --quiet; echo $?
      plugin_tempname=`echo $plugin_latest | awk -F '/' '{print $NF}'`
      plugin_foldername=`echo $plugin_tempname | awk -F '-' '{print $1}'`

      echo "removing $plugin_foldername"
      $PACKAGE_NAME/bin/kibana-plugin remove $plugin_foldername

      echo "installing $plugin_latest"
      $PACKAGE_NAME/bin/kibana-plugin --allow-root install "file://${PLUGIN_DIR}/${plugin_tempname}"
    fi
  fi

done

# List plugins
ls -l $PACKAGE_NAME/plugins

# Download windows oss for copying batch files
wget -nv $PREBUILD_URL

# Unzip the oss
unzip -q $PREBUILD_NAME
rm -rf $PREBUILD_NAME

# Copy all the bat files in the bin directory and node.exe
BAT_FILES=`ls $PACKAGE_NAME_PREBUILD/bin/*.bat`
cp -v $BAT_FILES $PACKAGE_NAME/bin
cp -v $PACKAGE_NAME_PREBUILD/node/node.exe $PACKAGE_NAME/node
rm -rf $PACKAGE_NAME_PREBUILD
ls -l

# Making zip
zip -q -r $TARGET_DIR/opendistroforelasticsearch-kibana-$OD_VERSION-$PLATFORM-$ARCHITECTURE.zip $PACKAGE_NAME
ls -l $TARGET_DIR

# Download install4j software
wget -nv https://download-gcdn.ej-technologies.com/install4j/install4j_unix_8_0_4.tar.gz

# Untar
tar -xzf install4j_unix_8_0_4.tar.gz
rm -rf install4j_unix_8_0_4.tar.gz

# Download the .install4j file from s3
aws s3 cp s3://${S3_RELEASE_BUCKET}/odfe-windows/ODFE-Kibana.install4j . --quiet ; echo $0

# Build the exe
install4j8.0.4/bin/install4jc -d $TARGET_DIR -D sourcedir=./$PACKAGE_NAME,version=$OD_VERSION --license=$install4j_license ./ODFE-Kibana.install4j
mv -v $TARGET_DIR/*.exe $TARGET_DIR/opendistroforelasticsearch-kibana-$OD_VERSION-$PLATFORM-$ARCHITECTURE.exe
ls -l $TARGET_DIR

# Copy to s3
aws s3 cp $TARGET_DIR/*.exe ${S3_RELEASE_BASEURL}${OD_VERSION}/odfe/
aws s3 cp $TARGET_DIR/*.zip ${S3_RELEASE_BASEURL}${OD_VERSION}/odfe/
