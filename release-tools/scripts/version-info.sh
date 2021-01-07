#!/bin/bash

###### Information ############################################################################
# Name:          version-info.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         Print the ES/ODFE related information and values
#                as defined in the 'manifest.yml' file
#
# Usage:         ./version-info.sh $VERSION_TYPE
#                $VERSION_TYPE (required): --od | --od-prev | --od-next
#                                          --es | --es-prev | --es-next
#
# Requirements:  Need to install yq (v4.0.0+) on your system:
#                https://github.com/mikefarah/yq/releases/
#
# Starting Date: 2021-01-06
# Modified Date: 2021-01-06
###############################################################################################

set -e
ROOT=`dirname $(realpath $0)`;
MANIFEST_FILE="$ROOT/manifest.yml"
VERSION_TYPE=$1

if [ -z "$VERSION_TYPE" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please enter \$VERSION_TYPE as parameter"
  echo "--od | --od-prev | --od-next | --es | --es-prev | --es-next"
  echo "Example: $0 --od"
  exit 1
fi

# yq v4.0.0+
case $VERSION_TYPE in

  --es)
    yq eval '.versions.ES.current' $MANIFEST_FILE
    ;;

  --es-prev)
    yq eval '.versions.ES.previous' $MANIFEST_FILE
    ;;

  --es-next)
    yq eval '.versions.ES.next' $MANIFEST_FILE
    ;;

  --od)
    yq eval '.versions.ODFE.current' $MANIFEST_FILE
    ;;

  --od-prev)
    yq eval '.versions.ODFE.previous' $MANIFEST_FILE
    ;;

  --od-next)
    yq eval '.versions.ODFE.next' $MANIFEST_FILE
    ;;

  *)
    echo -n "unknown user input"
    exit 1
    ;;
esac



