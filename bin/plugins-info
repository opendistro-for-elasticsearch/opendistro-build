#!/bin/bash

###### Information ############################################################################
# Name:          plugins-info
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         Print the ES/KIBANA plugin names and git urls with correct dependency orders
#                as defined in the 'plugins.json' file
#
# Usage:         ./plugins-info $PLUGINS_TYPE $RETURN_TYPE [$REQUIRE_INSTALL]
#                $PLUGINS_TYPE: elasticsearch | kibana | client | perftop  (required)
#                $RETURN_TYPE: zip | deb | rpm | windows | git | cutversion (required)
#                $REQUIRE_INSTALL: <default to both> (optional)
#                                  --require-install-true
#                                  --require-install-false
#
# Starting Date: 2020-06-24
# Modified Date: 2020-08-27
###############################################################################################

set -e
ROOT=`dirname $(realpath $0)`;
PLUGINS_LIST="$ROOT/plugins.json"
PLUGINS_TYPE=`echo $1 | tr '[:upper:]' '[:lower:]'`
RETURN_TYPE=`echo $2 | tr '[:upper:]' '[:lower:]'`
REQUIRE_INSTALL=`echo $3 | tr '[:upper:]' '[:lower:]'`

if [ -z "$PLUGINS_TYPE" ] || [ -z "$RETURN_TYPE" ]
then
  echo "Please enter \$PLUGINS_TYPE \$RETURN_TYPE [\$REQUIRE_INSTALL] as parameter(s)"
  echo "Example: \"$0 elasticsearch zip\" (Retrieve all es plugins s3 paths for zip formats)"
  echo "Example: \"$0 elasticsearch zip --require-install-true\" (Retrieve es plugins s3 paths for zip formats that requires installation)"
  echo "Example: \"$0 elasticsearch zip --require-install-false\" (Retrieve es plugins s3 paths for zip formats that DO NOT requires installation)"
  exit 1
fi

if [ "$REQUIRE_INSTALL" = "--require-install-true" ]
then
    jq -r ".[] | select(.category == \"${PLUGINS_TYPE}\") | select(.require_install == \"true\") |  .$RETURN_TYPE" $PLUGINS_LIST
elif [ "$REQUIRE_INSTALL" = "--require-install-false" ]
then
    jq -r ".[] | select(.category == \"${PLUGINS_TYPE}\") | select(.require_install == \"false\") |  .$RETURN_TYPE" $PLUGINS_LIST
else
    jq -r ".[] | select(.category == \"${PLUGINS_TYPE}\") |  .$RETURN_TYPE" $PLUGINS_LIST
fi
