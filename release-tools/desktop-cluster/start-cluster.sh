#!/bin/bash
# This script starts an Elasticsearch and Kibana cluster from an ODFE tarball. It un-tars the tarball, creates sensible elasticsearch.yml and kibana.yml files, starts the two processes, and waits for them to become available.

set -e

function usage() {
    echo "Usage: $0 [options] -e /path/to/elasticsearch.tgz -k /path/to/kibana.tgz"
    echo "Or   : $0 [options] -v <version>"
    echo "Mandatory arguments:"
    echo "-e PATH\tPath to the elasticsearch tarball. You must specify both -e and -k, or use -v to download an ODFE version."
    echo "-k PATH\tPath to the kibana tarball. You must specify both -e and -k, or use -v to download an ODFE version."
    echo "-v VERSION\tDownload ODFE version <VERSION>. This overrides the -e and -k options. If the files 'odfe-<VERSION>.tar.gz' or 'odfe-kibana-<VERSION>.tar.gz' exist in the current directory then they will not be re-fetched."
    echo ""
    echo "Options:"
    echo "-u\tRun unattended. If this is not specified, then the script will wait for the user to hit 'return' and automatically terminate the elasticsearch and kibana processes."
    echo "-w\tSet the working directory. This directory will be deleted and recreated. If not specified, then a new random temporary directory will be used. The tarballs will be unpacked into this directory; logs and the process pid files will be stored here."
    echo "-a\tSet the maximum number of times to probe the elasticsearch and kibana processes to see if the services are up. Defaults to 12."
    echo "-b\tSet the backoff (in seconds) between probes to the elasticsearch and kibana processes to see if they are up. Defaults to 10."
    echo "-h\tPrint this help message."
}

MAX_ATTEMPTS=12
BACKOFF=10

while getopts ":he:k:w:uv:a:b:" arg; do
    case $arg in
        h)
            usage
            exit 1
            ;;
        e)
            ELASTIC_TARBALL=`realpath $OPTARG`
            ;;
        k)
            KIBANA_TARBALL=`realpath $OPTARG`
            ;;
        w)
            WORK_DIR=$OPTARG
            ;;
        u)
            UNATTENDED="true"
            ;;
        v)
            VERSION=$OPTARG
            ;;
        a)
            MAX_ATTEMPTS=$OPTARG
            ;;
        b)
            BACKOFF=$OPTARG
            ;;
        :)
            echo "-${OPTARG} requires an argument"
            usage
            exit 1
            ;;
        ?)
            echo "Invalid option: -${arg}"
            exit 1
            ;;
    esac
done

if [ -n "$VERSION" ]; then
    ODFE_ELASTIC="odfe-$VERSION.tar.gz"
    if [ -e "$ODFE_ELASTIC" ]; then
        echo "$ODFE_ELASTIC already exists"
    else
        echo "Fetching ODFE-$VERSION into $ODFE_ELASTIC"
        wget -q http://d3g5vo6xdbdb9a.cloudfront.net/downloads/tarball/opendistro-elasticsearch/opendistroforelasticsearch-${VERSION}.tar.gz -O $ODFE_ELASTIC
        if [ $? -ne 0 ]; then
            echo "Download failed"
            exit 1
        fi
    fi

    ODFE_KIBANA="odfe-kibana-$VERSION.tar.gz"
    if [ -e "$ODFE_KIBANA" ]; then
        echo "$ODFE_KIBANA already exists"
    else
        echo "Fetching ODFE-Kibana-$VERSION into $ODFE_KIBANA"
        wget -q http://d3g5vo6xdbdb9a.cloudfront.net/downloads/tarball/opendistroforelasticsearch-kibana/opendistroforelasticsearch-kibana-${VERSION}.tar.gz -O $ODFE_KIBANA
        if [ $? -ne 0 ]; then
            echo "Download failed"
            exit 1
        fi
    fi

    ELASTIC_TARBALL=`realpath $ODFE_ELASTIC`
    KIBANA_TARBALL=`realpath $ODFE_KIBANA`
fi

if [ -z "$ELASTIC_TARBALL" ]; then
    echo "You must specify an elasticsearch tarball with the -e option, or use -v to specify an ODFE version to download"
    usage
    exit 1
fi

if [ -z "$KIBANA_TARBALL" ]; then
    echo "You must specify an elasticsearch tarball with the -k option, or use -v to specify an ODFE version to download"
    usage
    exit 1
fi

if [ -n "$UNATTENDED" ]; then
    echo "Starting unattended setup"
fi

