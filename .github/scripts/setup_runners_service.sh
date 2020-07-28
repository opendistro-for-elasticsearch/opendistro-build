#!/bin/bash

###### Information ############################################################################
# Name:          setup_runners_service.sh
# Maintainer:    ODFE Infra Team
# Email:         odfe-infra@amazon.com
# Language:      Shell
#
# About:         Setup ES/KIBANA for integTests on *NIX based ODFE distros w/wo Security
#
# Usage:         ./setup_runners_service.sh $SETUP_DISTRO $SETUP_ACTION
#                $SETUP_DISTRO: tar | deb | rpm (required)
#                $SETUP_ACTION: --es | --es-nosec | --kibana | --kibana-nosec (required)
#
# Starting Date: 2020-07-27
# Modified Date: 2020-07-30
###############################################################################################

# This script allows users to manually assign parameters
if [ "$#" -ne 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please assign 2 parameters when running this script"
  echo "Example: $0 \$SETUP_DISTRO \$SETUP_ACTION"
  echo "Example: $0 \"tar | deb | rpm\" \"--es | --es-nosec | --kibana | --kibana-nosec\""
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

#####################################################################################################

echo "############################################################"
echo "Setup ES/KIBANA to start with YES/NO security configurations"
echo "User enters $SETUP_ACTION"
echo "############################################################"

echo "setup parameters"
echo $JAVA_HOME
export PATH=$PATH:$JAVA_HOME
sudo sysctl -w vm.max_map_count=262144

if [ "$SETUP_DISTRO" = "tar" ]
then
  mkdir -p odfe-testing
  cd odfe-testing
  aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/tarball/opendistro-elasticsearch/opendistroforelasticsearch-$OD_VERSION.tar.gz . --quiet; echo $?
  tar -zxf opendistroforelasticsearch-$OD_VERSION.tar.gz
  cd opendistroforelasticsearch-$OD_VERSION
fi

if [ "$SETUP_DISTRO" = "deb" ]
then
  sudo sudo apt install -y net-tools
  wget -qO - https://d3g5vo6xdbdb9a.cloudfront.net/GPG-KEY-opendistroforelasticsearch | sudo apt-key add -
  echo "deb https://d3g5vo6xdbdb9a.cloudfront.net/staging/apt stable main" | sudo tee -a /etc/apt/sources.list.d/opendistroforelasticsearch.list
  wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-amd64.deb
  sudo dpkg -i elasticsearch-oss-$ES_VERSION-amd64.deb
  sudo apt update -y
  sudo apt install -y opendistroforelasticsearch-$OD_VERSION
fi

if [ "$SETUP_DISTRO" = "rpm" ]
then
  sudo curl https://d3g5vo6xdbdb9a.cloudfront.net/yum/staging-opendistroforelasticsearch-artifacts.repo  -o /etc/yum.repos.d/staging-opendistroforelasticsearch-artifacts.repo
  sudo yum update
  sudo yum install opendistroforelasticsearch-$OD_VERSION -y
fi

#####################################################################################################

echo "setup es"

# everything needs es
if [ "$SETUP_DISTRO" = "tar" ]
then
  sed -i /install_demo_configuration/d opendistro-tar-install.sh
  sed -i '/http\.port/s/^# *//' config/elasticsearch.yml
  nohup ./opendistro-tar-install.sh &          
else
  sudo mkdir -p /home/repo
  sudo chmod 777 /home/repo
  sudo chmod 777 /etc/elasticsearch/elasticsearch.yml
  sudo sed -i '/path.logs/a path.repo: ["/home/repo"]' /etc/elasticsearch/elasticsearch.yml
  sudo sed -i /^node.max_local_storage_nodes/d /etc/elasticsearch/elasticsearch.yml
  sudo systemctl restart elasticsearch.service
fi

if [ "$SETUP_ACTION" = "--es" ]
then
  sleep 60
  curl -XGET https://localhost:9200 -u admin:admin --insecure
  echo "es start"
  cd $REPO_ROOT
  exit 0
fi

#####################################################################################################

# *nosec remove es-security
if [ "$SETUP_ACTION" = "--es-nosec" ] || [ "$SETUP_ACTION" = "--kibana-nosec" ]
then
  echo "remove es security"

  if [ "$SETUP_DISTRO" = "tar" ]
  then
    ./bin/elasticsearch-plugin remove opendistro_security
    nohup ./opendistro-tar-install.sh &          
  else
    sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove opendistro_security 
    sudo sed -i /^opendistro_security/d /etc/elasticsearch/elasticsearch.yml
    sudo sed -i /CN=kirk/d /etc/elasticsearch/elasticsearch.yml
    sudo sed -i /^cluster.routing.allocation.disk.threshold_enabled/d /etc/elasticsearch/elasticsearch.yml
    sudo systemctl restart elasticsearch.service
  fi
fi

if [ "$SETUP_ACTION" = "--es-nosec" ]
then
  sleep 60
  curl -XGET http://localhost:9200
  echo "es-nosec start"
  cd $REPO_ROOT
  exit 0
fi

#####################################################################################################

# kibana* needs kibana
if [ "$SETUP_ACTION" = "--kibana" ] || [ "$SETUP_ACTION" = "--kibana-nosec" ]
then
  echo "setup kibana"

  if [ "$SETUP_DISTRO" = "tar" ]
  then
    cd ../../
    mkdir -p kibana-testing
    cd kibana-testing
    aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/tarball/opendistroforelasticsearch-kibana/opendistroforelasticsearch-kibana-$odfe_version.tar.gz . --quiet; echo $?
    tar -zxf opendistroforelasticsearch-kibana-$odfe_version.tar.gz
    cd opendistroforelasticsearch-kibana
    sed -i /install_demo_configuration/d opendistro-tar-install.sh
    cd ../../odfe-testing
    nohup ./opendistro-tar-install.sh &
    cd ../../kibana-testing
    nohup ./bin/kibana &
  else
    sudo apt install opendistroforelasticsearch-kibana-$OD_VERSION -y || sudo yum install opendistroforelasticsearch-kibana-$OD_VERSION -y
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart kibana.service
  fi
fi

if [ "$SETUP_ACTION" = "--kibana" ]
then
  sleep 120
  curl -XGET https://localhost:9200 -u admin:admin --insecure
  curl -v -XGET https://localhost:5601 --insecure
  echo "es & kibana start"
  cd $REPO_ROOT
  exit 0
fi

#####################################################################################################

# kibana-nosec remove kibana-security
if [ "$SETUP_ACTION" = "--kibana-nosec" ]
then
  echo "remove kibana security"

  if [ "$SETUP_DISTRO" = "tar" ]
  then
    ./bin/kibana-plugin remove opendistro_security 
    sed -i /^opendistro_security/d ./config/kibana.yml
    sed -i 's/https/http/' ./config/kibana.yml
    cd ../../odfe-testing
    nohup ./opendistro-tar-install.sh &
    cd ../../kibana-testing
    nohup ./bin/kibana &
  else
    sudo /usr/share/kibana/bin/kibana-plugin remove opendistro_security --allow-root
    sudo sed -i /^opendistro_security/d /etc/kibana/kibana.yml
    sudo sed -i 's/https/http/' /etc/kibana/kibana.yml
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart kibana.service
  fi

    sleep 120
    curl -XGET http://localhost:9200
    curl -v -XGET http://localhost:5601
    echo "es & kibana-nosec start"
  cd $REPO_ROOT
    exit 0
fi

