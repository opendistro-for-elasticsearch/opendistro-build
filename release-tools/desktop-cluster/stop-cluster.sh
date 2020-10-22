#!/bin/bash
# This script stops the local Elasticsearch and Kibana created by the start-cluster.sh script. It looks for the elasticsearch.pid and kibana.pid files in a given directory and kills the corresponding processes.

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/workdir"
fi
DIR=$1

if [ -e $DIR/elasticsearch.pid ]; then
    pid=$(<$DIR/elasticsearch.pid)
    echo "Killing Elasticsearch (pid $pid)"
    kill $pid
    rm $DIR/elasticsearch.pid
fi

if [ -e $DIR/kibana.pid ]; then
    pid=$(<$DIR/kibana.pid)
    echo "Killing Kibana (pid $pid)"
    kill $pid
    rm $DIR/kibana.pid
fi
