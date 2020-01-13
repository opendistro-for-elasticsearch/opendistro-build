#!/bin/bash
mkdir ./ws 
ES_VERSION=$(../bin/version-info --es)
OD_VERSION=$(../bin/version-info --od)
PACKAGE=opendistroforelasticsearch
ROOT=$(dirname "$0")/ws
TARGET_DIR="$ROOT/Windowsfiles"

#Downloading tar from s3
aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/tarball/opendistro-elasticsearch/$PACKAGE-$OD_VERSION.tar.gz $TARGET_DIR/
#Untar the tar artifact
tar -xzf $TARGET_DIR/$PACKAGE-$OD_VERSION.tar.gz --directory $TARGET_DIR
rm -rf $TARGET_DIR/*.tar.gz

#Remove PA plugin as it isn't provided for odfe-1.3.0 windows
rm -rf $TARGET_DIR/$PACKAGE-$OD_VERSION/plugins/opendistro_performance_analyzer

#install the certificates
sudo sh $TARGET_DIR/$PACKAGE-$OD_VERSION/plugins/opendistro_security/tools/install_demo_configuration.sh -y -i -s

#Download windowss oss for copying batch files
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip -P $ROOT/
#Unzip the oss
unzip $ROOT/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip -d $ROOT
rm -rf $ROOT/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip
echo after unzipping
ls -ltr $ROOT/

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

#Build the exe
$ROOT/install4j*/bin/install4jc -d $TARGET_DIR/EXE -D sourcedir=$TARGET_DIR/$PACKAGE-$OD_VERSION,version=$OD_VERSION --license=L-M8-AMAZON_DEVELOPMENT_CENTER_INDIA_PVT_LTD#50047687020001-3rhvir3mkx479#484b6 $ROOT/ODFE.install4j

#Copy to s3
aws s3 cp $TARGET_DIR/EXE/*.exe s3://odfe-windows/

rm -rf ws
