#!/usr/bin/env pwsh

# Keep the pwsh script running even with errors
#$ErrorActionPreference = 'SilentlyContinue'

# setup user parameters
$SETUP_ACTION=$args[0]
if (!$SETUP_ACTION) {
  echo "Please enter 1 parameter: --es | --es-nosec | --kibana | --kibana-nosec"
  exit 1
}

echo "############################################################"
echo "Setup ES/KIBANA to start with YES/NO security configurations"
echo "User enters $SETUP_ACTION"
echo "############################################################"

echo "setup es"
dir
python -m pip install --upgrade pip
echo pip3 -version
pip3 install awscli
$PACKAGE="opendistroforelasticsearch"
$OD_VERSION=$(python ./bin/version-info --od)
$S3_PACKAGE="odfe-"+$OD_VERSION+".zip"
dir

###############################################################

# everyone needs es
echo "downloading zip from S3"
aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/odfe-windows/staging/odfe-window-zip/$S3_PACKAGE . --quiet; echo $?\
echo "unzipping $S3_PACKAGE"
unzip -qq .\$S3_PACKAGE

if ($SETUP_ACTION -eq "--es"){
  echo "removing useless config" #deprecated since 7.8.0 and will crash --es-nosec now
  findstr /V "node.max_local_storage_nodes" .\$PACKAGE-$OD_VERSION\config\elasticsearch.yml > .\$PACKAGE-$OD_VERSION\config\elasticsearch.yml.new
  del .\$PACKAGE-$OD_VERSION\config\elasticsearch.yml
  move .\$PACKAGE-$OD_VERSION\config\elasticsearch.yml.new .\$PACKAGE-$OD_VERSION\config\elasticsearch.yml
  type .\$PACKAGE-$OD_VERSION\config\elasticsearch.yml

  echo "running es"
  nohup .\$PACKAGE-$OD_VERSION\bin\elasticsearch.bat &

  echo "Waiting for 60 seconds"
  ping -n 60 127.0.0.1 >.\out.txt
  curl -XGET https://localhost:9200 -u admin:admin --insecure

  echo "es start"
  exit 0
}

###############################################################

# *nosec remove es-security
if ($SETUP_ACTION -eq "--es-nosec" -Or $SETUP_ACTION -eq "--kibana-nosec"){
  echo "removing es security"
  cd $PACKAGE-$OD_VERSION\bin
  .\elasticsearch-plugin.bat remove opendistro_security
  cd ..\..

  echo "Overriding with elasticsearch.yml having no certificates"
  del .\$PACKAGE-$OD_VERSION\config\elasticsearch.yml
  aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/utils/elasticsearch.yml .\$PACKAGE-$OD_VERSION\config --quiet; echo $?
}

if ($SETUP_ACTION -eq "--es-nosec"){
  echo "running es"
  nohup .\$PACKAGE-$OD_VERSION\bin\elasticsearch.bat &

  echo "Waiting for 60 seconds"
  ping -n 60 127.0.0.1 >.\out.txt
  curl -XGET http://localhost:9200

  echo "es-nosec start"
  exit 0
}

###############################################################

# kibana* needs kibana
if ($SETUP_ACTION -eq "--kibana" -Or $SETUP_ACTION -eq "--kibana-nosec"){
  echo "setup kibana"
  mkdir kibana-it-test
  cd kibana-it-test
  $S3_KIBANA_PACKAGE="odfe-"+$OD_VERSION+"-kibana.zip"
  aws s3 cp --quiet s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/odfe-windows/ode-windows-zip/$S3_KIBANA_PACKAGE . --quiet; echo $?\
  unzip -qq .\$S3_KIBANA_PACKAGE
}

if ($SETUP_ACTION -eq "--kibana"){
  cd ..

  echo "running es"
  nohup .\$PACKAGE-$OD_VERSION\bin\elasticsearch.bat &

  echo "running kibana"
  cd kibana-it-test\opendistroforelasticsearch-kibana
  nohup .\bin\kibana.bat &
  cd ..\..

  echo "Waiting for 120 seconds"
  ping -n 120 127.0.0.1 >.\out.txt
  curl -XGET https://localhost:9200 -u admin:admin --insecure
  curl -v -XGET https://localhost:5601 --insecure

  echo "kibana start"
  exit 0
}

###############################################################

# kibana-nosec remove kibana-security
if ($SETUP_ACTION -eq "--kibana-nosec"){
  echo "removing kibana security"
  cd opendistroforelasticsearch-kibana
  .\bin\kibana-plugin.bat remove opendistro_security
  del .\config\kibana.yml
  aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/utils/kibana-config-without-security/kibana.yml .\config --quiet; echo $?

  cd ..\..

  echo "running es"
  nohup .\$PACKAGE-$OD_VERSION\bin\elasticsearch.bat &

  echo "running kibana"
  cd kibana-it-test\opendistroforelasticsearch-kibana
  nohup .\bin\kibana.bat &
  cd ..\..

  echo "Waiting for 120 seconds"
  ping -n 120 127.0.0.1 >.\out.txt
  curl -XGET http://localhost:9200
  curl -v -XGET http://localhost:5601

  echo "kibana-nosec start"
  exit 0
}

