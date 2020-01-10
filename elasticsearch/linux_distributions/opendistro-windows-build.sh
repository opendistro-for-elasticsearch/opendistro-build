#!/bin/bash

ES_VERSION=$(../bin/version-info --es)
OD_VERSION=$(../bin/version-info --od)
PACKAGE=opendistroforelasticsearch
ROOT=$(dirname "$0")
TARGET_DIR="$ROOT/Windowsfiles"

#Downloading tar from s3
aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/tarball/opendistro-elasticsearch/$PACKAGE-$OD_VERSION.tar.gz $TARGET_DIR/
#Untar the tar artifact
tar -xzf $TARGET_DIR/$PACKAGE-$OD_VERSION.tar.gz --directory $TARGET_DIR
rm -rf $TARGET_DIR/*.tar.gz

#Download windowss oss for copying batch files
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip -P $ROOT/
#Unzip the oss
unzip $ROOT/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip
rm -rf $ROOT/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip

#Copy all the bat files in the bin directory
BAT_FILES=`ls $ROOT/elasticsearch-$ES_VERSION/bin/*.bat`
cp $BAT_FILES $TARGET_DIR/$PACKAGE-$OD_VERSION/bin
rm -rf $ROOT/elasticsearch-oss-$ES_VERSION-windows-x86_64

#Download install4j software
wget https://download-gcdn.ej-technologies.com/install4j/install4j_unix_8_0_4.tar.gz -P $ROOT
#Untar
tar -xzf $ROOT/install4j_unix_8_0_4.tar.gz --directory $ROOT 
rm -rf $ROOT/*tar*



#Download the .install4j file from s3
aws s3 cp s3://odfe-windows/ODFE.install4j $ROOT/

echo root after downloading default install4j file
ls -ltr $ROOT
#build the exe using install4jc
#sudo apt install default-jre
#INSTALL4J_JAVA_HOME="/usr/lib/jvm/open-jdk"
#export JAVA_HOME=../../openjdk12
cd ./install4j*/bin/
./install4jc -d $TARGET_DIR/EXE -D sourcedir=$TARGET_DIR/$PACKAGE-$OD_VERSION,version=$OD_VERSION --license=L-M8-AMAZON_DEVELOPMENT_CENTER_INDIA_PVT_LTD#50047687020001-3rhvir3mkx479#484b6 ./ODFE.install4j

echo after exe build
echo TAR_DIR is
ls -ltr $TARGET_DIR
echo EXE DIR is
ls -ltr $TARGET_DIR/EXE
#Copy to s3
aws s3 cp $TARGET_DIR/EXE/*.exe s3://odfe-windows/
