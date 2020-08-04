#!/bin/bash

###### Information ############################################################################
# Name:          setup_runners_service.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         Setup ES/KIBANA for integTests on *NIX based ODFE distros w/wo Security
#
# Usage:         ./setup_runners_service.sh $SETUP_DISTRO $SETUP_ACTION
#                $SETUP_DISTRO: zip | deb | rpm (required)
#                $SETUP_ACTION: --es | --es-nosec | --kibana | --kibana-nosec (required)
#
# Requirements:  This script assumes java 14 is already installed on the servers
#
# Starting Date: 2020-07-27
# Modified Date: 2020-08-02
###############################################################################################

# This script allows users to manually assign parameters
if [ "$#" -ne 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please assign 2 parameters when running this script"
  echo "Example: $0 \$SETUP_DISTRO \$SETUP_ACTION"
  echo "Example: $0 \"zip | deb | rpm\" \"--es | --es-nosec | --kibana | --kibana-nosec\""
  exit 1
fi

SETUP_DISTRO=$1
SETUP_ACTION=$2
SETUP_PACKAGES="python3 git unzip wget jq"

echo "install required packages"
sudo apt install $SETUP_PACKAGES -y || sudo yum install $SETUP_PACKAGES -y

REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; cd $ROOT
OD_VERSION=`python $REPO_ROOT/bin/version-info --od`
ES_VERSION=`python $REPO_ROOT/bin/version-info --es`

ES_PACKAGE_NAME="opendistroforelasticsearch-${OD_VERSION}"
ES_ROOT="${ROOT}/odfe-testing/${ES_PACKAGE_NAME}"
KIBANA_PACKAGE_NAME="opendistroforelasticsearch-kibana"
KIBANA_ROOT="${ROOT}/kibana-testing/${KIBANA_PACKAGE_NAME}"

S3_BUCKET="artifacts.opendistroforelasticsearch.amazon.com"

#####################################################################################################

echo "############################################################"
echo "Setup ES/KIBANA to start with YES/NO security configurations"
echo "User enters $SETUP_ACTION"
echo "############################################################"

echo "setup parameters"
echo $JAVA_HOME
export PATH=$JAVA_HOME:$PATH
which java
java -version
sudo sysctl -w vm.max_map_count=262144

if [ "$SETUP_DISTRO" = "zip" ]
then
  mkdir -p $ES_ROOT
  aws s3 cp s3://$S3_BUCKET/downloads/tarball/opendistro-elasticsearch/$ES_PACKAGE_NAME.tar.gz . --quiet; echo $?
  tar -zxf $ES_PACKAGE_NAME.tar.gz -C $ES_ROOT --strip 1
fi

if [ "$SETUP_DISTRO" = "deb" ]
then
  sudo add-apt-repository ppa:openjdk-r/ppa
  sudo apt update
  sudo sudo apt install -y net-tools
  wget -qO - https://d3g5vo6xdbdb9a.cloudfront.net/GPG-KEY-opendistroforelasticsearch | sudo apt-key add -
  echo "deb https://d3g5vo6xdbdb9a.cloudfront.net/staging/apt stable main" | sudo tee -a /etc/apt/sources.list.d/opendistroforelasticsearch.list
  wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-amd64.deb
  sudo dpkg -i elasticsearch-oss-$ES_VERSION-amd64.deb
  sudo apt update -y
  sudo apt install -y opendistroforelasticsearch=$OD_VERSION*
fi

if [ "$SETUP_DISTRO" = "rpm" ]
then
  sudo curl https://d3g5vo6xdbdb9a.cloudfront.net/yum/staging-opendistroforelasticsearch-artifacts.repo  -o /etc/yum.repos.d/staging-opendistroforelasticsearch-artifacts.repo
  sudo yum update
  sudo yum install $ES_PACKAGE_NAME -y
fi

#####################################################################################################

echo "setup es"

# everything needs es
if [ "$SETUP_DISTRO" = "zip" ]
then
  sed -i /install_demo_configuration/d $ES_ROOT/opendistro-tar-install.sh
  sed -i /^node.max_local_storage_nodes/d $ES_ROOT/config/elasticsearch.yml
  mkdir -p snapshots
  echo "path.repo: [\"$PWD/snapshots\"]" >> $ES_ROOT/config/elasticsearch.yml
else
  sudo mkdir -p /home/repo
  sudo chmod 777 /home/repo
  sudo chmod 777 /etc/elasticsearch/elasticsearch.yml
  sudo sed -i '/path.logs/a path.repo: ["/home/repo"]' /etc/elasticsearch/elasticsearch.yml
  sudo sed -i /^node.max_local_storage_nodes/d /etc/elasticsearch/elasticsearch.yml
fi

if [ "$SETUP_ACTION" = "--es" ]
then
  if [ "$SETUP_DISTRO" = "zip" ]
  then
    cd $ES_ROOT
    nohup ./opendistro-tar-install.sh > /dev/null 2>&1 &
  else
    sudo systemctl restart elasticsearch.service
  fi
  echo "Sleep 120 seconds"
  sleep 120
  curl -XGET https://localhost:9200 -u admin:admin --insecure
  curl -XGET https://localhost:9200/_cluster/health?pretty -u admin:admin --insecure
  echo "es start"
  cd $REPO_ROOT
  exit 0
fi

#####################################################################################################

# *nosec remove es-security
if [ "$SETUP_ACTION" = "--es-nosec" ] || [ "$SETUP_ACTION" = "--kibana-nosec" ]
then
  echo "remove es security"

  if [ "$SETUP_DISTRO" = "zip" ]
  then
    $ES_ROOT/bin/elasticsearch-plugin remove opendistro_security
    sed -i '/http\.port/s/^# *//' $ES_ROOT/config/elasticsearch.yml
  else
    sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove opendistro_security 
    sudo sed -i '/http\.port/s/^# *//' /etc/elasticsearch/elasticsearch.yml
    sudo sed -i /^opendistro_security/d /etc/elasticsearch/elasticsearch.yml
    sudo sed -i /CN=kirk/d /etc/elasticsearch/elasticsearch.yml
    sudo sed -i /^cluster.routing.allocation.disk.threshold_enabled/d /etc/elasticsearch/elasticsearch.yml
  fi
fi

if [ "$SETUP_ACTION" = "--es-nosec" ]
then
  if [ "$SETUP_DISTRO" = "zip" ]
  then
    cd $ES_ROOT
    nohup ./opendistro-tar-install.sh > /dev/null 2>&1 &
  else
    sudo systemctl restart elasticsearch.service
  fi
  echo "Sleep 120 seconds"
  sleep 120
  curl -XGET http://localhost:9200
  curl -XGET http://localhost:9200/_cluster/health?pretty
  echo "es-nosec start"
  cd $REPO_ROOT
  exit 0
fi

#####################################################################################################

# kibana* needs kibana
if [ "$SETUP_ACTION" = "--kibana" ] || [ "$SETUP_ACTION" = "--kibana-nosec" ]
then
  echo "setup kibana"

  if [ "$SETUP_DISTRO" = "zip" ]
  then
    mkdir -p $KIBANA_ROOT
    aws s3 cp s3://$S3_BUCKET/downloads/tarball/$KIBANA_PACKAGE_NAME/$KIBANA_PACKAGE_NAME-$OD_VERSION.tar.gz . --quiet; echo $?
    tar -zxf $KIBANA_PACKAGE_NAME-$OD_VERSION.tar.gz -C $KIBANA_ROOT --strip 1
  else
    sudo apt install $KIBANA_PACKAGE_NAME=$OD_VERSION* -y || sudo yum install $KIBANA_PACKAGE_NAME-$OD_VERSION -y
  fi
fi

if [ "$SETUP_ACTION" = "--kibana" ]
then
  if [ "$SETUP_DISTRO" = "zip" ]
  then
    cd $ES_ROOT
    nohup ./opendistro-tar-install.sh > /dev/null 2>&1 &
    cd $KIBANA_ROOT
    nohup ./bin/kibana > /dev/null 2>&1 &
  else
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart kibana.service
  fi
  echo "Sleep 120 seconds"
  sleep 120
  curl -XGET https://localhost:9200 -u admin:admin --insecure
  curl -XGET https://localhost:9200/_cluster/health?pretty -u admin:admin --insecure
  curl -v -XGET https://localhost:5601 --insecure
  curl -v -XGET https://localhost:5601/api/status --insecure
  echo "es & kibana start"
  cd $REPO_ROOT
  exit 0
fi

#####################################################################################################

# kibana-nosec remove kibana-security
if [ "$SETUP_ACTION" = "--kibana-nosec" ]
then
  echo "remove kibana security"

  if [ "$SETUP_DISTRO" = "zip" ]
  then
    $KIBANA_ROOT/bin/kibana-plugin remove opendistro_security 
    sed -i /^opendistro_security/d $KIBANA_ROOT/config/kibana.yml
    sed -i 's/https/http/' $KIBANA_ROOT/config/kibana.yml

    cd $ES_ROOT
    nohup ./opendistro-tar-install.sh > /dev/null 2>&1 &
    cd $KIBANA_ROOT
    nohup ./bin/kibana > /dev/null 2>&1 &
  else
    sudo /usr/share/kibana/bin/kibana-plugin remove opendistro_security --allow-root
    sudo sed -i /^opendistro_security/d /etc/kibana/kibana.yml
    sudo sed -i 's/https/http/' /etc/kibana/kibana.yml
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart kibana.service
  fi
  echo "Sleep 120 seconds"
  sleep 120
  curl -XGET http://localhost:9200
  curl -XGET http://localhost:9200/_cluster/health?pretty
  curl -v -XGET http://localhost:5601
  curl -v -XGET http://localhost:5601/api/status
  echo "es & kibana-nosec start"
  cd $REPO_ROOT
  exit 0
fi

