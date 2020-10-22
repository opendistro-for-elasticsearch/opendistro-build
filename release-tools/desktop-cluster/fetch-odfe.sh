#!/bin/bash
# This script will download an ODFE tarball distribution into the current directory

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION=$1

echo "Fetching ODFE-$VERSION"
wget -q http://d3g5vo6xdbdb9a.cloudfront.net/downloads/tarball/opendistro-elasticsearch/opendistroforelasticsearch-${VERSION}.tar.gz || echo "Failed"

echo "Fetching ODFE-Kibana-$VERSION"
wget -q http://d3g5vo6xdbdb9a.cloudfront.net/downloads/tarball/opendistroforelasticsearch-kibana/opendistroforelasticsearch-kibana-${VERSION}.tar.gz || echo "Failed"
