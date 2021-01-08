#!/bin/bash
  
###### Information ############################################################################
# About:         Retrieve the value for Plugin specific key from the Manifest file
#
# Usage:         ./plugin_parser.sh $plugin_name $key
###############################################################################################

set -e

# Parse manifest file to retrieve key value based on the plugin name as a filter

plugin_name=$1
key=$2

yq eval '.plugins[] | select (.plugin_basename=="'$plugin_name'") | .'$key'' ./release-tools/scripts/manifest.yml
