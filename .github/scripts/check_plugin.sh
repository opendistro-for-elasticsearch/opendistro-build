#!/bin/bash

###### Information ############################################################################
# Name:          check_plugin.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         This script is to check plugin artifacts availability for odfe distros
#                It will prepare emails to odfe-release-process@amazon.com and a chime msg
#                to inform user the status of the list of plugins
#
#                RED:    plugin artifact is NOT in S3 and corresponding repo has NO tag cut
#                YELLOW: plugin artifact is NOT in S3 but corresponding repo has A tag cut
#                GREEN:  plugin artifact is in S3
#
# Usage:         ./check_plugin.sh $PLUGIN_TYPES [$ODFE_VERSION]
#                $PLUGIN_TYPES: zip,deb,rpm,kibana,clidvr,perftop (optional)
#                $ODFE_VERSION: x.y.z (optional)
#
# Starting Date: 2020-05-29
# Modified Date: 2020-08-19
###############################################################################################

# Please leave it commented as aws s3 will fail if no plugin presents
#set -e

# This script is meant to be run within .github/scripts folder structure
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
S3_BUCKET="artifacts.opendistroforelasticsearch.amazon.com"
S3_DIR_zip="downloads/elasticsearch-plugins"
S3_DIR_rpm="downloads/rpms"
S3_DIR_deb="downloads/debs"
S3_DIR_kibana="downloads/kibana-plugins"
S3_DIR_clidvr="downloads/elasticsearch-clients"
S3_DIR_perftop="downloads/perftop"
TSCRIPT_NEWLINE="%0D%0A"
RUN_STATUS=0 # 0 is success, 1 is failure
PLUGIN_TYPES=$1
ODFE_VERSION=$2
OLDIFS=$IFS

