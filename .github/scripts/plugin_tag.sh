#!/bin/bash

###### Information ############################################################################
# Name:          plugin-tag.sh
# Maintainer:    ODFE Infra Team
# Email:         odfe-infra@amazon.com
# Language:      Shell
#
# About:         Retrieve the latest tag of a specific repo based on certain filters on Git
#
# Usage:         ./plugin-tag.sh $GIT_REPONAME [$OD_VERSION]
#                $GIT_REPONAME: <repo_owner>/<repo_name> (required)
#                $OD_VERSION: ODFE Version (optional)
#
# Starting Date: 2020-06-17
# Modified Date: 2020-07-30
###############################################################################################

set -e

# This script allows users to manually assign parameters
if [ "$#" -eq 0 ] || [ "$#" -gt 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please assign at least 1 / at most 2 parameters when running this script"
  echo "Example: $0 \$GIT_REPONAME [\$OD_VERSION]"
  echo "Example: $0 \"opendistro-for-elasticsearch/opendistro-build\""
  echo "Example: $0 \"opendistro-for-elasticsearch/opendistro-build\" \"1.7.0\""
  exit 1
fi

# This script is meant to be run within .github/scripts folder structure
USE_PATCH_VERSION=0 # If version is 1.9.1, use 0 check 1.9, use 1 check 1.9.1
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; cd $ROOT
#GIT_GROUPNAME="https://github.com/opendistro-for-elasticsearch"
GIT_BASEURL="https://github.com"
GIT_REPONAME=$1

# Avoid issues when running on windows
OD_VERSION=`python $REPO_ROOT/bin/version-info --od`

# Use Major.Minor only to check available tags
if [ "$USE_PATCH_VERSION" -eq 0 ]
then
  OD_VERSION=`echo $OD_VERSION | sed -E 's/.[0-9]+$//g'`
fi

# Let user override the odfe version
if [ "$#" -eq 2 ]
then
  OD_VERSION=$2; #echo "Userinput OD_VERSION: $OD_VERSION"
fi

# Get the latest tag of the given repository
PLUGIN_TAG=`git ls-remote --tags "${GIT_BASEURL}/${GIT_REPONAME}" v* | grep $OD_VERSION | grep -oh "v[0-9.]*" | sort | tail -n 1`
echo "${PLUGIN_TAG}"

