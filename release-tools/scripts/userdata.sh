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
#                the necessary services while installing the EC2 via Launch configurations
#
# Usage:         ./userdata.sh $distribution $security $architecture
#                $distribution: TAR | DEB | RPM (required)
#                $security: ENABLE | DISABLE (required)
#                $architecture: arm64 (optional defaults to x64)
#
###############################################################################################

set -e
REPO_ROOT=`git rev-parse --show-toplevel`
ES_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --es`
OD_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --od`
MANIFEST_FILE=$REPO_ROOT/release-tools/scripts/manifest.yml
S3_RELEASE_BASEURL=`yq eval '.urls.ODFE.releases' $MANIFEST_FILE`
echo $ES_VERSION $OD_VERSION

if [ "$#" -lt 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
    echo "Please assign atleast 2 parameters when running this script"
    echo "Format for dispatch event: \"client_payload\": {
		\"distribution\" : \"rpm\",
		\"security\" : \"enable\"
	}"
    echo "Example: $0 \"RPM\" \"ENABLE\""
    echo "Example: $0 \"DEB\" \"DISABLE\" \"ARM64\""
    exit 1
fi

ARCHITECTURE="x64"; if [ ! -z "$3" ]; then ARCHITECTURE=$3; fi; echo ARCHITECTURE $ARCHITECTURE
if [ "$ARCHITECTURE" = "arm64" ];
then
ESARCH="arm64"
else
ESARCH="amd64"
fi

###### RPM package with Security enabled ######
if [ "$1" = "RPM" ]
then
cat <<- EOF > $REPO_ROOT/userdata_$1.sh
#!/bin/bash
sudo -i
sudo curl https://d3g5vo6xdbdb9a.cloudfront.net/staging/yum/staging-opendistroforelasticsearch-artifacts.repo -o /etc/yum.repos.d/staging-opendistroforelasticsearch-artifacts.repo
sudo yum install -y libnss3.so xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-utils xorg-x11-fonts-cyrillic xorg-x11-fonts-Type1 xorg-x11-fonts-misc fontconfig freetype
sudo yum install -y opendistroforelasticsearch-$OD_VERSION
sudo sysctl -w vm.max_map_count=262144
echo "node.name: init-master" >> /etc/elasticsearch/elasticsearch.yml
echo "cluster.name: odfe-$OD_VERSION-$ARCHITECTURE-rpm-auth" >> /etc/elasticsearch/elasticsearch.yml
echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
echo "cluster.initial_master_nodes: [\"init-master\"]" >> /etc/elasticsearch/elasticsearch.yml
echo "webservice-bind-host = 0.0.0.0" >> /usr/share/elasticsearch/plugins/opendistro-performance-analyzer/pa_config/performance-analyzer.properties


# Installing kibana
sudo yum install -y opendistroforelasticsearch-kibana-$OD_VERSION
echo "server.host: 0.0.0.0" >> /etc/kibana/kibana.yml

EOF
fi

###### DEB package with Security enabled ######
if [ "$1" = "DEB" ];
then
cat <<- EOF > $REPO_ROOT/userdata_$1.sh
#!/bin/bash
#installing ODFE
sudo -i
sudo sysctl -w vm.max_map_count=262144
sudo apt-get update
sudo apt install zip awscli libnss3-dev fonts-liberation libfontconfig1 -y 
wget -qO - https://d3g5vo6xdbdb9a.cloudfront.net/GPG-KEY-opendistroforelasticsearch | sudo apt-key add -
echo "deb https://d3g5vo6xdbdb9a.cloudfront.net/staging/apt stable main" | sudo tee -a /etc/apt/sources.list.d/opendistroforelasticsearch.list
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-$ES_VERSION-$ESARCH.deb
sudo dpkg -i elasticsearch-oss-$ES_VERSION-$ESARCH.deb
sudo apt-get -y update
sudo apt install -y opendistroforelasticsearch
echo "node.name: init-master" >> /etc/elasticsearch/elasticsearch.yml
echo "cluster.initial_master_nodes: [\"init-master\"]" >> /etc/elasticsearch/elasticsearch.yml
echo "cluster.name: odfe-$OD_VERSION-$ARCHITECTURE-deb-auth" >> /etc/elasticsearch/elasticsearch.yml
echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
echo "webservice-bind-host = 0.0.0.0" >> /usr/share/elasticsearch/plugins/opendistro-performance-analyzer/pa_config/performance-analyzer.properties

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
sudo apt-get update
sudo apt install zip awscli libnss3-dev fonts-liberation libfontconfig1 -y 
ulimit -n 65535
aws s3 cp $S3_RELEASE_BASEURL$OD_VERSION/odfe/opendistroforelasticsearch-$OD_VERSION-linux-$ARCHITECTURE.tar.gz .
tar zxf opendistroforelasticsearch-$OD_VERSION-linux-$ARCHITECTURE.tar.gz
chown -R ubuntu:ubuntu opendistroforelasticsearch-$OD_VERSION
cd opendistroforelasticsearch-$OD_VERSION/

