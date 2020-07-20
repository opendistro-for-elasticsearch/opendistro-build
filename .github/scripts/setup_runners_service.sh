#!/bin/bash

echo "install required packages"
sudo yum install python37 git unzip wget -y

REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; cd $ROOT
OD_VERSION=`python $REPO_ROOT/bin/version-info --od`
SETUP_ACTION=$1

echo "############################################################"
echo "Setup ES/KIBANA to start with YES/NO security configurations"
echo "############################################################"

echo "setup parameters"
echo $JAVA_HOME
sudo curl https://d3g5vo6xdbdb9a.cloudfront.net/yum/staging-opendistroforelasticsearch-artifacts.repo  -o /etc/yum.repos.d/staging-opendistroforelasticsearch-artifacts.repo
export PATH=$PATH:$JAVA_HOME

#####################################################################################################

echo "install es"
sudo yum install opendistroforelasticsearch-$OD_VERSION -y
sudo mkdir -p /home/repo
sudo chmod 777 /home/repo
sudo chmod 777 /etc/elasticsearch/elasticsearch.yml
sudo sed -i '/path.logs/a path.repo: ["/home/repo"]' /etc/elasticsearch/elasticsearch.yml
sudo sed -i /^node.max_local_storage_nodes/d /etc/elasticsearch/elasticsearch.yml

if [ "$SETUP_ACTION" = "--es" ]
then
  sudo systemctl restart elasticsearch.service
  sleep 30
  exit 0
fi

#####################################################################################################

echo "remove es security"
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove opendistro_security
sudo sed -i /^opendistro_security/d /etc/elasticsearch/elasticsearch.yml
sudo sed -i /CN=kirk/d /etc/elasticsearch/elasticsearch.yml
sudo sed -i /^cluster.routing.allocation.disk.threshold_enabled/d /etc/elasticsearch/elasticsearch.yml

if [ "$SETUP_ACTION" = "--es-nosec" ]
then
  sudo systemctl restart elasticsearch.service
  sleep 30
  exit 0
fi

#####################################################################################################

echo "install kibana"
sudo yum install opendistroforelasticsearch-kibana-$OD_VERSION -y

if [ "$SETUP_ACTION" = "--kibana" ]
then
  sudo systemctl restart elasticsearch.service
  sudo systemctl restart kibana.service
  sleep 120
  exit 0
fi

#####################################################################################################

echo "remove kibana security"
sudo /usr/share/kibana/bin/kibana-plugin remove opendistro_security --allow-root
sudo sed -i /^opendistro_security/d /etc/kibana/kibana.yml
sudo sed -i 's/https/http/' /etc/kibana/kibana.yml

if [ "$SETUP_ACTION" = "--kibana-nosec" ]
then
  sudo systemctl restart elasticsearch.service
  sudo systemctl restart kibana.service
  sleep 120
  exit 0
fi

