#!/bin/bash

set -e

###### Information ############################################################################
# Name:          setup_runners_service.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         Setup ES/KIBANA for integTests on *NIX based ODFE distros w/wo Security
#
# Usage:         ./setup_runners_service.sh $SETUP_DISTRO $SETUP_ACTION
#                $SETUP_DISTRO: zip | docker | deb | rpm (required)
#                $SETUP_ACTION: --es | --es-nosec | --kibana | --kibana-nosec (required)
#
# Requirements:  This script assumes java 14 is already installed on the servers
#
# Starting Date: 2020-07-27
# Modified Date: 2020-08-17
###############################################################################################

# This script allows users to manually assign parameters
if [ "$#" -ne 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please assign 2 parameters when running this script"
  echo "Example: $0 \$SETUP_DISTRO \$SETUP_ACTION"
  echo "Example: $0 \"zip | docker | deb | rpm\" \"--es | --es-nosec | --kibana | --kibana-nosec\""
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

DOCKER_NAME="Test-Docker-${OD_VERSION}"
DOCKER_NAME_KIBANA="Test-Docker-Kibana-${OD_VERSION}"
DOCKER_NAME_NoSec="Test-Docker-${OD_VERSION}-NoSec"
DOCKER_NAME_KIBANA_NoSec="Test-Docker-Kibana-${OD_VERSION}-NoSec"

S3_BUCKET="artifacts.opendistroforelasticsearch.amazon.com"

# Backoff in seconds, and number of attempts before assuming that Elasticsearch/Kibana failed to start
BACKOFF=10
MAX_ATTEMPTS=12

function wait_for_elasticsearch() {
    # Turn off fail-on-error because we expect curl to fail the first few attempts
    set +e
    echo "Waiting for Elasticsearch"
    for (( i = 1 ; i <= $MAX_ATTEMPTS ; i++ )); do
        echo "Waiting for Elasticsearch to start: attempt ${i}"
        if [ "$1" == "secure" ]; then
            output=`curl -XGET https://localhost:9200 -u admin:admin --insecure | grep -q "cluster_name"`
        else
            output=`curl -XGET http://localhost:9200 | grep -q "cluster_name"`
        fi
        if [ -n "$output" ]; then
            echo "Elasticsearch is running";
            set -e
            return
        fi
        sleep $BACKOFF
    done
    echo "Elasticsearch failed to start after $MAX_ATTEMPTS attempts"
    exit 1
}

function wait_for_kibana() {
    # Turn off fail-on-error because we expect curl to fail the first few attempts
    set +e
    echo "Waiting for Kibana"
    for (( i = 1 ; i <= $MAX_ATTEMPTS ; i++ )); do
        echo "Waiting for Kibana to start: attempt ${i}"
        output=`curl -XGET http://localhost:5601/api/status | grep "\"state\":\"green\""`
        if [ -n "$output" ]; then
            echo "Kibana is running";
            set -e
            return
        fi
        sleep $BACKOFF
    done
    echo "Kibana failed to start after $MAX_ATTEMPTS attempts"
    exit 1
}

#####################################################################################################

echo "############################################################"
echo "Setup ES/KIBANA to start with YES/NO security configurations"
echo "User enters ${SETUP_DISTRO}:${SETUP_ACTION}"
echo "############################################################"

echo "setup parameters"
echo $JAVA_HOME
export PATH=$JAVA_HOME:$PATH
which java
java -version
sudo sysctl -w vm.max_map_count=262144
sudo chmod -R 777 /dev/shm

if [ "$SETUP_DISTRO" = "zip" ]
then
  echo "Fetching $ES_PACKAGE_NAME.tar.gz from S3"
  mkdir -p $ES_ROOT
  aws s3 cp s3://$S3_BUCKET/downloads/tarball/opendistro-elasticsearch/$ES_PACKAGE_NAME.tar.gz . --quiet
  tar -zxf $ES_PACKAGE_NAME.tar.gz -C $ES_ROOT --strip-components 1
fi

if [ "$SETUP_DISTRO" = "docker" ]
then
  echo "setup docker"
  echo -n > Dockerfile
  echo -n > Dockerfile.kibana
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

echo "Installing Elasticsearch"

# everything needs es
if [ "$SETUP_DISTRO" = "zip" ]
then
  mkdir -p snapshots
  echo "path.repo: [\"$PWD/snapshots\"]" >> $ES_ROOT/config/elasticsearch.yml
  # Increase the number of allowed script compilations. The SQL integ tests use a lot of scripts.
  echo "script.context.field.max_compilations_rate: 1000/1m" >> $ES_ROOT/config/elasticsearch.yml
elif [ "$SETUP_DISTRO" = "docker" ]
then
  echo "FROM opendistroforelasticsearch/opendistroforelasticsearch:$OD_VERSION" >> Dockerfile
  echo "RUN echo ''  >> /usr/share/elasticsearch/config/elasticsearch.yml" >> Dockerfile
  echo "RUN echo \"path.repo: [\\\"/usr/share/elasticsearch\\\"]\" >> /usr/share/elasticsearch/config/elasticsearch.yml" >> Dockerfile
  # Increase the number of allowed script compilations. The SQL integ tests use a lot of scripts.
  echo "RUN echo \"script.context.field.max_compilations_rate: 1000/1m\" >> /usr/share/elasticsearch/config/elasticsearch.yml" >> Dockerfile
  docker build -t odfe-http:security -f Dockerfile .
  sleep 5
  docker run -d -p 9200:9200 -d -p 9600:9600 -e "discovery.type=single-node" --name $DOCKER_NAME odfe-http:security
  sleep 30
  echo "Temp Solution to remove the wrong configuration. need be fixed in building stage"
  docker exec -t $DOCKER_NAME /bin/bash -c "sed -i /^node.max_local_storage_nodes/d /usr/share/elasticsearch/config/elasticsearch.yml"
  docker stop $DOCKER_NAME
else
  sudo mkdir -p /home/repo
  sudo chmod 777 /home/repo
  sudo chmod 777 /etc/elasticsearch/elasticsearch.yml
  sudo sed -i '/path.logs/a path.repo: ["/home/repo"]' /etc/elasticsearch/elasticsearch.yml
  sudo sed -i /^node.max_local_storage_nodes/d /etc/elasticsearch/elasticsearch.yml
  # Increase the number of allowed script compilations. The SQL integ tests use a lot of scripts.
  echo "script.context.field.max_compilations_rate: 1000/1m" | sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null
fi

if [ "$SETUP_ACTION" = "--es" ]
then
  if [ "$SETUP_DISTRO" = "zip" ]
  then
    cd $ES_ROOT
    echo "Running opendistro-tar-install"
    nohup ./opendistro-tar-install.sh > /dev/null 2>&1 &
    sleep 30
    kill -9 `ps -ef | grep [e]lasticsearch | awk '{print $2}'`
    sed -i /^node.max_local_storage_nodes/d ./config/elasticsearch.yml
    echo "Running opendistro-tar-install again"
    nohup ./opendistro-tar-install.sh > /dev/null 2>&1 &
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    docker restart $DOCKER_NAME
    docker ps
  else
    sudo systemctl restart elasticsearch.service
  fi
  wait_for_elasticsearch secure
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
    sed -i /install_demo_configuration/d $ES_ROOT/opendistro-tar-install.sh
    $ES_ROOT/bin/elasticsearch-plugin remove opendistro_security
    sed -i '/http\.port/s/^# *//' $ES_ROOT/config/elasticsearch.yml
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    echo "RUN /usr/share/elasticsearch/bin/elasticsearch-plugin remove opendistro_security" >> Dockerfile
    docker build -t odfe-http:no-security -f Dockerfile .
    sleep 5
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
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    docker run -d -p 9200:9200 -d -p 9600:9600 -e "discovery.type=single-node" --name $DOCKER_NAME_NoSec odfe-http:no-security
    docker ps
  else
    sudo systemctl restart elasticsearch.service
  fi
  wait_for_elasticsearch
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
    tar -zxf $KIBANA_PACKAGE_NAME-$OD_VERSION.tar.gz -C $KIBANA_ROOT --strip-components 1
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    echo "FROM opendistroforelasticsearch/opendistroforelasticsearch-kibana:$OD_VERSION" >> Dockerfile.kibana
    docker build -t odfe-kibana-http:security -f Dockerfile.kibana .
    sleep 5
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
    sleep 30
    kill -9 `ps -ef | grep [e]lasticsearch | awk '{print $2}'`
    sed -i /^node.max_local_storage_nodes/d ./config/elasticsearch.yml
    nohup ./opendistro-tar-install.sh > /dev/null 2>&1 &
    cd $KIBANA_ROOT
    nohup ./bin/kibana > /dev/null 2>&1 &
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    docker restart $DOCKER_NAME
    docker run -d --name $DOCKER_NAME_KIBANA --network="host" odfe-kibana-http:security
    docker ps
  else
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart kibana.service
  fi
  wait_for_elasticsearch secure
  wait_for_kibana
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
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    echo "RUN /usr/share/kibana/bin/kibana-plugin remove opendistro_security" >> Dockerfile.kibana
    echo "RUN sed -i /^opendistro_security/d /usr/share/kibana/config/kibana.yml" >> Dockerfile.kibana
    echo "RUN sed -i 's/https/http/' /usr/share/kibana/config/kibana.yml" >> Dockerfile.kibana
    docker build -t odfe-kibana-http:no-security -f Dockerfile.kibana .
    sleep 5
    docker run -d -p 9200:9200 -d -p 9600:9600 -e "discovery.type=single-node" --name $DOCKER_NAME_NoSec odfe-http:no-security
    docker run -d --name $DOCKER_NAME_KIBANA_NoSec --network="host" odfe-kibana-http:no-security
    docker ps
  else
    sudo /usr/share/kibana/bin/kibana-plugin remove opendistro_security --allow-root
    sudo sed -i /^opendistro_security/d /etc/kibana/kibana.yml
    sudo sed -i 's/https/http/' /etc/kibana/kibana.yml
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart kibana.service
  fi
  wait_for_elasticsearch
  wait_for_kibana
  cd $REPO_ROOT
  exit 0
fi