echo "node.name: init-master" >> config/elasticsearch.yml
echo "cluster.initial_master_nodes: [\"init-master\"]" >> config/elasticsearch.yml
echo "cluster.name: odfe-$OD_VERSION-$ARCHITECTURE-tarball-auth" >> config/elasticsearch.yml
echo "network.host: 0.0.0.0" >> config/elasticsearch.yml
echo "webservice-bind-host = 0.0.0.0" >> /opendistroforelasticsearch-$OD_VERSION/plugins/opendistro-performance-analyzer/pa_config/performance-analyzer.properties
sudo sysctl -w vm.max_map_count=262144



#Installing kibana
cd /
aws s3 cp $S3_RELEASE_BASEURL$OD_VERSION/odfe/opendistroforelasticsearch-kibana-$OD_VERSION-linux-$ARCHITECTURE.tar.gz .
tar zxf opendistroforelasticsearch-kibana-$OD_VERSION-linux-$ARCHITECTURE.tar.gz
chown -R ubuntu:ubuntu opendistroforelasticsearch-kibana
cd opendistroforelasticsearch-kibana/
echo "server.host: 0.0.0.0" >> config/kibana.yml

EOF
fi

# Extra configurations required
if [ "$1" = "TAR" ]
then
cat <<- EOF >> $REPO_ROOT/userdata_$1.sh
cd /opendistroforelasticsearch-$OD_VERSION/
mkdir -p snapshots
echo "path.repo: [\"/opendistroforelasticsearch-$OD_VERSION/snapshots\"]" >> config/elasticsearch.yml
# Increase the number of allowed script compilations. The SQL integ tests use a lot of scripts.
echo "script.context.field.max_compilations_rate: 1000/1m" >> config/elasticsearch.yml
EOF
else
cat <<- EOF >> $REPO_ROOT/userdata_$1.sh
sudo mkdir -p /home/repo
sudo chmod 777 /home/repo
sudo chmod 777 /etc/elasticsearch/elasticsearch.yml
sudo sed -i '/path.logs/a path.repo: ["/home/repo"]' /etc/elasticsearch/elasticsearch.yml
sudo sed -i /^node.max_local_storage_nodes/d /etc/elasticsearch/elasticsearch.yml
# Increase the number of allowed script compilations. The SQL integ tests use a lot of scripts.
sudo echo "script.context.field.max_compilations_rate: 1000/1m" >> /etc/elasticsearch/elasticsearch.yml
EOF
fi

#### Security disable feature ####
if  [[ "$2" = "DISABLE" ]]
then
if [[ "$1" = "RPM"  ||  "$1" = "DEB" ]]
then
sed -i "s/^echo \"cluster.name.*/echo \"cluster.name \: odfe-$OD_VERSION-$1-$ARCHITECTURE-noauth\" \>\> \/etc\/elasticsearch\/elasticsearch.yml/g" $REPO_ROOT/userdata_$1.sh
sed -i "/echo \"network.host/a echo \"opendistro_security.disabled: true\" \>\> \/etc\/elasticsearch\/elasticsearch.yml" $REPO_ROOT/userdata_$1.sh
cat <<- EOF >> userdata_$1.sh
sudo rm -rf /usr/share/kibana/plugins/opendistroSecurityKibana
sudo sed -i /^opendistro_security/d /etc/kibana/kibana.yml
sudo sed -i 's/https/http/' /etc/kibana/kibana.yml
EOF
else
sed -i "s/^echo \"cluster.name.*/echo \"cluster.name \: odfe-$OD_VERSION-$1-$ARCHITECTURE-noauth\" \>\> config\/elasticsearch.yml/g" $REPO_ROOT/userdata_$1.sh
cat <<- EOF >> userdata_$1.sh
sudo rm -rf plugins/opendistro_security
ls -l plugins/
sed -i /^opendistro_security/d config/elasticsearch.yml
cd /opendistroforelasticsearch-kibana/
sudo rm -rf plugins/opendistroSecurityKibana
sed -i /^opendistro_security/d config/kibana.yml
sed -i 's/https/http/' config/kibana.yml
EOF
fi
fi

#### Start Elasticsearch ####
if [[ "$1" = "TAR" ]]
then
cat <<- EOF >> $REPO_ROOT/userdata_$1.sh
cd /opendistroforelasticsearch-$OD_VERSION/
sudo -u ubuntu nohup ./opendistro-tar-install.sh 2>&1 > /dev/null &
EOF
if [[ "$2" = "ENABLE" ]]
then
cat <<- EOF >> $REPO_ROOT/userdata_$1.sh
sleep 30
kill -9 `ps -ef | grep [e]lasticsearch | awk '{print $2}'`
sed -i /^node.max_local_storage_nodes/d ./config/elasticsearch.yml
nohup ./opendistro-tar-install.sh > /dev/null 2>&1 &
EOF
fi
else
cat <<- EOF >> $REPO_ROOT/userdata_$1.sh
sudo systemctl start elasticsearch.service
sleep 30
EOF
fi

#### Start Kibana ####
if [[ "$1" = "TAR" ]]
then
cat <<- EOF >> $REPO_ROOT/userdata_$1.sh
cd /
cd opendistroforelasticsearch-kibana/
sudo -u ubuntu nohup ./bin/kibana &
EOF
else
echo "sudo systemctl start kibana.service" >> $REPO_ROOT/userdata_$1.sh
fi
