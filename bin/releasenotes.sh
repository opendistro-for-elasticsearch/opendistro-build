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
# Requirement:   This script needs gsed (gnu-sed) from Homebrew on MacOS
#                brew install gnu-sed
#
# Starting Date: 2020-09-03
# Modified Date: 2020-09-04
###############################################################################################

set -e
OLDIFS=$IFS
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`;
OD_VERSION=`python $REPO_ROOT/bin/version-info --od`
ES_VERSION=`python $REPO_ROOT/bin/version-info --es`
RELEASENOTES_PLUGINS="$ROOT/releasenotes-plugins-urls.txt"
RELEASENOTES_TEMPTXT="$ROOT/releasenotes-temp-text.temp"
RELEASENOTES_DISTROS="$ROOT/releasenotes-distros-draft.md"
RELEASENOTES_CATEGORIES=`echo "Breaking Changes,Features,Enhancements,Bug Fixes,Infrastructure,Documentation,Maintenance,Refactoring" | tr '[:lower:]' '[:upper:]'`

echo -n > $RELEASENOTES_DISTROS

echo "# Open Distro for Elasticsearch ${OD_VERSION} Release Notes" >> $RELEASENOTES_DISTROS
echo "" >> $RELEASENOTES_DISTROS
echo "## Release Highlights" >> $RELEASENOTES_DISTROS
echo "" >> $RELEASENOTES_DISTROS
echo "## Release Details" >> $RELEASENOTES_DISTROS
echo "" >> $RELEASENOTES_DISTROS

IFS=,
for category1 in $RELEASENOTES_CATEGORIES
do
  echo "## $category1" >> $RELEASENOTES_DISTROS
  echo "" >> $RELEASENOTES_DISTROS
done

IFS=`echo -ne "\n\b"`
cat $RELEASENOTES_PLUGINS | while read github_temp_url
do
  if !(echo $github_temp_url | grep -qi -E "^#")
  then
    if !(echo $github_temp_url | grep -qi "raw.githubusercontent.com")
    then
      github_raw_url=`echo $github_temp_url | sed 's@github.com@raw.githubusercontent.com@g;s@blob/@@g'`
    else
      github_raw_url=$github_temp_url
    fi

    echo $github_raw_url
    wget -q $github_raw_url -O $RELEASENOTES_TEMPTXT
    CATEGORY_LIST=`cat $RELEASENOTES_TEMPTXT | grep "###"`
    for entry in $CATEGORY_LIST
    do
      upper_entry=`echo $entry | tr '[:lower:]' '[:upper:]'`
      echo $upper_entry

      # Resolve MacOS / BSD sed does not work as same as gnu sed commands
      sed "s/$entry/$upper_entry/g" $RELEASENOTES_TEMPTXT > ${RELEASENOTES_TEMPTXT}1
      mv ${RELEASENOTES_TEMPTXT}1 $RELEASENOTES_TEMPTXT

      sed -n "/$upper_entry/,/###/{//!p;}" $RELEASENOTES_TEMPTXT | sed '/^$/d'
      echo $upper_entry
    done

  fi
done

