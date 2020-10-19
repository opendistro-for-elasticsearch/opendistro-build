###### Information ############################################################################
# Name:          wss-scan.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         This script is to scan the odfe distros for vulnerabilities and licenses
#                It will scan the repositories and send the WhiteSource link to the mail 
#                of the user. 
#
# Prerequisites: Need to install Java 14
#                Export JAVA_HOME env variable to the JDK path
#		 Add JAVA_HOME to PATH variable
#                Need to set the recepient mail in wss-scan.config for local run
#                API token is needed for local run
#
# Usage:         ./wss-scan.sh
#
# Starting Date: 10-13-2020
# Modified Date: 10-15-2020
###############################################################################################

set -e

java -version
if [ $? != 0 ] ; then echo "Java has not been setup" ; exit ; fi

# download the WhiteSource Agent 
curl -LJO -sS https://github.com/whitesource/unified-agent-distribution/releases/latest/download/wss-unified-agent.jar

# The version 20.9.2.1 has been tested and can be used if a specific version is required
#curl -LJO -sS https://github.com/whitesource/unified-agent-distribution/releases/download/v20.9.2.1/wss-unified-agent.jar


echo "wss-unified-agent jar download has been completed"

# scan the config file for the user configurations
# wss-scan.config has to be present in the same working directory as the script
source wss-scan.config

# change comma to whitespace
gitRepos=${gitRepos//,/$'\n'} 

basepath=$baseDirPath"/repos"

if [[ ! -e $basepath ]]; then
 mkdir -p $basepath
fi
 

echo "Cleaning up scan directories if already present"
rm -rf $basepath/*


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
if [ -d "$basepath"/"$repo" ]
then
echo "Scanning repo : "$gitBasePath$repo " Project:" $repo 
repo_path=$basepath"/"$repo
java -jar wss-unified-agent.jar -c wss-unified-agent.config -d $repo_path -apiKey $wss_apikey -product ODFE -project $repo | grep "Project name" | sed 's/^.\{,41\}//' >> info.txt 2>&1 &
else
echo "Scanning failed for repo : "$gitBasePath$repo " Project:" $repo
fi
done


i=0
# wait for the scannings to complete
while ps ax | grep -vw grep| grep -w "wss-unified-agent.jar" > /dev/null
do
echo "scanning is still in progress"
sleep 60
((i=i+1))
# break the loop after 70 mins
if [ $i -gt 70 ]; then break; fi
done
echo "scanning has completed"


# mail function to send the scan details to the desired recepient 
mail_format_func()
{

echo "<html><body><table border=1 cellspacing=0 cellpadding=3>" > tmp.md
while IFS= read -r line
do
# setting comma as the delimiter

IFS=','
read -ra val <<< "$line"
echo "<tr>" >> tmp.md
for ln in "${val[@]}"; do
echo "${ln//[[:space:]]/}"
echo "<td>"${ln//[[:space:]]/}"</td>" >> tmp.md
done
echo "</tr>" >> tmp.md
done < info.txt
echo "</table></body></html>" >> tmp.md

}

mail_format_func

# remove the functionality for local mail 

#if [ "${emailid}" != "" ]; then
#{
#echo "Sending mail"
#echo -e "Content-Type: text/html; charset='utf-8'\r\nSubject: ODFE Vulnerability Scan details" |cat - tmp.md |sendmail -t ${emailid}
#}
#fi



# remove the WhiteSource unified Jar 
rm "wss-unified-agent.jar" 
