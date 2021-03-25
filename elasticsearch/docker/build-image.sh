# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
set -e

function usage() {
    echo "This script is used to build the Open Distro for ElasticSearch Docker image. It prepares the files required by the Dockerfile in a temporary directory, then builds and tags the Docker image."
    echo "Usage: $0 args"
    echo "Required arguments:"
    echo -e "-v VERSION\tSpecify the ODFE version number that you are building, e.g. '1.13.1'. This will used to label the Docker image. If you do not use the '-o' option then this tool will download a public ODFE release matching this version."
    echo ""
    echo "Optional arguments:"
    echo -e "-o FILENAME\tSpecify a local ODFE tarball. You still need to specify the version - this tool does not attempt to parse the filename."
    echo -e "-h\tPrint this message."
}

while getopts ":ho:v:" arg; do
    case $arg in
        h)
            usage
            exit 1
            ;;
        o)
            ODFE_TARBALL=`realpath $OPTARG`
            ;;
        v)
            ODFE_VERSION=$OPTARG
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

if [ -z "$ODFE_VERSION" ]; then
    echo "You must specify '-v VERSION'"
    usage
    exit 1
fi

DIR=`mktemp -d`

echo "Creating Docker workspace in $DIR"

if [ -z "$ODFE_TARBALL" ]; then
    # No tarball file specified so download one
    URL="http://d3g5vo6xdbdb9a.cloudfront.net/tarball/opendistro-elasticsearch/opendistroforelasticsearch-${ODFE_VERSION}-linux-x64.tar.gz"
    echo "Downloading ODFE version ${ODFE_VERSION} from $URL"
    curl -f $URL -o $DIR/odfe.tgz || exit 1
    ls -l $DIR
else
    cp $ODFE_TARBALL $DIR/odfe.tgz
fi

# TODO: Once https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/697 is built into an ODFE release these three lines can be removed
cp ../linux_distributions/opendistro-onetime-setup.sh $DIR/
cp ../linux_distributions/opendistro-run.sh $DIR/
cp ../linux_distributions/opendistro-tar-install.sh $DIR/

cp config/* $DIR/

docker build --build-arg ODFE_VERSION=$ODFE_VERSION --build-arg BUILD_DATE=`date -u +%Y-%m-%dT%H:%M:%SZ` -f dockerfiles/AL2.dockerfile $DIR -t odfe:$ODFE_VERSION

rm -rf $DIR