if [ -z "$WORK_DIR" ]; then
    WORK_DIR=`mktemp -d`
    echo "Using new work directory: $WORK_DIR"
else
    echo "Deleting and re-creating work directory: $WORK_DIR"
    rm -rf $WORK_DIR
    mkdir -p $WORK_DIR
fi
SCRIPT_DIR=`dirname $(realpath $0)`

ELASTIC_DIR=$WORK_DIR/elasticsearch
KIBANA_DIR=$WORK_DIR/kibana
mkdir -p $ELASTIC_DIR
mkdir -p $KIBANA_DIR

# Set up elasticsearch
cd $ELASTIC_DIR
echo "Unpacking elasticsearch tarball $ELASTIC_TARBALL into $ELASTIC_DIR"
tar -xzf $ELASTIC_TARBALL -C $ELASTIC_DIR --strip-components 1

# Set up directories
mkdir -p data
mkdir -p logs
mkdir -p snapshots
mkdir -p config

# Create elasticsearch config
CLUSTER_NAME=desktop\
            DATA_DIR=$ELASTIC_DIR/data\
            LOG_DIR=$ELASTIC_DIR/log\
            SNAPSHOT_DIR=$ELASTIC_DIR/snapshots\
            envsubst < $SCRIPT_DIR/elasticsearch.yml.template > config/elasticsearch.yml
bash ./plugins/opendistro_security/tools/install_demo_configuration.sh -y -i > /dev/null

# Set up kibana
cd $KIBANA_DIR
echo "Unpacking kibana tarball $KIBANA_TARBALL into $KIBANA_DIR"
tar -xzf $KIBANA_TARBALL -C $KIBANA_DIR --strip-components 1

# Create kibana config
envsubst < $SCRIPT_DIR/kibana.yml.template > config/kibana.yml

# Start elasticsearch
cd $WORK_DIR
bash $ELASTIC_DIR/bin/elasticsearch >& $WORK_DIR/elasticsearch.log &
ELASTIC_PID=$!
echo "$ELASTIC_PID" > elasticsearch.pid
echo "Elasticsearch started with pid $ELASTIC_PID"

# Start kibana
bash $KIBANA_DIR/bin/kibana >& $WORK_DIR/kibana.log &
KIBANA_PID=$!
echo "$KIBANA_PID" > kibana.pid
echo "Kibana started with pid $KIBANA_PID"

# Wait for Elasticsearch to be available
# Turn off bash's "fail on error" because we expect the first couple of curl calls to fail
set +e
for (( attempt = 1 ; attempt < $MAX_ATTEMPTS ; attempt ++ )); do
    echo "Waiting for Elasticsearch to start: attempt ${attempt}"
    sleep $BACKOFF
    response=`curl --silent https://localhost:9200 --insecure -u admin:admin | grep "cluster_name"`
    if [ -n "$response" ]; then
        echo "Elasticsearch is up"
        success="true"
        break
    fi
done
if [ -z "$success" ]; then
    echo "Elasticsearch failed to start"
    kill $ELASTIC_PID $KIBANA_PID
    exit 1
fi

success=
# Wait for Kibana to be available
for (( attempt = 1 ; attempt < $MAX_ATTEMPTS ; attempt ++ )); do
    echo "Waiting for Kibana to start: attempt ${attempt}"
    sleep $BACKOFF
    response=`curl --silent http://localhost:5601/api/status | grep "green"`
    if [ -n "$response" ]; then
        echo "Kibana is up"
        success="true"
        break
    fi
done
if [ -z "$success" ]; then
    echo "Kibana failed to start"
    kill $ELASTIC_PID $KIBANA_PID
    exit 1
fi

if [ -n "$UNATTENDED" ]; then
    # Unattended installation: We're done
    echo "Exiting unattended installation. The working directory is $WORK_DIR"
    exit 0
fi

echo
echo
echo "*******"
echo "Elasticsearch and Kibana are up. You can test them by hitting https://localhost:9200 and http://localhost:5601 respectively"
echo "Press enter to terminate the Elasticsearch and Kibana instances"
echo "If you need to manually kill the processes, look in $(realpath elasticsearch.pid) and $(realpath kibana.pid) for the PIDs, or run 'stop-cluster.sh $WORK_DIR'"
echo "*******"

read input

echo "Killing Elasticsearch (pid $ELASTIC_PID)"
kill $ELASTIC_PID
rm elasticsearch.pid

echo "Killing Kibana (pid $KIBANA_PID)"
kill $KIBANA_PID
rm kibana.pid
