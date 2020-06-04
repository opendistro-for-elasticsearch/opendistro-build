#!/bin/bash

# This script is meant to be run within .github/scripts folder structure
REPO_ROOT=`git rev-parse --show-toplevel`
ROOT=`dirname $(realpath $0)`; echo $ROOT; cd $ROOT
S3_BUCKET="artifacts.opendistroforelasticsearch.amazon.com"
S3_DIR_zip="downloads/elasticsearch-plugins"
S3_DIR_rpm="downloads/rpms"
S3_DIR_deb="downloads/debs"
S3_DIR_kibana="downloads/kibana-plugins"
TSCRIPT_NEWLINE="%0D%0A"
RUN_STATUS=0 # 0 is success, 1 is failure
PLUGIN_TYPES=$1
ODFE_VERSION=$2

# This script allows users to manually assign parameters
if [ "$#" -gt 2 ]
then
  echo "ERROR: Please assign at most 2 parameters when running this script"
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
  PLUGIN_TYPES="zip,deb,rpm,kibana" # separate the types by comma here
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

PLUGINS_zip="opendistro-alerting/opendistro_alerting \
             opendistro-anomaly-detection/opendistro-anomaly-detection \
             opendistro-index-management/opendistro_index_management \
             opendistro-job-scheduler/opendistro-job-scheduler \
             opendistro-knn/opendistro-knn \
             performance-analyzer/opendistro_performance_analyzer \
             opendistro-security/opendistro_security \
             opendistro-sql/opendistro_sql"

PLUGINS_rpm="opendistro-alerting/opendistro-alerting \
             opendistro-anomaly-detection/opendistro-anomaly-detection \
             opendistro-index-management/opendistro-index-management \
             opendistro-job-scheduler/opendistro-job-scheduler \
             opendistro-knn/opendistro-knn \
             opendistro-performance-analyzer/opendistro-performance-analyzer \
             opendistro-security/opendistro-security \
             opendistro-sql/opendistro-sql"

PLUGINS_deb="opendistro-alerting/opendistro-alerting \
             opendistro-anomaly-detection/opendistro-anomaly-detection \
             opendistro-index-management/opendistro-index-management \
             opendistro-job-scheduler/opendistro-job-scheduler \
             opendistro-knn/opendistro-knn \
             opendistro-performance-analyzer/opendistro-performance-analyzer \
             opendistro-security/opendistro-security \
             opendistro-sql/opendistro-sql"

PLUGINS_kibana="opendistro-alerting/opendistro-alerting \
                opendistro-anomaly-detection/opendistro-anomaly-detection-kibana \
                opendistro-index-management/opendistro_index_management_kibana \
                opendistro-security/opendistro_security_kibana_plugin \
                opendistro-sql-workbench/opendistro-sql-workbench"

# plugin_type
IFS=,
for plugin_type in $PLUGIN_TYPES
do
  unset IFS
  # Try to dynamically assign the variables based on PLUGIN_TYPES
  eval PLUGINS='$'PLUGINS_${plugin_type}
  eval S3_DIR='$'S3_DIR_${plugin_type}
  plugin_arr=()
  unavailable_plugin=()
  available_plugin=()
  echo ""

  echo "Proceed to check these ES Plugins ($plugin_type):"
  echo $S3_DIR
  echo "#######################################"
  echo $PLUGINS | tr " " "\n"
  echo "#######################################"
  cd $ROOT
  rm -rf plugins
  mkdir -p plugins
  echo "#######################################"
  cd plugins

  for item in $PLUGINS
  do
    plugin_folder=`echo $item|awk -F/ '{print $1}'`
    plugin_item=`echo $item|awk -F/ '{print $2}'`
    plugin_arr+=( $plugin_item )
    plugin_latest=`aws s3api list-objects --bucket artifacts.opendistroforelasticsearch.amazon.com --prefix "${S3_DIR}/${item}-${ODFE_VERSION}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`

    # Quick fix and possible regex integration later
    if [ "$plugin_latest" = "None" ]
    then
      plugin_latest=`aws s3api list-objects --bucket artifacts.opendistroforelasticsearch.amazon.com --prefix "${S3_DIR}/${item}_${ODFE_VERSION}" --query 'Contents[].[Key]' --output text | sort | tail -n 1`
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
  echo $curr_plugins
  for plgin in ${plugin_arr[*]}
    do
	if echo $curr_plugins|grep -q $plgin
	then
	    available_plugin+=( $plgin )
	    echo "$plgin exists"
	else
	    unavailable_plugin+=( $plgin )
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
  
  echo "<h2><p style='color:red;'>Below plugins are <b>NOT available</b> for ODFE-$ODFE_VERSION build:</p></h2>" >> message.md
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
  
  echo "<h2><p style='color:green;'>Below plugins are <b>available</b> for ODFE-$ODFE_VERSION build:</p></h2>" >> message.md
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

