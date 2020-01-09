#!/bin/bash

ES_VERSION=$(../bin/version-info --es)
OD_VERSION=$(../bin/version-info --od)
echo "$ES_VERSION"
echo "$OD_VERSION"
#OD_PLUGINVERSION=$OD_VERSION.0
PACKAGE=opendistroforelasticsearch
ROOT=$(dirname "$0")

TARGET_DIR="$ROOT/Windowsfiles"

#Downloading tar from s3
aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/tarball/opendistro-elasticsearch/$PACKAGE-$OD_VERSION.tar.gz $TARGET_DIR/
echo after downloading tar to TARGET_DIR
ls -ltr $TARGET_DIR
#Untar the built tar artifact
tar -xzf $TARGET_DIR/$PACKAGE-$OD_VERSION.tar.gz --directory $TARGET_DIR
rm -rf $TARGET_DIR/*.tar.gz
echo content after untarring inside TARGET_DIR
ls -ltr $TARGET_DIR

#Download windowss oss for copying batch files
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip -P $ROOT/
#Unzip the oss
unzip $ROOT/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip
rm -rf $ROOT/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip
echo inside ROOT 
ls -ltr $ROOT
#Copy all the bat files in the bin directory
BAT_FILES=`ls $ROOT/elasticsearch-$ES_VERSION/bin/*.bat`
cp $BAT_FILES $TARGET_DIR/$PACKAGE-$OD_VERSION/bin
#ls -ltr $TARGET_DIR/$PACKAGE-$OD_VERSION/bin
rm -rf $ROOT/elasticsearch-oss-$ES_VERSION-windows-x86_64
echo inside bin of es
ls -ltr $TARGET_DIR/$PACKAGE-$OD_VERSION/bin
#Download install4j software
wget https://download-gcdn.ej-technologies.com/install4j/install4j_unix_4_2_8.tar.gz -P $ROOT
#Untar
tar -xzf $ROOT/install4j_unix_4_2_8.tar.gz
rm -rf $ROOT/install4j_unix_4_2_8.tar.gz

#Download the .install4j file from s3
aws s3 cp s3://odfe-windows/ODFE.install4j $ROOT/

#build the exe using install4jc
$ROOT/install4j/bin/install4jc -d $TARGET_DIR/EXE -D sourcedir=$TARGET_DIR/$PACKAGE-$OD_VERSION,version=$OD_VERSION --license=L-M8-AMAZON_DEVELOPMENT_CENTER_INDIA_PVT_LTD#50047687020001-3rhvir3mkx479#484b6 ./ODFE.install4j
 
 #Copy to s3
 aws s3 cp $TARGET_DIR/EXE/*.exe s3://odfe-windows/
