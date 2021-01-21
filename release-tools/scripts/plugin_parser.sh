#!/bin/bash
  
###### Information ############################################################################
# About:         Retrieve the value for Plugin specific key from the Manifest file
#
# Usage:         ./plugin_parser.sh $plugin_name $key
###############################################################################################

set -e

# Parse manifest file to retrieve key value based on the plugin name as a filter
ROOT=`dirname $(realpath $0)`;
MANIFEST_FILE="$ROOT/manifest.yml"

plugin_name=$1
key=$2

# yq v4.0.0+ commands
yq eval '.plugins[] | select (.plugin_basename=="'$plugin_name'") | .'$key'' $MANIFEST_FILE