# This script allows users to manually assign parameters
if [ "$#" -gt 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please assign at most 2 parameters when running this script"
  echo "Example: $0 \$PLUGIN_TYPES [\$ODFE_VERSION]"
  echo "Example: $0 \"tar\""
  echo "Example: $0 \"rpm,kibana\" \"1.7.0\""
  exit 1
fi

# Allow user assignment
echo "#######################################"
echo "PLUGIN_TYPES is: $PLUGIN_TYPES"
if [ -z "$PLUGIN_TYPES" ]
then
  # Kibana currently have the same plugins for all distros
  PLUGIN_TYPES="zip,deb,rpm,kibana,clidvr,perftop" # separate the types by comma here
  echo "Use default PLUGIN_TYPES: $PLUGIN_TYPES"
fi
PLUGIN_TYPES=`echo $PLUGIN_TYPES | tr '[:upper:]' '[:lower:]'`
echo "#######################################"

echo "#######################################"
echo "ODFE_VERSION is: $ODFE_VERSION"
if [ -z "$ODFE_VERSION" ]
then
  ODFE_VERSION=`$REPO_ROOT/bin/version-info --od`
  echo "Use default ODFE_VERSION: $ODFE_VERSION"
fi
echo "#######################################"

# plugin_type
IFS=,
for plugin_type in $PLUGIN_TYPES
do
  # Try to dynamically assign the variables based on PLUGIN_TYPES
  PLUGINS=`$REPO_ROOT/bin/plugins-info $plugin_type`
  PLUGINS_GIT=`$REPO_ROOT/bin/plugins-info $plugin_type --git | tr '\n' ' '`
  eval S3_DIR='$'S3_DIR_${plugin_type}
  plugin_arr=()
  unavailable_plugin=()
  inprogress_plugin=()
  available_plugin=()
  IFS=' ' read -r -a plugin_git_arr <<< $PLUGINS_GIT
  #IFS=$OLDIFS
  IFS=`echo -ne "\n\b"`
  echo ""

  echo "Proceed to check these ES Plugins ($plugin_type):"
  echo $S3_DIR
  echo "#######################################"
  for entry1 in $PLUGINS; do echo $entry1; done
  echo "#######################################"
  cd $ROOT
  rm -rf plugins
  mkdir -p plugins
  echo "#######################################"
  cd plugins

  for item in $PLUGINS
  do
    # temp fix until we change the structures
    plugin_folder=`echo $item|awk -F/ '{print $1}'`
    plugin_item=`echo $item|awk -F/ '{print $2}'`
    plugin_item_extra=`echo $item|awk -F/ '{print $3}'`

    if [ -z "$plugin_item_extra" ]
    then
      if [ -z "$plugin_item" ]
      then
        plugin_arr+=( $plugin_folder )
      else
        plugin_arr+=( $plugin_item )
      fi
    else
      plugin_arr+=( $plugin_item_extra )
    fi

    plugin_latest=`aws s3api list-objects --bucket $S3_BUCKET --prefix "${S3_DIR}/${item}-${ODFE_VERSION}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`

    # Quick fix and possible regex integration later
    if [ "$plugin_latest" = "None" ]
    then
      plugin_latest=`aws s3api list-objects --bucket $S3_BUCKET --prefix "${S3_DIR}/${item}_${ODFE_VERSION}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
    fi

    echo "downloading ${item}: ${plugin_latest}"
    aws s3 cp "s3://${S3_BUCKET}/${plugin_latest}" . --quiet; echo $?
  done
  echo "#######################################"
  ls -ltr
  echo "#######################################"
  tot_plugins=`ls|wc -l`
  echo $tot_plugins
  echo "${#plugin_arr[*]}"
  
  curr_plugins=`ls`
  for entry2 in $curr_plugins; do echo $entry2; done
  echo "#######################################"
  for index in ${!plugin_arr[*]}
  do
    plgin=${plugin_arr[$index]}
    plgin_git=${plugin_git_arr[$index]}

    if echo $curr_plugins | grep -q $plgin
    then
      # If on S3
      available_plugin+=( $plgin )
      echo "isavailable: ${plgin}"
    else
      plgin_tag=`$ROOT/plugin_tag.sh $plgin_git $ODFE_VERSION`
      if [ -z "$plgin_tag" ]
      then
        # If not on both S3 and Git Tag
        unavailable_plugin+=( $plgin )
        echo "unavailable: ${plgin}"
      else
        # If not on S3 but on Git Tag
        inprogress_plugin+=( $plgin )
        echo "in progress: ${plgin}"
      fi
    fi
  done

  echo "#######################################"
  #cd /home/runner/work/opendistro-build/opendistro-build/
  cd $ROOT

  if [ "$plugin_type" = "kibana" ]
  then
    echo "<h1><u>[KIBANA] Plugins ($ODFE_VERSION) Availability Checks for ( $plugin_type $tot_plugins/${#plugin_arr[*]} )</u></h1>" >> message.md
    echo ":bar_chart: [KIBANA] Plugins ($ODFE_VERSION) for ( $plugin_type $tot_plugins/${#plugin_arr[*]} ): $TSCRIPT_NEWLINE" >> chime_message.md
  else
    echo "<h1><u>[ES] Plugins ($ODFE_VERSION) Availability Checks for ( $plugin_type $tot_plugins/${#plugin_arr[*]} )</u></h1>" >> message.md
    echo ":mag_right: [ES] Plugins ($ODFE_VERSION) for ( $plugin_type $tot_plugins/${#plugin_arr[*]} ): $TSCRIPT_NEWLINE" >> chime_message.md
  fi
  
  echo "<h2><p style='color:red;'><b>NOT AVAILABLE</b></p></h2>" >> message.md
  if [ "${#unavailable_plugin[*]}" -gt 0 ]
  then
    RUN_STATUS=1
    echo "<ol>" >> message.md
    for item in ${unavailable_plugin[*]}
    do
      echo "<li><h3>$item</h3></li>" >> message.md
      echo ":x: $item $TSCRIPT_NEWLINE" >> chime_message.md
    done
    echo "</ol>" >> message.md
    echo "<br><br>" >> message.md
  fi
  
  echo "<h2><p style='color:gold;'><b>IN PROGRESS</b></p></h2>" >> message.md
  if [ "${#inprogress_plugin[*]}" -gt 0 ]
  then
    RUN_STATUS=1
    echo "<ol>" >> message.md
    for item in ${inprogress_plugin[*]}
    do
      echo "<li><h3>$item</h3></li>" >> message.md
      echo ":hourglass_flowing_sand: $item $TSCRIPT_NEWLINE" >> chime_message.md
    done
    echo "</ol>" >> message.md
    echo "<br><br>" >> message.md
  fi

  echo "<h2><p style='color:green;;'><b>AVAILABLE</b></p></h2>" >> message.md
  if [ "${#available_plugin[*]}" -gt 0 ]
  then
    echo "<ol>" >> message.md
    for item in ${available_plugin[*]}
    do
      echo "<li><h3>$item</h3></li>" >> message.md
      echo ":white_check_mark: $item $TSCRIPT_NEWLINE" >> chime_message.md
    done
    echo "</ol>" >> message.md
    echo "<br><br>" >> message.md
  fi
  
  echo "<br><br>" >> message.md
  echo "$TSCRIPT_NEWLINE" >> chime_message.md

# plugin_type
done

# cp message.md to work with the check_plugin.yml workflow
cp -v message.md /tmp/message.md
cp -v chime_message.md /tmp/chime_message.md

# Use status to decide a success or failure run
# DO NOT change this as workflow email is depend on this
if [ "$RUN_STATUS" -eq 1 ]
then
  echo "Plugin Checks Failure with 1 or more plugin(s) is not available"
  echo -n 1 > /tmp/plugin_status.check
else
  echo "Plugin Checks Success"
  echo -n 0 > /tmp/plugin_status.check
fi

