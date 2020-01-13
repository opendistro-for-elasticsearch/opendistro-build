#!/bin/bash
mkdir ./ws #A temporary workspace inside opendistro-build/elasticsearch/linux_distributions
ES_VERSION=$(../bin/version-info --es)
OD_VERSION=$(../bin/version-info --od)
PACKAGE=opendistroforelasticsearch-kibana
ROOT=$(dirname "$0")/ws
TARGET_DIR="$ROOT/Windowsfiles"
 
#Downloading tar from s3
aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/tarball/opendistroforelasticsearch-kibana/$PACKAGE-$OD_VERSION.tar.gz $TARGET_DIR/
#Untar the tar artifact
tar -xzf $TARGET_DIR/$PACKAGE-$OD_VERSION.tar.gz --directory $TARGET_DIR
rm -rf $TARGET_DIR/*.tar.gz

#Download windowss oss for copying batch files
wget https://artifacts.elastic.co/downloads/kibana/kibana-oss-$ES_VERSION-windows-x86_64.zip -P $ROOT/
#Unzip the oss
unzip $ROOT/kibana-oss-$ES_VERSION-windows-x86_64.zip -d $ROOT
rm -rf $ROOT/kibana-oss-$ES_VERSION-windows-x86_64.zip
 
#Copy all the bat files in the bin directory and node.exe
BAT_FILES=`ls $ROOT/kibana-$ES_VERSION-windows-x86_64/bin/*.bat`
cp $BAT_FILES $TARGET_DIR/$PACKAGE-$OD_VERSION/bin
cp $ROOT/kibana-$ES_VERSION-windows-x86_64/node/node.exe $TARGET_DIR/$PACKAGE-$OD_VERSION/node
rm -rf $ROOT/kibana-oss-$ES_VERSION-windows-x86_64

#Download install4j software
wget https://download-gcdn.ej-technologies.com/install4j/install4j_unix_8_0_4.tar.gz -P $ROOT
#Untar
tar -xzf $ROOT/install4j_unix_8_0_4.tar.gz --directory $ROOT 
rm -rf $ROOT/*tar*

#Download the .install4j file from s3
aws s3 cp s3://odfe-windows/ODFE-Kibana.install4j $ROOT/
echo inside kibana/linux/ws
ls -ltr $ROOT
echo inside TARGET_DIR
ls -ltr $TARGET_DIR

#Build the exe
$ROOT/install4j*/bin/install4jc -d $TARGET_DIR/EXE -D sourcedir=$TARGET_DIR/$PACKAGE-$OD_VERSION,version=$OD_VERSION --license=L-M8-AMAZON_DEVELOPMENT_CENTER_INDIA_PVT_LTD#50047687020001-3rhvir3mkx479#484b6 $ROOT/ODFE-Kibana.install4j

#Copy to s3
aws s3 cp $TARGET_DIR/EXE/*.exe s3://odfe-windows/

rm -rf ws
