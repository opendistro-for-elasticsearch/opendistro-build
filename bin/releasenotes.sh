#!/bin/bash

###### Information ############################################################################
# Name:          releasenotes.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         Create a distro release notes markdown file based on plugin release notes
#
# Usage:         ./releasenotes.sh
#                URLs of plugin release notes are taken from ./releasenotes.txt
#
# Starting Date: 2020-09-03
# Modified Date: 2020-09-04
###############################################################################################

set -e
ROOT=`dirname $(realpath $0)`;
RELEASENOTES_PLUGINS="$ROOT/releasenotes-plugins-urls.txt"
RELEASENOTES_DISTROS="$ROOT/releasenotes-distros-draft.md"
RELEASENOTES_CATEGORIES="Breaking Changes,Features,Enhancements,Bug Fixes,Infrastructure,Documentation,Maintenance,Refactoring"


cat $RELEASENOTES_LIST | while read line
do
  if !(echo $line | grep -q "raw.githubusercontent.com")
  then
    github_raw_url=`echo $line | sed 's@github.com@raw.githubusercontent.com@g;s@blob/@@g'`
    echo $github_raw_url
  fi
done

