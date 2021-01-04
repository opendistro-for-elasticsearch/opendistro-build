#!/bin/bash
###### Information ############################################################################
# Name:          wss-scan.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         This script is to scan the odfe distros for vulnerabilities and licenses
#                It will scan the repositories and send the WhiteSource link to the mail 
#                of the user. 
#
# Prerequisites: Need to install Java 11
#                Export JAVA_HOME env variable to the JDK path
#                Add JAVA_HOME to PATH variable
#                Need to set the recepient mail in wss-scan.config for local run
#                WhiteSource API key is needed for local run, The API Key can be retrieved from the
#                WhiteSource Admin Console of your account.Use the below command to export the API key
#                export wss_apikey=$(APIKEY)
#
# Usage:         ./wss-scan.sh
#
###############################################################################################

set -e

java -version
if [ "$?" != 0 ]
then 
  echo "Java has not been setup" 
  exit 1
fi

if [ ! -f "wss-unified-agent.jar" ]
then
  # Download the WhiteSource Agent 
  wget -q https://github.com/whitesource/unified-agent-distribution/releases/latest/download/wss-unified-agent.jar
  # The version 20.9.2.1 has been tested and can be used if a specific version is required
  #wget -q  https://github.com/whitesource/unified-agent-distribution/releases/download/v20.9.2.1/wss-unified-agent.jar
fi

# scan the config file for the user configurations
# wss-scan.config has to be present in the same working directory as the script
source wss-scan.config

# change comma to whitespace
gitRepos=${gitRepos//,/$'\n'} 

basepath=$baseDirPath"/repos"

echo "Cleaning up scan directories if already present"
rm -rf $basepath

mkdir -p $basepath
 

# clone the desired Repos for scanning 
for repo in $gitRepos
do
  echo "Cloning repo "$gitBasePath$repo
  git clone "$gitBasePath$repo".git $basepath"/"$repo
done

echo -n > info.txt


# scan the Repos using the WhiteSource Unified Agent
for repo in $gitRepos
do
  repo_path=$basepath"/"$repo
  if [ -d "$repo_path" ]
  then
    echo "Scanning repo: "$gitBasePath$repo " Project: " $repo 
    java -jar wss-unified-agent.jar -c wss-unified-agent.config -d $repo_path -apiKey $wss_apikey -product ODFE -project $repo | grep "Project name" | sed 's/^.\{,41\}//' >> info.txt 2>&1 
  else
    echo "Scanning failed for repo: "$gitBasePath$repo " Project: " $repo
  fi
done



# mail function to send the scan details to the desired recepient 
mail_format_func()
{

echo "<html><body><table border=1 cellspacing=0 cellpadding=3>" > output.md
while IFS= read -r line
do
# setting comma as the delimiter

  IFS=','
  read -ra val <<< "$line"
  echo "<tr>" >> output.md
  for ln in "${val[@]}" 
  do
    echo "${ln//[[:space:]]/}"
    echo "<td>"${ln//[[:space:]]/}"</td>" >> output.md
  done
  echo "</tr>" >> output.md
done < info.txt
echo "</table></body></html>" >> output.md

}

mail_format_func

# remove the WhiteSource unified Jar 
rm "wss-unified-agent.jar" 
