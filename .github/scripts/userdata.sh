#!/bin/bash

###### Information ############################################################################
# Name:          userdata.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         This script is related to testing-domains set-up.
#                See https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/283
#
#                In order to set-up domains, EC2 needs to have ES and Kibana running, 
#                hence this script will act as userdata input to install and configure 
#                the necessary services while installing the EC2 via AutoScaling Groups
#
# Usage:         ./userdata.sh $distribution $security
#                $distribution: TAR | DEB | RPM (required)
#                $security: ENABLE | DISABLE (required)
#
# Starting Date: 2020-06-24
# Modified Date: 2020-07-30
###############################################################################################

set -e
REPO_ROOT=`git rev-parse --show-toplevel`
ES_VER=`$REPO_ROOT/bin/version-info --es`
ODFE_VER=`$REPO_ROOT/bin/version-info --od`
echo $ES_VER $ODFE_VER

if [ "$#" -ne 2 ] || [ -z "$1" ] || [ -z "$2" ]
then
    echo "Please assign 2 parameters when running this script"
    echo "Format for dispatch event: \"client_payload\": {
		\"distribution\" : \"rpm\",
		\"security\" : \"enable\"
	}"
    echo "Example: $0 \"RPM\" \"ENABLE\""
    echo "Example: $0 \"DEB\" \"DISABLE\""
    exit 1
fi

###### RPM package with Security enabled ######
if [ "$1" = "RPM" ]
then
cat <<- EOF > $REPO_ROOT/userdata_$1.sh
#!/bin/bash
sudo -i
sudo curl https://d3g5vo6xdbdb9a.cloudfront.net/yum/staging-opendistroforelasticsearch-artifacts.repo -o /etc/yum.repos.d/staging-opendistroforelasticsearch-artifacts.repo
sudo yum install -y opendistroforelasticsearch-$ODFE_VER
sudo sysctl -w vm.max_map_count=262144
echo "node.name: init-master" >> /etc/elasticsearch/elasticsearch.yml
echo "cluster.name: odfe-$ODFE_VER-rpm-auth" >> /etc/elasticsearch/elasticsearch.yml
echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
echo "cluster.initial_master_nodes: [\"init-master\"]" >> /etc/elasticsearch/elasticsearch.yml

# Start the service
sudo systemctl start elasticsearch.service
sleep 30

# Installing kibana
sudo yum install -y opendistroforelasticsearch-kibana-$ODFE_VER
echo "server.host: 0.0.0.0" >> /etc/kibana/kibana.yml
EOF
fi

###### DEB package with Security enabled ######
if [ "$1" = "DEB" ]
then 
cat <<- EOF > $REPO_ROOT/userdata_$1.sh
#!/bin/bash
#installing ODFE
sudo -i
sudo sysctl -w vm.max_map_count=262144
sudo apt-get install -y zip
wget -qO - https://d3g5vo6xdbdb9a.cloudfront.net/GPG-KEY-opendistroforelasticsearch | sudo apt-key add -
echo "deb https://d3g5vo6xdbdb9a.cloudfront.net/staging/apt stable main" | sudo tee -a /etc/apt/sources.list.d/opendistroforelasticsearch.list
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VER-amd64.deb
sudo dpkg -i elasticsearch-oss-$ES_VER-amd64.deb
sudo apt-get -y update
sudo apt install -y opendistroforelasticsearch
echo "node.name: init-master" >> /etc/elasticsearch/elasticsearch.yml
echo "cluster.initial_master_nodes: [\"init-master\"]" >> /etc/elasticsearch/elasticsearch.yml
echo "cluster.name: odfe-$ODFE_VER-deb-auth" >> /etc/elasticsearch/elasticsearch.yml
echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml

# Start the service
sudo /etc/init.d/elasticsearch start
sleep 30

# Installing kibana
sudo apt install opendistroforelasticsearch-kibana
echo "server.host: 0.0.0.0" >> /etc/kibana/kibana.yml

EOF
fi

###### TAR package with Security enabled ######
if [ "$1" = "TAR" ]
then 
cat <<- EOF > $REPO_ROOT/userdata_$1.sh
#!/bin/bash
echo "*   hard  nofile  65535" | tee --append /etc/security/limits.conf
echo "*   soft  nofile  65535" | tee --append /etc/security/limits.conf
sudo apt-get install -y zip
ulimit -n 65535
wget https://d3g5vo6xdbdb9a.cloudfront.net/downloads/tarball/opendistro-elasticsearch/opendistroforelasticsearch-$ODFE_VER.tar.gz
tar zxvf opendistroforelasticsearch-$ODFE_VER.tar.gz
chown -R ubuntu:ubuntu opendistroforelasticsearch-$ODFE_VER
cd opendistroforelasticsearch-$ODFE_VER/

echo "node.name: init-master" >> config/elasticsearch.yml
echo "cluster.initial_master_nodes: [\"init-master\"]" >> config/elasticsearch.yml
echo "cluster.name: odfe-$ODFE_VER-tarball-auth" >> config/elasticsearch.yml
echo "network.host: 0.0.0.0" >> config/elasticsearch.yml
sudo sysctl -w vm.max_map_count=262144
sudo -u ubuntu nohup ./opendistro-tar-install.sh 2>&1 > /dev/null &

#Installing kibana
cd /
wget https://d3g5vo6xdbdb9a.cloudfront.net/downloads/tarball/opendistroforelasticsearch-kibana/opendistroforelasticsearch-kibana-$ODFE_VER.tar.gz
tar zxvf opendistroforelasticsearch-kibana-$ODFE_VER.tar.gz
chown -R ubuntu:ubuntu opendistroforelasticsearch-kibana
cd opendistroforelasticsearch-kibana/
echo "server.host: 0.0.0.0" >> config/kibana.yml
EOF
fi

#### Security disable feature ####
if  [[ "$2" = "DISABLE" ]]
then
if [[ "$1" = "RPM"  ||  "$1" = "DEB" ]]
then
sed -i "s/^echo \"cluster.name.*/echo \"cluster.name \: odfe-$ODFE_VER-$1-noauth\" \>\> \/etc\/elasticsearch\/elasticsearch.yml/g" $REPO_ROOT/userdata_$1.sh
sed -i "/echo \"network.host/a echo \"opendistro_security.disabled: true\" \>\> \/etc\/elasticsearch\/elasticsearch.yml" $REPO_ROOT/userdata_$1.sh
cat <<- EOF >> userdata_$1.sh
sudo rm -rf /usr/share/kibana/plugins/opendistro_security
sudo sed -i /^opendistro_security/d /etc/kibana/kibana.yml
sudo sed -i 's/https/http/' /etc/kibana/kibana.yml
EOF
else
sed -i "s/^echo \"cluster.name.*/echo \"cluster.name \: odfe-$ODFE_VER-$1-noauth\" \>\> config\/elasticsearch.yml/g" $REPO_ROOT/userdata_$1.sh
sed -i "/echo \"network.host/a echo \"opendistro_security.disabled: true\" \>\> config\/elasticsearch.yml" $REPO_ROOT/userdata_$1.sh
cat <<- EOF >> userdata_$1.sh
sudo rm -rf plugins/opendistro_security
sed -i /^opendistro_security/d config/kibana.yml
sed -i 's/https/http/' config/kibana.yml
EOF
fi
fi

#Start Kibana
if [[ "$1" = "RPM"  ||  "$1" = "DEB" ]]
then
echo "sudo systemctl start kibana.service" >> $REPO_ROOT/userdata_$1.sh
else
echo "sudo -u ubuntu nohup ./bin/kibana &" >> $REPO_ROOT/userdata_$1.sh
fi
