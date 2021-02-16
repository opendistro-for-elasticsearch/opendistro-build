#!/bin/bash

###### Information ############################################################################
# Name:          releasenotes.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         Create a distro release notes markdown file based on plugin release notes
#
# Usage:         ./releasenotes.sh
#                URLs of plugin release notes are in $RELEASENOTES_ORIGURL 
#                (default to releasenotes-orig-urls.txt)
#
# Platform:      This script works on both GNU/LINUX and MacOS
#
# Starting Date: 2020-09-03
# Modified Date: 2021-01-06
###############################################################################################

set -e
# Setup variables
OLDIFS=$IFS
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`;
OD_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --od`
ES_VERSION=`$REPO_ROOT/release-tools/scripts/version-info.sh --es`
RELEASENOTES_ORIGURL="$ROOT/releasenotes-orig-urls.txt"
RELEASENOTES_SORTURL="$ROOT/releasenotes-sort-urls.txt"
RELEASENOTES_TEMPTXT="$ROOT/releasenotes-temp-text.tmp"
RELEASENOTES_DISTROS="$ROOT/releasenotes-dist-draft.md"
RELEASENOTES_CATEGORIES="BREAKING CHANGES,FEATURES,ENHANCEMENTS,BUG FIXES,INFRASTRUCTURE,DOCUMENTATION,MAINTENANCE,REFACTORING" # upper cases

# Clean up
rm -rf $RELEASENOTES_SORTURL
rm -rf $RELEASENOTES_TEMPTXT 

# Sort the urls in reverse order so they appear in normal order in distro release notes
(cat $RELEASENOTES_ORIGURL | grep -v -E "^#" | sort -rfd) > $RELEASENOTES_SORTURL

# Prepare ODFE distro release notes template 
IFS=,
echo -n > $RELEASENOTES_DISTROS
echo "# Open Distro for Elasticsearch ${OD_VERSION} Release Notes" >> $RELEASENOTES_DISTROS
echo "" >> $RELEASENOTES_DISTROS
echo "## Release Highlights" >> $RELEASENOTES_DISTROS
echo "" >> $RELEASENOTES_DISTROS
echo "## Release Details" >> $RELEASENOTES_DISTROS
echo "" >> $RELEASENOTES_DISTROS
echo "You can also track upcoming features in Open Distro for Elasticsearch by watching the code repositories or checking the [project website](https://opendistro.github.io/for-elasticsearch/features/comingsoon.html)." >> $RELEASENOTES_DISTROS
echo "" >> $RELEASENOTES_DISTROS

for category in $RELEASENOTES_CATEGORIES
do
  echo "## $category" >> $RELEASENOTES_DISTROS
  echo "" >> $RELEASENOTES_DISTROS
done

# Loop through each plugin release note url to create distro release notes
IFS=`echo -ne "\n\b"`
cat $RELEASENOTES_SORTURL | while read github_temp_url
do
  # Make sure we are pulling raw texts
  if echo $github_temp_url | grep -qi "raw.githubusercontent.com"
  then
    github_raw_url=$github_temp_url
  else
    github_raw_url=`echo $github_temp_url | sed 's@github.com@raw.githubusercontent.com@g;s@blob/@@g'`
  fi

  # Get capitalized name for plugin based on github release notes url
  github_capi_name=`basename $github_temp_url | awk -F '.' '{print $1}' | sed 's/opendistro-for-elasticsearch-//g;s/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1'`

  # Pulling the plugin release notes and get available category
  echo $github_raw_url
  wget -nv $github_raw_url -O $RELEASENOTES_TEMPTXT; echo $?

  CURR_CATEGORY_LIST=`cat $RELEASENOTES_TEMPTXT | grep "###"`
  for entry in $CURR_CATEGORY_LIST
  do
    # Get upper-case category to match with the one in template 
    entry_upper=`echo $entry | tr '[:lower:]' '[:upper:]'`

    # Resolve MacOS / BSD sed does not work the same as gnu sed commands
    # Replace pulled plugin release notes category names to upper-case so that we can retrieve actual release notes lines
    # Also, make sure & is properly escaped here
    sed "s/$entry/$entry_upper/g" $RELEASENOTES_TEMPTXT | sed 's/&/\\&/g' > ${RELEASENOTES_TEMPTXT}1
    mv ${RELEASENOTES_TEMPTXT}1 $RELEASENOTES_TEMPTXT

    # Get the actual release notes lines for the selected category, exclude category names
    entry_notes_array=( `sed -n "/$entry_upper/,/###/{//!p;}" $RELEASENOTES_TEMPTXT | sed '/^$/d'` )
    # Plugin release notes use ### and distro release notes use ## for category, so strip the leading # to achieve this behavior
    entry_upper=`echo $entry_upper | sed -E 's/^#//g'`

    # Loop through the actual release notes lines in reverse order so they appear in normal order on distro release notes
    for index in `seq $(echo ${#entry_notes_array[@]}) -1 0`
    do
      # As a limitation in MacOS / BSD version of sed, we can only insert one line at a time
      # Ignore usage of in-place parameter as there are differences between BSD/MacOS sed and GNU sed commands
      sed "s@${entry_upper}@&\\"$'\n'"${entry_notes_array[$index]}@g" $RELEASENOTES_DISTROS > ${RELEASENOTES_DISTROS}1
      mv ${RELEASENOTES_DISTROS}1 $RELEASENOTES_DISTROS
    done

    # Adding capitalized plugin names to distro release notes for each category
    sed "s@${entry_upper}@&\\"$'\n'''"### ${github_capi_name}@g" $RELEASENOTES_DISTROS > ${RELEASENOTES_DISTROS}1
    mv ${RELEASENOTES_DISTROS}1 $RELEASENOTES_DISTROS
    sed "s@${entry_upper}@&\\"$'\n'"@g" $RELEASENOTES_DISTROS > ${RELEASENOTES_DISTROS}1
    mv ${RELEASENOTES_DISTROS}1 $RELEASENOTES_DISTROS

  done

done

# Clean up
rm -rf $RELEASENOTES_SORTURL
rm -rf $RELEASENOTES_TEMPTXT 

echo ""
echo "ODFE distro release notes has been generated now:"
echo "$RELEASENOTES_DISTROS"

