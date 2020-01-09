ES_VERSION=$(../bin/version-info --es)
OD_VERSION=$(../bin/version-info --od)
OD_PLUGINVERSION=$OD_VERSION.0
PACKAGE=opendistroforelasticsearch
ROOT=$(dirname "$0")

TARGET_DIR="$ROOT/tarfiles"
#Untar the built tar artifact
tar -vxzf $TARGET_DIR/$PACKAGE-$OD_VERSION.tar.gz

#Download windowss oss for copying batch files
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$OD_VERSION-windows-x86_64.zip
#Unzip the oss
unzip elasticsearch-oss-$OD_VERSION-windows-x86_64.zip
rm -rf elasticsearch-oss-$OD_VERSION-windows-x86_64.zip

#Copy all the bat files in the bin directory
BAT_FILES=`ls ./elasticsearch-oss-$OD_VERSION-windows-x86_64/bin/*.bat`
cp BAT_FILES $TARGET_DIR/$PACKAGE-$OD_VERSION/bin
rm -rf ./elasticsearch-oss-$OD_VERSION-windows-x86_64

#Download install4j software
wget https://download-gcdn.ej-technologies.com/install4j/install4j_unix_4_2_8.tar.gz
#Untar
tar -xzf install4j_unix_4_2_8.tar.gz

#Download the .install4j file from s3
aws s3 cp s3://odfe-windows/ODFE.install4j ./

#build the exe using install4jc
./install4j/bin/install4jc -d ./EXE -D sourcedir=./$PACKAGE-$OD_VERSION,version=$OD_VERSION --license=L-M8-AMAZON_DEVELOPMENT_CENTER_INDIA_PVT_LTD#50047687020001-3rhvir3mkx479#484b6 ./ODFE.install4j
 
 #Copy to s3
 aws s3 cp ./EXE/*.exe s3://odfe-windows/
