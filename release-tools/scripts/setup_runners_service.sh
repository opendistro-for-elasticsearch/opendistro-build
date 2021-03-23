#!/bin/bash

###### Information ############################################################################
# Name:          setup_runners_service.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         Setup ES/KIBANA for integTests on *NIX based ODFE distros w/wo Security
#
# Usage:         ./setup_runners_service.sh $SETUP_DISTRO $SETUP_ACTION $ARCHITECTURE
#                $SETUP_DISTRO: zip | docker | deb | rpm (required)
#                $SETUP_ACTION: --es | --es-nosec | --kibana | --kibana-nosec (required)
#                $ARCHITECTURE: arm64 (optional)
#
# Requirements:  This script assumes java 14 is already installed on the servers
#
# Starting Date: 2020-07-27
# Modified Date: 2021-01-06
###############################################################################################

# This script allows users to manually assign parameters
if [ "$#" -lt 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please assign atleast 2 parameters when running this script"
  echo "Example: $0 \$SETUP_DISTRO \$SETUP_ACTION \$ARCHITECTURE (optional)"
  echo "Example: $0 \"zip | docker | deb | rpm\" \"--es | --es-nosec | --kibana | --kibana-nosec \" \"arm64 (optional)\""
  exit 1
fi

SETUP_DISTRO=$1
SETUP_ACTION=$2
ARCHITECTURE="x64"; if [ ! -z "$3" ]; then ARCHITECTURE=$3; fi; echo ARCHITECTURE $ARCHITECTURE
SETUP_PACKAGES="python3 git unzip wget jq"
if [ "$ARCHITECTURE" = "x64" ]
then
  ARCHITECTURE_ALT="amd64"
elif [ "$ARCHITECTURE" = "arm64" ]
then
  ARCHITECTURE_ALT="arm64"
else
  echo "Your server is not supported for now"
  exit 1
fi

echo "install required packages"
sudo apt install $SETUP_PACKAGES -y || sudo yum install $SETUP_PACKAGES -y

REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; cd $ROOT
ES_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --es`; echo ES_VERSION: $ES_VERSION
OD_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --od`; echo OD_VERSION: $OD_VERSION
MANIFEST_FILE=$REPO_ROOT/release-tools/scripts/manifest.yml

ES_PACKAGE_NAME="opendistroforelasticsearch-${OD_VERSION}"
ES_ROOT="${ROOT}/odfe-testing/${ES_PACKAGE_NAME}"
KIBANA_PACKAGE_NAME="opendistroforelasticsearch-kibana"
KIBANA_ROOT="${ROOT}/kibana-testing/${KIBANA_PACKAGE_NAME}"

DOCKER_NAME="Test-Docker-${OD_VERSION}"
DOCKER_NAME_KIBANA="Test-Docker-Kibana-${OD_VERSION}"
DOCKER_NAME_NoSec="Test-Docker-${OD_VERSION}-NoSec"
DOCKER_NAME_KIBANA_NoSec="Test-Docker-Kibana-${OD_VERSION}-NoSec"

S3_RELEASE_BASEURL=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE`
S3_RELEASE_FINAL_BUILD=`yq eval '.urls.ODFE.releases_final_build' $MANIFEST_FILE | sed 's/\///g'`
S3_RELEASE_BUCKET=`echo $S3_RELEASE_BASEURL | awk -F '/' '{print $3}'`
PLUGIN_PATH=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE | sed "s/^.*$S3_RELEASE_BUCKET\///g"`

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
  mkdir -p $ES_ROOT
  aws s3 cp s3://$S3_RELEASE_BUCKET/${PLUGIN_PATH}${OD_VERSION}/odfe/$ES_PACKAGE_NAME-linux-$ARCHITECTURE.tar.gz . --quiet; echo $?
  tar -zxf $ES_PACKAGE_NAME-linux-$ARCHITECTURE.tar.gz -C $ES_ROOT --strip-components 1
fi

if [ "$SETUP_DISTRO" = "docker" ]
then
  echo "setup docker"
  echo -n > Dockerfile
  echo -n > Dockerfile.kibana
fi

if [ "$SETUP_DISTRO" = "deb" ]
then
  sudo add-apt-repository ppa:openjdk-r/ppa -y
  sudo apt update -y
  sudo sudo apt install -y net-tools
  wget -qO - https://d3g5vo6xdbdb9a.cloudfront.net/GPG-KEY-opendistroforelasticsearch | sudo apt-key add -
  echo "deb https://d3g5vo6xdbdb9a.cloudfront.net/staging/apt stable main" | sudo tee -a /etc/apt/sources.list.d/opendistroforelasticsearch.list
  wget -nv https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-$ARCHITECTURE_ALT.deb
  sudo dpkg -i elasticsearch-oss-$ES_VERSION-$ARCHITECTURE_ALT.deb
  sudo apt update -y
  sudo apt install -y opendistroforelasticsearch=$OD_VERSION*
fi

if [ "$SETUP_DISTRO" = "rpm" ]
then
  sudo curl https://d3g5vo6xdbdb9a.cloudfront.net/staging/yum/staging-opendistroforelasticsearch-artifacts.repo  -o /etc/yum.repos.d/staging-opendistroforelasticsearch-artifacts.repo
  sudo yum update -y
  sudo yum install $ES_PACKAGE_NAME -y
fi

#####################################################################################################

echo "setup es"

# everything needs es
if [ "$SETUP_DISTRO" = "zip" ]
then
  mkdir -p snapshots
  echo "path.repo: [\"$PWD/snapshots\"]" >> $ES_ROOT/config/elasticsearch.yml
  # Increase the number of allowed script compilations. The SQL integ tests use a lot of scripts.
  echo "script.context.field.max_compilations_rate: 1000/1m" >> $ES_ROOT/config/elasticsearch.yml
  echo "opendistro.destination.host.deny_list: [\"10.0.0.0/8\", \"127.0.0.1\"]" >> $ES_ROOT/config/elasticsearch.yml
elif [ "$SETUP_DISTRO" = "docker" ]
then
  echo "FROM opendistroforelasticsearch/opendistroforelasticsearch:$OD_VERSION" >> Dockerfile
  echo "RUN echo ''  >> /usr/share/elasticsearch/config/elasticsearch.yml" >> Dockerfile
  echo "RUN echo \"path.repo: [\\\"/usr/share/elasticsearch\\\"]\" >> /usr/share/elasticsearch/config/elasticsearch.yml" >> Dockerfile
  # Increase the number of allowed script compilations. The SQL integ tests use a lot of scripts.
  echo "RUN echo \"script.context.field.max_compilations_rate: 1000/1m\" >> /usr/share/elasticsearch/config/elasticsearch.yml" >> Dockerfile
  echo "RUN echo \"opendistro.destination.host.deny_list: [\"10.0.0.0/8\", \"127.0.0.1\"]\" >> /usr/share/elasticsearch/config/elasticsearch.yml" >> Dockerfile
  docker build -t odfe-http:security -f Dockerfile .
  sleep 5
  docker run -d -p 9200:9200 -d -p 9600:9600 -e "discovery.type=single-node" --name $DOCKER_NAME odfe-http:security
  sleep 60
  echo "Temp Solution to remove the wrong configuration. need be fixed in building stage"
  docker exec -t $DOCKER_NAME /bin/bash -c "sed -i /^node.max_local_storage_nodes/d /usr/share/elasticsearch/config/elasticsearch.yml"
  docker exec -t $DOCKER_NAME /bin/bash -c "echo \"opendistro_security.unsupported.restapi.allow_securityconfig_modification: true\" >> /usr/share/elasticsearch/config/elasticsearch.yml"
  docker stop $DOCKER_NAME
else
  sudo mkdir -p /home/repo
  sudo chmod 777 /home/repo
  sudo chmod 777 /etc/elasticsearch/elasticsearch.yml
  sudo sed -i '/path.logs/a path.repo: ["/home/repo"]' /etc/elasticsearch/elasticsearch.yml
  sudo sed -i /^node.max_local_storage_nodes/d /etc/elasticsearch/elasticsearch.yml
  # Increase the number of allowed script compilations. The SQL integ tests use a lot of scripts.
  sudo echo "script.context.field.max_compilations_rate: 1000/1m" | sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null
  sudo echo "opendistro.destination.host.deny_list: [\"10.0.0.0/8\", \"127.0.0.1\"]" | sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null
  sudo echo "opendistro_security.unsupported.restapi.allow_securityconfig_modification: true" | sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null
fi

if [ "$SETUP_ACTION" = "--es" ]
then
  if [ "$SETUP_DISTRO" = "zip" ]
  then
    cd $ES_ROOT
    nohup ./opendistro-tar-install.sh > install.log 2>&1 &
    sleep 60
    cat install.log
    kill -9 `ps -ef | grep [e]lasticsearch | awk '{print $2}'`
    sed -i /^node.max_local_storage_nodes/d ./config/elasticsearch.yml
    nohup ./opendistro-tar-install.sh > install.log 2>&1 &
    sleep 60
    cat install.log
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    docker restart $DOCKER_NAME
    docker ps
  else
    sudo systemctl restart elasticsearch.service
  fi
  echo "Sleep 120 seconds"
  sleep 120
  curl -XGET https://localhost:9200 -u admin:admin --insecure
  curl -XGET https://localhost:9200/_cat/plugins?v -u admin:admin --insecure
  curl -XGET https://localhost:9200/_cluster/health?pretty -u admin:admin --insecure
  echo "es start"
  netstat -ntlp
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
    ls -l $ES_ROOT/plugins
    sed -i '/http\.port/s/^# *//' $ES_ROOT/config/elasticsearch.yml
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    echo "RUN /usr/share/elasticsearch/bin/elasticsearch-plugin remove opendistro_security" >> Dockerfile
    echo "RUN ls -l /usr/share/elasticsearch/plugins"
    docker build -t odfe-http:no-security -f Dockerfile .
    sleep 5
  else
    sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove opendistro_security
    ls -l /usr/share/elasticsearch/plugins
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
    nohup ./opendistro-tar-install.sh > install.log 2>&1 &
    sleep 60
    cat install.log
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    docker run -d -p 9200:9200 -d -p 9600:9600 -e "discovery.type=single-node" --name $DOCKER_NAME_NoSec odfe-http:no-security
    docker ps
  else
    sudo systemctl restart elasticsearch.service
  fi
  echo "Sleep 120 seconds"
  sleep 120
  curl -XGET http://localhost:9200
  curl -XGET http://localhost:9200/_cat/plugins?v
  curl -XGET http://localhost:9200/_cluster/health?pretty
  echo "es-nosec start"
  netstat -ntlp
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
    aws s3 cp s3://$S3_RELEASE_BUCKET/${PLUGIN_PATH}${OD_VERSION}/odfe/$KIBANA_PACKAGE_NAME-$OD_VERSION-linux-$ARCHITECTURE.tar.gz . --quiet; echo $?
    tar -zxf $KIBANA_PACKAGE_NAME-$OD_VERSION-linux-$ARCHITECTURE.tar.gz -C $KIBANA_ROOT --strip-components 1
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
    nohup ./opendistro-tar-install.sh > install.log 2>&1 &
    sleep 60
    cat install.log
    kill -9 `ps -ef | grep [e]lasticsearch | awk '{print $2}'`
    sed -i /^node.max_local_storage_nodes/d ./config/elasticsearch.yml
    echo "opendistro_security.unsupported.restapi.allow_securityconfig_modification: true" >> ./config/elasticsearch.yml
    nohup ./opendistro-tar-install.sh > install.log 2>&1 &
    sleep 60
    cat install.log
    cd $KIBANA_ROOT
    nohup ./bin/kibana > kibana_install.log 2>&1 &
    sleep 60
    cat kibana_install.log
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    docker restart $DOCKER_NAME
    docker run -d --name $DOCKER_NAME_KIBANA --network="host" odfe-kibana-http:security
    docker ps
  else
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart kibana.service
  fi
  echo "Sleep 120 seconds"
  sleep 120
  curl -XGET https://localhost:9200 -u admin:admin --insecure
  curl -XGET https://localhost:9200/_cat/plugins?v -u admin:admin --insecure
  curl -XGET https://localhost:9200/_cluster/health?pretty -u admin:admin --insecure
  # kibana can still use http to check status
  curl -v -XGET http://localhost:5601
  #curl http://localhost:5601/_cat/plugins?v
  curl -v -XGET http://localhost:5601/api/status
  echo "es & kibana start"
  netstat -ntlp
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
    $KIBANA_ROOT/bin/kibana-plugin remove opendistroSecurityKibana 
    sed -i /^opendistro_security/d $KIBANA_ROOT/config/kibana.yml
    sed -i 's/https/http/' $KIBANA_ROOT/config/kibana.yml

    cd $ES_ROOT
    nohup ./opendistro-tar-install.sh > install.log 2>&1 &
    sleep 60
    cat install.log
    cd $KIBANA_ROOT
    nohup ./bin/kibana > kibana_install.log 2>&1 &
    sleep 60
    cat kibana_install.log
  elif [ "$SETUP_DISTRO" = "docker" ]
  then
    echo "RUN /usr/share/kibana/bin/kibana-plugin remove opendistroSecurityKibana" >> Dockerfile.kibana
    echo "RUN sed -i /^opendistro_security/d /usr/share/kibana/config/kibana.yml" >> Dockerfile.kibana
    echo "RUN sed -i 's/https/http/' /usr/share/kibana/config/kibana.yml" >> Dockerfile.kibana
    docker build -t odfe-kibana-http:no-security -f Dockerfile.kibana .
    sleep 5
    docker run -d -p 9200:9200 -d -p 9600:9600 -e "discovery.type=single-node" --name $DOCKER_NAME_NoSec odfe-http:no-security
    docker run -d --name $DOCKER_NAME_KIBANA_NoSec --network="host" odfe-kibana-http:no-security
    docker ps
  else
    sudo /usr/share/kibana/bin/kibana-plugin remove opendistroSecurityKibana --allow-root
    sudo sed -i /^opendistro_security/d /etc/kibana/kibana.yml
    sudo sed -i 's/https/http/' /etc/kibana/kibana.yml
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart kibana.service
  fi
  echo "Sleep 120 seconds"
  sleep 120
  curl -XGET http://localhost:9200
  curl -XGET http://localhost:9200/_cat/plugins?v
  curl -XGET http://localhost:9200/_cluster/health?pretty
  curl -v -XGET http://localhost:5601
  curl http://localhost:5601/_cat/plugins?v
  curl -v -XGET http://localhost:5601/api/status
  echo "es & kibana-nosec start"
  netstat -ntlp
  cd $REPO_ROOT
  exit 0
fi


