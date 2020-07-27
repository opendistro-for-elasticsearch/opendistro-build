#!/bin/bash

# This script allows users to manually assign parameters
if [ "$#" -ne 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please assign a2 parameters when running this script"
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
echo "############################################################"

echo "setup parameters"
echo $JAVA_HOME
export PATH=$PATH:$JAVA_HOME
sudo sysctl -w vm.max_map_count=262144

if [ "$SETUP_DISTRO" = "tar" ]
then
  mkdir -p odfe-testing
  cd odfe-testing
  aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/tarball/opendistro-elasticsearch/opendistroforelasticsearch-$OD_VERSION.tar.gz .
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
if [ "$SETUP_DISTRO" = "tar" ]
then
  sed -i /install_demo_configuration/d opendistro-tar-install.sh
  sed -i '/http\.port/s/^# *//' config/elasticsearch.yml
else
  sudo mkdir -p /home/repo
  sudo chmod 777 /home/repo
  sudo chmod 777 /etc/elasticsearch/elasticsearch.yml
  sudo sed -i '/path.logs/a path.repo: ["/home/repo"]' /etc/elasticsearch/elasticsearch.yml
  sudo sed -i /^node.max_local_storage_nodes/d /etc/elasticsearch/elasticsearch.yml
fi

if [ "$SETUP_ACTION" = "--es" ]
then
  if [ "$SETUP_DISTRO" = "tar" ]
  then
    nohup ./opendistro-tar-install.sh &          
    sleep 45
    exit 0
  else
    sudo systemctl restart elasticsearch.service
    sleep 30
    exit 0
  fi
fi

#####################################################################################################

echo "remove es security"
if [ "$SETUP_DISTRO" = "tar" ]
then
  ./bin/elasticsearch-plugin remove opendistro_security
else
  sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove opendistro_security 
  sudo sed -i /^opendistro_security/d /etc/elasticsearch/elasticsearch.yml
  sudo sed -i /CN=kirk/d /etc/elasticsearch/elasticsearch.yml
  sudo sed -i /^cluster.routing.allocation.disk.threshold_enabled/d /etc/elasticsearch/elasticsearch.yml
fi

if [ "$SETUP_ACTION" = "--es-nosec" ]
then
  if [ "$SETUP_DISTRO" = "tar" ]
  then
    nohup ./opendistro-tar-install.sh &          
    sleep 45
    exit 0
  else
    sudo systemctl restart elasticsearch.service
    sleep 30
    exit 0
  fi
fi

#####################################################################################################

echo "setup kibana"
if [ "$SETUP_DISTRO" = "tar" ]
then
  cd ../../
  mkdir -p kibana-testing
  cd kibana-testing
  aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/tarball/opendistroforelasticsearch-kibana/opendistroforelasticsearch-kibana-$odfe_version.tar.gz .
  tar -zxf opendistroforelasticsearch-kibana-$odfe_version.tar.gz
  cd opendistroforelasticsearch-kibana
  sed -i /install_demo_configuration/d opendistro-tar-install.sh
else
  sudo apt install opendistroforelasticsearch-kibana-$OD_VERSION -y || sudo yum install opendistroforelasticsearch-kibana-$OD_VERSION -y
fi

if [ "$SETUP_ACTION" = "--kibana" ]
then
  if [ "$SETUP_DISTRO" = "tar" ]
  then
    cd ../../odfe-testing
    nohup ./opendistro-tar-install.sh &
    sleep 45
    cd ../../kibana-testing
    nohup ./bin/kibana &
    sleep 120
    exit 0
  else
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart kibana.service
    sleep 120
    exit 0
  fi
fi

#####################################################################################################

echo "remove kibana security"
if [ "$SETUP_DISTRO" = "tar" ]
then
  ./bin/kibana-plugin remove opendistro_security 
  sed -i /^opendistro_security/d ./config/kibana.yml
  sed -i 's/https/http/' ./config/kibana.yml
else
  sudo /usr/share/kibana/bin/kibana-plugin remove opendistro_security --allow-root
  sudo sed -i /^opendistro_security/d /etc/kibana/kibana.yml
  sudo sed -i 's/https/http/' /etc/kibana/kibana.yml
fi

if [ "$SETUP_ACTION" = "--kibana-nosec" ]
then
  if [ "$SETUP_DISTRO" = "tar" ]
  then
    cd ../../odfe-testing
    nohup ./opendistro-tar-install.sh &
    sleep 45
    cd ../../kibana-testing
    nohup ./bin/kibana &
    sleep 120
    exit 0
  else
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart kibana.service
    sleep 120
    exit 0
  fi
fi

