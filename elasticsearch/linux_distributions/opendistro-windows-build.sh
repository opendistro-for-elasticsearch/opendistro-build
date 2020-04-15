#!/bin/bash
mkdir ./ws #A temporary workspace inside opendistro-build/elasticsearch/linux_distributions
ES_VERSION=$(../bin/version-info --es)
OD_VERSION=$(../bin/version-info --od)
OD_PLUGINVERSION=$OD_VERSION.0
PACKAGE=opendistroforelasticsearch
ROOT=$(dirname "$0")/ws
TARGET_DIR="$ROOT/Windowsfiles"

#Download windowss oss for copying batch files
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip -P $ROOT/
if [ "$?" -eq "1" ]
then
  echo "OSS not available"
  exit 1
fi

#Unzip the oss
unzip $ROOT/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip -d $ROOT
rm -rf $ROOT/elasticsearch-oss-$ES_VERSION-windows-x86_64.zip

#Install plugins
for plugin_path in  opendistro-sql/opendistro_sql-$OD_PLUGINVERSION.zip opendistro-alerting/opendistro_alerting-$OD_PLUGINVERSION.zip opendistro-job-scheduler/opendistro-job-scheduler-$OD_PLUGINVERSION.zip opendistro-security/opendistro_security-$OD_PLUGINVERSION.zip opendistro-index-management/opendistro_index_management-$OD_PLUGINVERSION.zip
do
  $ROOT/elasticsearch-$ES_VERSION/bin/elasticsearch-plugin install --batch "https://d3g5vo6xdbdb9a.cloudfront.net/downloads/elasticsearch-plugins/$plugin_path"
done

mv $ROOT/elasticsearch-$ES_VERSION $ROOT/$PACKAGE-$OD_VERSION
cd $ROOT
#Making zip
zip -r odfe-$OD_VERSION.zip $PACKAGE-$OD_VERSION

##Build Exe
wget https://download-gcdn.ej-technologies.com/install4j/install4j_unix_8_0_4.tar.gz
tar -xzf install4j_unix_8_0_4.tar.gz
aws s3 cp s3://odfe-windows/ODFE.install4j .
if [ "$?" -eq "1" ]
then
  echo "Install4j not available"
  exit 1
fi
pwd

#Build the exe
install4j8.0.4/bin/install4jc -d EXE -D sourcedir=./$PACKAGE-$OD_VERSION,version=$OD_VERSION --license="L-M8-AMAZON_DEVELOPMENT_CENTER_INDIA_PVT_LTD#50047687020001-3rhvir3mkx479#484b6" ./ODFE.install4j

#upload top S3
aws s3 cp EXE/*.exe s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/odfe-windows/staging/odfe-executable/
aws s3 cp odfe-$OD_VERSION.zip s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/odfe-windows/staging/odfe-window-zip/
aws cloudfront create-invalidation --distribution-id E1VG5HMIWI4SA2 --paths "/downloads/*"
