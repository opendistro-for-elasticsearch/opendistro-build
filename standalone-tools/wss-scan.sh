###### Information ############################################################################
# Name:          wss-scan.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         This script is to scan the odfe distros for vulnerabilities and licenses
#                It will scan the repositories and send the WhiteSource link to the mail 
#                of the user. 
#
# Prerequisites: Need to set the Java Path
#                Need to set the recepient mail in wss-scan.config
#
# Usage:         ./wss-scan.sh
#
# Starting Date: 10-13-2020
# Modified Date: 10-15-2020
###############################################################################################

#Download the WhiteSource Agent 
curl -LJO -sS https://github.com/whitesource/unified-agent-distribution/releases/latest/download/wss-unified-agent.jar > /dev/null

echo "Download completed"

#Scanning the config file for the user configurations
source wss-scan.config
gitRepos=${gitRepos//,/$'\n'}  # change the semicolons to white space

basepath=$baseDirPath"/repos"

if [[ ! -e $basepath ]]; then
    mkdir -p $basepath
fi
 

echo "Cleaning up scan directories if already present"
rm -rf $basepath/*


#Cloning the desired Repos for scanning 
for repo in $gitRepos
do
        echo "Cloning repo "$gitBasePath$repo
    git clone "$gitBasePath$repo".git $basepath"/"$repo
done

cp /dev/null info.txt

#Scanning the Repos using the WhiteSource Unified Agent
for repo in $gitRepos
do
	if [ -d "$basepath"/"$repo" ]
        then
           echo "Scanning repo :"$gitBasePath$repo " Project:" $repo 
	   repo_path=$basepath"/"$repo
	   java -jar wss-unified-agent.jar -c wss-unified-agent.config -d $repo_path -apiKey $wss_apikey -product ODFE -project $repo | grep "Project name" | sed 's/^.\{,41\}//' >> info.txt 2>&1 &
	else
	   echo "Scanning failed for repo :"$gitBasePath$repo " Project:" $repo
        fi
done



#Waiting for the scannings to complete
while ps ax | grep -vw grep| grep -w "wss-unified-agent.jar" > /dev/null
do
        echo "scanning is still in progress"
        sleep 20

done
echo "scanning has completed"

#ls -ltr

#Output of the Scan logs
cat whitesource/Fri*/*


#Mail function to send the scan details to the desired recepient 
mail_func()
{

#echo "Sending mail"
#cp /dev/null /tmp/tmp.html

cp /dev/null tmp.md

echo "<html><body><table border=1 cellspacing=0 cellpadding=3>" >> tmp.md

while IFS= read -r line
do
  #echo "$line"
  #setting comma as the delimiter

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

#echo -e "Content-Type: text/html; charset='utf-8'\r\nSubject: ODFE Vulnerability Scan details" |cat - tmp.html |sendmail -t ${emailid}
}

mail_func

if [ "${emailid}" != "" ]; then
	{
		echo "Sending mail"
		echo -e "Content-Type: text/html; charset='utf-8'\r\nSubject: ODFE Vulnerability Scan details" |cat - tmp.md |sendmail -t ${emailid}
	}
fi

#ls -ltr


#Removing the WhiteSource unified Jar and the the temporary mail file
rm "wss-unified-agent.jar" 
