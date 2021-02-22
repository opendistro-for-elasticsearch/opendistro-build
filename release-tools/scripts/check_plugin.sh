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
# Usage:         ./check_plugin.sh $PLUGIN_CATEGORY [$ODFE_VERSION]
#                $PLUGIN_CATEGORY: elasticsearch-plugins,kibana-plugins,elasticsearch-clients,opendistro-libs
#                               (optional, use "," to separate multiple entries in one run)
#                $ODFE_VERSION: x.y.z (optional)
#
# Starting Date: 2020-05-29
# Modified Date: 2021-01-06
###############################################################################################

# Please leave it commented as aws s3 will fail if no plugin presents
#set -e

# This script is meant to be run within .github/scripts folder structure
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
SCRIPTS_DIR="$REPO_ROOT/release-tools/scripts"
#TSCRIPT_NEWLINE="%0D%0A"
RUN_STATUS=0 # 0 is success, 1 is failure
PLUGIN_CATEGORY=$1
ODFE_VERSION=$2
OLDIFS=$IFS

# This script allows users to manually assign parameters
if [ "$#" -gt 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please assign at most 2 parameters when running this script"
  echo "Example: $0 \$PLUGIN_CATEGORY [\$ODFE_VERSION]"
  echo "Example: $0 \"elasticsearch\""
  echo "Example: $0 \"elasticsearch,kibana\" \"1.7.0\""
  exit 1
fi

# Allow user assignment
echo "#######################################"
echo "PLUGIN_CATEGORY is: $PLUGIN_CATEGORY"
if [ -z "$PLUGIN_CATEGORY" ]
then
  # Kibana currently have the same plugins for all distros
  PLUGIN_CATEGORY="elasticsearch-plugins,kibana-plugins,elasticsearch-clients,opendistro-libs" # separate the types by comma here
  echo "Use default PLUGIN_CATEGORY: $PLUGIN_CATEGORY"
fi
PLUGIN_CATEGORY=`echo $PLUGIN_CATEGORY | tr '[:upper:]' '[:lower:]'`
echo "#######################################"

echo "#######################################"
echo "ODFE_VERSION is: $ODFE_VERSION"
if [ -z "$ODFE_VERSION" ]
then
  ODFE_VERSION=`$SCRIPTS_DIR/version-info.sh --od`
  echo "Use default ODFE_VERSION: $ODFE_VERSION"
fi
echo "#######################################"

# Cleanup messages here
rm -rf message.md chime_message.md

IFS=,
for plugin_category in $PLUGIN_CATEGORY
do
  IFS=$OLDIFS
  PLUGINS_BASENAME_ARRAY=( `$SCRIPTS_DIR/plugins-info.sh $plugin_category plugin_basename` )
  PLUGINS_IS_RC_ARRAY=( `$SCRIPTS_DIR/plugins-info.sh $plugin_category release_candidate` )
  PLUGINS_BUILD_ARRAY=( `$SCRIPTS_DIR/plugins-info.sh $plugin_category plugin_build` )
  IFS="]"; PLUGINS_LOCATION_ARRAY=( `$SCRIPTS_DIR/plugins-info.sh $plugin_category plugin_location_staging` ); IFS=$OLDIFS
  PLUGINS_SPEC_ARRAY=( `$SCRIPTS_DIR/plugins-info.sh $plugin_category plugin_spec | sed 's/\[//g;s/\]//g;s/ *//g'` )
  PLUGINS_GIT=`$SCRIPTS_DIR/plugins-info.sh $plugin_category plugin_git | tr '\n' ' '`
  plugin_total=0
  unavailable_plugin=()
  inprogress_plugin=()
  available_plugin=()
  IFS=' ' read -r -a PLUGINS_GIT_ARRAY <<< $PLUGINS_GIT
  echo ""

  echo "Proceed to check ($plugin_category):"
  echo "#######################################"

  for pindex in ${!PLUGINS_BASENAME_ARRAY[@]}
  do
    IFS=$OLDIFS
    plugin_is_rc=`echo ${PLUGINS_IS_RC_ARRAY[$pindex]}`; if [ "$plugin_is_rc" != "true" ]; then break; fi
    plugin_basename=`echo ${PLUGINS_BASENAME_ARRAY[$pindex]}`
    plugin_build=`echo ${PLUGINS_BUILD_ARRAY[$pindex]}`
    plugin_location_array1=( `echo ${PLUGINS_LOCATION_ARRAY[$pindex]} | sed 's/{/{"/g;s/:[ ]*"/"&/g;s/[][}{]//g;s/^/{/g;s/$/}/g' | jq -r '. | keys[]'` )
    plugin_location_array2=( `echo ${PLUGINS_LOCATION_ARRAY[$pindex]} | sed 's/{/{"/g;s/:[ ]*"/"&/g;s/[][}{]//g;s/^/{/g;s/$/}/g' | jq -r '.[]'` )
    plugin_spec_array=( `echo ${PLUGINS_SPEC_ARRAY[$pindex]} | tr ',' '\n'` )
    plugin_platform_array=( `echo ${PLUGINS_SPEC_ARRAY[$pindex]} | tr ',' '\n' | awk -F '_' '{print $1}'` )
    plugin_arch_array=( `echo ${PLUGINS_SPEC_ARRAY[$pindex]} | tr ',' '\n' | awk -F '_' '{print $2}'` )
    plugin_type_array=( `echo ${PLUGINS_SPEC_ARRAY[$pindex]} | tr ',' '\n' | awk -F '_' '{print $3}'` )
    plugin_total=$((plugin_total+${#plugin_type_array[@]}))
    plugin_git=${PLUGINS_GIT_ARRAY[$pindex]}
    plugin_version=`./plugin_parser.sh $plugin_basename plugin_version`

    IFS=`echo -ne "\n\b"`

    for lindex in ${!plugin_spec_array[@]}
    do
      plugin_bucket=""
      plugin_path=""
      for sindex in ${!plugin_location_array1[@]}
      do
        if [ "${plugin_location_array1[$sindex]}" = "default" ]
        then
          plugin_location_default=${plugin_location_array2[$sindex]}
          break
        fi
      done

      for sindex in ${!plugin_location_array1[@]}
      do
        if [ "${plugin_spec_array[$lindex]}" = "${plugin_location_array1[$sindex]}" ]
        then
          plugin_bucket=`echo ${plugin_location_array2[$sindex]}  | awk -F/ '{print $3}'`
          plugin_path=`echo ${plugin_location_array2[$sindex]} | sed "s/^.*$plugin_bucket\///g"`
          break
        fi
      done

      if [ -z "$plugin_bucket" ] && [ ! -z "$plugin_location_default" ]
      then
        plugin_bucket=`echo ${plugin_location_default}  | awk -F/ '{print $3}'`
        plugin_path=`echo ${plugin_location_default} | sed "s/^.*$plugin_bucket\///g"`
      else
        echo "manifest yaml error, neither default nor specific location exist for plugin location"
        exit 1
      fi

      plugin_platform=${plugin_platform_array[$lindex]}; if [ "$plugin_platform" = "noplatform" ]; then plugin_platform="";  fi
      plugin_arch=${plugin_arch_array[$lindex]}; if [ "$plugin_arch" = "noarch" ]; then plugin_arch="";  fi
      plugin_type=${plugin_type_array[$lindex]}
      plugin_latest=`aws s3api list-objects --bucket $plugin_bucket --prefix $plugin_path --query 'Contents[].[Key]' --output text \
                     | grep "${plugin_basename}" | grep "${plugin_platform}" |grep "${plugin_version}" | grep "${plugin_arch}" | grep "${plugin_build}" | grep "${plugin_type}" \
                     | sort | tail -n 1 | awk -F '/' '{print $NF}'`

      if [ -z "$plugin_latest" ]
      then
        plugin_tag=`$SCRIPTS_DIR/plugin_tag.sh $plugin_git $ODFE_VERSION`
        if [ -z "$plugin_tag" ]
        then
          plugin_latest="unavailable:${plugin_type_array[$tindex]}:${plugin_basename}"
          unavailable_plugin+=( $plugin_latest )
        else
          plugin_latest="in_progress:${plugin_type_array[$tindex]}:${plugin_basename}"
          inprogress_plugin+=( $plugin_latest )
        fi
      else
        plugin_latest="isavailable:${plugin_type_array[$tindex]}:${plugin_latest}"
        available_plugin+=( $plugin_latest )
      fi
      echo $plugin_latest
    done

  done

  cd $ROOT

  echo "<h1><u>[$plugin_category] Plugins ($ODFE_VERSION) Availability Checks for ( ${#available_plugin[@]}/$plugin_total )</u></h1>" >> message.md
  echo "[$plugin_category] Plugins ($ODFE_VERSION) for ( ${#available_plugin[@]}/$plugin_total ): " >> chime_message.md
  
  echo "<h2><p style='color:red;'><b>NOT AVAILABLE</b></p></h2>" >> message.md
  if [ "${#unavailable_plugin[@]}" -gt 0 ]
  then
    RUN_STATUS=1
    echo "<ol>" >> message.md
    for item in ${unavailable_plugin[@]}
    do
      item=`echo $item | awk -F ':' '{print $NF}'`
      echo "<li><h3>$item</h3></li>" >> message.md
      echo ":x: $item " >> chime_message.md
    done
    echo "</ol>" >> message.md
    echo "<br><br>" >> message.md
  fi
  
  echo "<h2><p style='color:gold;'><b>IN PROGRESS</b></p></h2>" >> message.md
  if [ "${#inprogress_plugin[@]}" -gt 0 ]
  then
    RUN_STATUS=1
    echo "<ol>" >> message.md
    for item in ${inprogress_plugin[@]}
    do
      item=`echo $item | awk -F ':' '{print $NF}'`
      echo "<li><h3>$item</h3></li>" >> message.md
      echo ":hourglass_flowing_sand: $item " >> chime_message.md
    done
    echo "</ol>" >> message.md
    echo "<br><br>" >> message.md
  fi

  echo "<h2><p style='color:green;;'><b>AVAILABLE</b></p></h2>" >> message.md
  if [ "${#available_plugin[@]}" -gt 0 ]
  then
    echo "<ol>" >> message.md
    for item in ${available_plugin[@]}
    do
      item=`echo $item | awk -F ':' '{print $NF}'`
      echo "<li><h3>$item</h3></li>" >> message.md
      echo ":white_check_mark: $item " >> chime_message.md
    done
    echo "</ol>" >> message.md
    echo "<br><br>" >> message.md
  fi
  
  echo "<br><br>" >> message.md
  echo "" >> chime_message.md

done

echo "#######################################"
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

