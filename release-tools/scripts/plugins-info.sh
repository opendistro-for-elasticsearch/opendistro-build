#!/bin/bash

###### Information ############################################################################
# Name:          plugins-info.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         Print the ES/KIBANA plugin names and git urls with correct dependency orders
#                as defined in the $MANIFEST_FILE file
#
# Usage:         ./plugins-info.sh $PLUGIN_CATEGORY $RETURN_TYPE
#                $PLUGIN_CATEGORY : elasticsearch-plugins | kibana-plugins  (required)
#                                 | elasticsearch-clients | opendistro-libs  (required)
#                $RETURN_TYPE     : plugin_location* | plugin_git | plugin_version | plugin_build
#                                   plugin_spec | ......
#                                 ($MANIFEST_FILE file for more return types)
#
# Requirements:  Need to install yq (v4.0.0+) on your system:
#                LINUX: pip3 install yq
#                MACOS: brew install yq
#
# Starting Date: 2020-06-24
# Modified Date: 2021-01-06
###############################################################################################

set -e
ROOT=`dirname $(realpath $0)`;
MANIFEST_FILE="$ROOT/manifest.yml"
PLUGIN_CATEGORY=`echo $1 | tr '[:upper:]' '[:lower:]'`
RETURN_TYPE=`echo $2 | tr '[:upper:]' '[:lower:]'`
REQUIRE_INSTALL=`echo $3 | tr '[:upper:]' '[:lower:]'`

if [ -z "$PLUGIN_CATEGORY" ] || [ -z "$RETURN_TYPE" ]
then
  echo "Please enter \$PLUGIN_CATEGORY \$RETURN_TYPE [\$REQUIRE_INSTALL] as parameter(s)"
  echo "Example: \"$0 elasticsearch-plugins plugin_version\" (Retrieve es plugins versions)"
  echo "Example: \"$0 kibana-plugins plugin_git\" (Retrieve kibana plugins git repo urls)"
  exit 1
fi

# backup for yq v3.x.x version in case user cannot download yq v4.0.0+
# yq r $MANIFEST_FILE "snapshots.(plugin_category==${PLUGIN_CATEGORY}).${RETURN_TYPE}"

# yq v4.0.0+
yq eval ".plugins.[] | select(.plugin_category == \"${PLUGIN_CATEGORY}\") | .${RETURN_TYPE}" $MANIFEST_FILE


