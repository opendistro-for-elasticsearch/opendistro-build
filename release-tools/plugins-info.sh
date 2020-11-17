#!/bin/bash

###### Information ############################################################################
# Name:          plugins-info
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         Print the ES/KIBANA plugin names and git urls with correct dependency orders
#                as defined in the $PLUGIN_LIST file
#
# Usage:         ./plugins-info.sh $PLUGIN_CATEGORY $PLUGIN_TYPE
#                $PLUGIN_CATEGORY : elasticsearch | kibana | client | library  (required)
#                $PLUGIN_TYPE     : zip | deb | rpm | git | ...... (required)
#
# Requirements:  Need to install yq on your system:
#                LINUX: pip3 install yq
#                MACOS: brew install yq
#
# Starting Date: 2020-06-24
# Modified Date: 2020-11-16
###############################################################################################

set -e
ROOT=`dirname $(realpath $0)`;
PLUGIN_LIST="$ROOT/manifest.yml"
PLUGIN_CATEGORY=`echo $1 | tr '[:upper:]' '[:lower:]'`
PLUGIN_TYPE=`echo $2 | tr '[:upper:]' '[:lower:]'`
REQUIRE_INSTALL=`echo $3 | tr '[:upper:]' '[:lower:]'`
GIT_ORG="opendistro-for-elasticsearch"

if [ -z "$PLUGIN_CATEGORY" ] || [ -z "$PLUGIN_TYPE" ]
then
  echo "Please enter \$PLUGIN_CATEGORY \$PLUGIN_TYPE [\$REQUIRE_INSTALL] as parameter(s)"
  echo "Example: \"$0 elasticsearch zip\" (Retrieve es plugins s3 paths for zip formats)"
  echo "Example: \"$0 elasticsearch rpm\" (Retrieve es plugins s3 paths for rpm formats"
  echo "Example: \"$0 kibana git\" (Retrieve kibana plugins s3 paths for git urls)"
  exit 1
fi

if [ "$PLUGIN_TYPE" = "git" ]
then
  yq r $PLUGIN_LIST "snapshots.(plugin_category==${PLUGIN_CATEGORY}).plugin" | sed "s/^/${GIT_ORG}\//g"
else
  PLUGIN_LOCATION_ARRAY=(`yq r $PLUGIN_LIST "snapshots.(plugin_category==${PLUGIN_CATEGORY}).plugin_location"`)
  PLUGIN_NAME_ARRAY=(`yq r $PLUGIN_LIST "snapshots.(plugin_category==${PLUGIN_CATEGORY}).plugin_full_name"`)
  PLUGIN_TYPE_ARRAY=(`yq r $PLUGIN_LIST "snapshots.(plugin_category==${PLUGIN_CATEGORY}).plugin_type" | sed 's/\[//g;s/\]//g;s/ *//g'`)
  for index in ${!PLUGIN_LOCATION_ARRAY[@]}
  do
    if echo "${PLUGIN_TYPE_ARRAY[$index]}" | grep -q "$PLUGIN_TYPE"
    then
      echo "${PLUGIN_LOCATION_ARRAY[$index]}/${PLUGIN_NAME_ARRAY[$index]}"
    fi
  done
fi
