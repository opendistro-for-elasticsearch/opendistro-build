#!/bin/bash

###### Information ############################################################################
# Name:          setup_runners.sh
# Maintainer:    ODFE Infra Team
# Language:      Shell
#
# About:         1. Run instances on EC2 based on parameters defined and wait for completion
#                2. SSH to these instances and configure / bootstrap on $GIT_URL_REPO as runners
#                3. Unbootstrap the runners and terminate the instances for cleanups
#
# Usage:         ./setup_runners.sh $ACTION $EC2_INSTANCE_NAMES $GITHUB_TOKEN
#                $ACTION: run | terminate (required)
#                $EC2_INSTANCE_NAMES: <names of instances> (required, sep ",")
#                $GITHUB_TOKEN: GitHub PAT with repo scope and Admin Access to $GIT_URL_REPO
#
# Requirements:  The env that runs this script must have its AWS resources with these configurations
#
#                1. Have an AWS user account with access to EC2 resource, remember the User ID
#
#                2. Create EC2 keypairs with name "odfe-release-runner"
#
#                3. Create EC2 Security Group with name "odfe-release-runner"
#                   with inbound rules of 22/9200/9600/5601 from IP ranges that need access to the runner
#
#                4. Create IAM resources:
#
#                * IAM role with name "odfe-release-runner", and these policies attached to it:
#                i.  AmazonEC2RoleforSSM
#                ii. AmazonSSMManagedInstanceCore 
#                
#                * IAM user "opendistro-ec2-user", generate a pair of security credentials,
#                  and these policies attached to it:
#                i.  AmazonEC2FullAccess 
#                ii. Custom policy using this json, I name it again to "odfe-release-runner"
#                {
#                    "Version": "2012-10-17",
#                    "Statement": [
#                        {
#                            "Sid": "VisualEditor0",
#                            "Effect": "Allow",
#                            "Action": [
#                                "ssm:SendCommand",
#                                "iam:PassRole"
#                            ],
#                            "Resource": [
#                                "arn:aws:ssm:*:*:document/*",
#                                "arn:aws:ec2:*:*:instance/*",
#                                "arn:aws:iam::<AWS User ID>:role/<IAM Role Name above>"
#                            ]
#                        },
#                        {
#                            "Sid": "VisualEditor1",
#                            "Effect": "Allow",
#                            "Action": "ssm:DescribeInstanceInformation",
#                            "Resource": "*"
#                        }
#                    ]
#                }
#
#                5. awscli must "aws login" with the security credencial created for IAM user
#                   in the step 4 above
#
#                6. If you change the above resources name from "odfe-release-runner" to "xyz",
#                   please update "Variables / Parameters / Settings" section of this script
#
#                7. Runner AMI requires installation of packages of these (java version can be different as gradle might request a higher version):
#                   Debian:
#                   sudo apt install -y curl wget unzip tar jq python python3 git awscli openjdk-14-jdk
#                   sudo apt install -y libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb
#
#                   RedHat:
#                   sudo yum install -y curl wget unzip tar jq python python3 git awscli java-latest-openjdk
#                   sudo yum install -y xorg-x11-server-Xvfb gtk2-devel gtk3-devel libnotify-devel GConf2 nss libXScrnSaver alsa-lib
#
#                   Also you need to install java devel if you want to compile library (e.g. knnlib)
#
#                8. AMI must be at least 16GB during the creation.
#
#                9. You can use `export GIT_UTL_REPO="opendistro-for-elasticsearch/opendistro-build"` or similar to set the Git Repo of the runner
#
#                10. JDK & SSM Agent
#                    You should find a way to install JDK14 or later on the server
#                    Dibian with: sudo add-apt-repository ppa:openjdk-r/ppa
#                    RedHat with: https://fedoraproject.org/wiki/EPEL
#                    
#                    Also, you need to install ssm agent
#                    on non-al2 machine due to ssm RunCommand requires that
#                    https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-manual-agent-install.html
#                    
#                    us-west-2
#                    RPM x64: https://s3.us-west-2.amazonaws.com/amazon-ssm-us-west-2/latest/linux_amd64/amazon-ssm-agent.rpm
#                    RPM arm64: https://s3.us-west-2.amazonaws.com/amazon-ssm-us-west-2/latest/linux_arm64/amazon-ssm-agent.rpm
#                    DEB x64: https://s3.us-west-2.amazonaws.com/amazon-ssm-us-west-2/latest/debian_amd64/amazon-ssm-agent.deb
#                    DEB arm64: https://s3.us-west-2.amazonaws.com/amazon-ssm-us-west-2/latest/debian_arm64/amazon-ssm-agent.deb
#                    yum or dpkg then systemctl enable/start amazon-ssm-agent
#
#                11. You also need to set the user of the GitHub Token to have ADMIN access of the GitHub Repo
#                    So that runner can be successfully bootstrapped to action tab in settings.
#
# Starting Date: 2020-07-27
# Modified Date: 2021-01-09
###############################################################################################

set -e

#####################################
# Variables / Parameters / Settings #
#####################################

# This script allows users to manually assign parameters
if [ "$#" -lt 3 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please assign at least 3 parameters when running this script"
  echo "Example: $0 \$ACTION \$EC2_INSTANCE_NAMES(,) \$GITHUB_TOKEN, \$EC2_AMI_ID"
  echo "Example (run must have 4 parameters): $0 \"run\" \"odfe-rpm-im,odfe-rpm-sql\" \"<GitHub PAT>\" \"ami-*\""
  echo "Example (terminate must have 3 parameters): $0 \"terminate\" \"odfe-rpm-im,odfe-rpm-sql\" \"<GitHub PAT>\""
  echo "You can use \`export GIT_UTL_REPO=\"opendistro-for-elasticsearch/opendistro-build\"\` or similar to set the Git Repo of the runner"
  exit 1
fi

SETUP_ACTION=$1
SETUP_RUNNER=`echo $2 | sed 's/,/ /g'`
SETUP_GIT_TOKEN=$3

# AMI on us-west-2
# Distro      Arch  Recommand Username AMI-ID                Java  Comments
# RPM-al2     x64   YES       ec2-user ami-0bd968fea932935f4 none  no jdk + reports kibana dependencies
# RPM-al2     arm64 YES       ec2-user ami-0ef0c96643bbd01f2 jdk14 preinstall with tar.gz + reports kibana dependencies
# DEB-ubu1804 arm64 YES       ubuntu   ami-03f8a33a16290a84c  jdk14 preinstall + docker + docker compose + reports kibana dependencies
# RPM-centos8 x64   NO        centos   ami-011f59f50bac33376 jdk15 preinstall
# RPM-centos8 arm64 NO        centos   ami-0ed17173ab64255b1 jdk15 preinstall
EC2_AMI_ID=$4

if [ "$SETUP_ACTION" = "run" ]
then
  if [ -z "$EC2_AMI_ID" ]
  then
    echo " \$EC2_AMI_ID is empty, please add a 4th parameter for the run "
    exit 1
  else
    # This does not support MacOS now due to cumbersome descriptions
    # MacOS sample: ami-00b3e436dc75183e0
    # "PlatformDetails": "Linux/UNIX"
    # "Architecture": "x86_64_mac"
    EC2_AMI_PLATFORM=`aws ec2 describe-images --image-id $EC2_AMI_ID --query 'Images[*].PlatformDetails' --output text | awk -F '/' '{print $1}' | tr '[:upper:]' '[:lower:]'`
    EC2_AMI_ARCH=`aws ec2 describe-images --image-id $EC2_AMI_ID --query 'Images[*].Architecture' --output text | sed 's/x86_64/x64/g'`
    EC2_AMI_NAME=`aws ec2 describe-images --image-id $EC2_AMI_ID --query 'Images[*].Name' --output text | tr '[:upper:]' '[:lower:]'`
    EC2_AMI_USER="ec2-user"; if echo $EC2_AMI_NAME | grep "centos"; then EC2_AMI_USER="centos"; elif echo $EC2_AMI_NAME | grep "ubuntu"; then EC2_AMI_USER="ubuntu"; fi
    EC2_INSTANCE_TYPE="m5.xlarge"; if [ "$EC2_AMI_ARCH" = "arm64" ]; then EC2_INSTANCE_TYPE="m6g.xlarge"; fi
    RUNNER_URL=`curl -s https://api.github.com/repos/actions/runner/releases/latest -H "Authorization: token $SETUP_GIT_TOKEN" | jq -r '.assets[].browser_download_url' | grep "$EC2_AMI_PLATFORM" | grep "$EC2_AMI_ARCH" | tail -n 1`
    echo Provision $EC2_AMI_PLATFORM $EC2_AMI_ARCH $EC2_AMI_NAME $EC2_AMI_USER $EC2_INSTANCE_TYPE $RUNNER_URL
  fi
fi


EC2_INSTANCE_SIZE=20 #GiB
EC2_KEYPAIR="odfe-release-runner"
EC2_SECURITYGROUP="odfe-release-runner"
IAM_ROLE="odfe-release-runner"
GIT_URL_API="https://api.github.com/repos"
GIT_URL_BASE="https://github.com"
GIT_URL_REPO=${GIT_URL_REPO:-opendistro-for-elasticsearch/opendistro-build}
RUNNER_DIR="actions-runner"


echo "###############################################"
echo "Start Running $0 $1 $2"
echo "###############################################"

###############################################
# Run / Start instances and bootstrap runners #
###############################################
if [ "$SETUP_ACTION" = "run" ]
then
  echo "GIT_URL_REPO $GIT_URL_REPO"

  echo ""
  echo "Run / Start instances and bootstrap runners [${SETUP_RUNNER}]"
  echo ""

  # Get information
  instance_root_device=`aws ec2 describe-images --image-id $EC2_AMI_ID --query 'Images[*].RootDeviceName' --output text`

  # Provision VMs
  for instance_name1 in $SETUP_RUNNER
  do
    echo "[${instance_name1}]: Start provisioning vm"
    aws ec2 run-instances --image-id $EC2_AMI_ID --count 1 --instance-type $EC2_INSTANCE_TYPE \
                          --block-device-mapping DeviceName=$instance_root_device,Ebs={VolumeSize=$EC2_INSTANCE_SIZE} \
                          --key-name $EC2_KEYPAIR --security-groups $EC2_SECURITYGROUP \
                          --iam-instance-profile Name=$IAM_ROLE \
                          --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name1}]" > /dev/null 2>&1; echo $?
    sleep 1
  done

  echo ""
  echo "Sleep for 120 seconds for EC2 instances to start running"
  echo ""

  sleep 120

  # Setup VMs to register as runners
  for instance_name2 in $SETUP_RUNNER
  do
    echo "[${instance_name2}]: Make change of the runner hostname"
    aws ssm send-command --targets Key=tag:Name,Values=$instance_name2 --document-name "AWS-RunShellScript" \
                         --parameters '{"commands": ["#!/bin/bash", "sudo hostnamectl set-hostname '${instance_name2}'"]}' \
                         --output text > /dev/null 2>&1; echo $?

    echo "[${instance_name2}]: Get latest runner binary to server ${RUNNER_URL}"
    aws ssm send-command --targets Key=tag:Name,Values=$instance_name2 --document-name "AWS-RunShellScript" \
                         --parameters '{"commands": ["#!/bin/bash", "sudo su - '${EC2_AMI_USER}' -c \"mkdir -p '${RUNNER_DIR}' && cd '${RUNNER_DIR}' && wget -q '${RUNNER_URL}' && tar -xzf *.tar.gz && rm *.tar.gz \""]}' \
                         --output text > /dev/null 2>&1; echo $?

    echo "[${instance_name2}]: Get runner token and bootstrap on Git"
    instance_runner_token=`curl --silent -H "Authorization: token ${SETUP_GIT_TOKEN}" --request POST "${GIT_URL_API}/${GIT_URL_REPO}/actions/runners/registration-token" | jq -r .token`
    # Wait 10 seconds for untar of runner binary to complete
    aws ssm send-command --targets Key=tag:Name,Values=$instance_name2 --document-name "AWS-RunShellScript" \
                         --parameters '{"commands": ["#!/bin/bash", "sudo su - '${EC2_AMI_USER}' -c \"sleep 30 && cd '${RUNNER_DIR}' && ./config.sh --unattended --url '${GIT_URL_BASE}/${GIT_URL_REPO}' --labels '${instance_name2}' --token '${instance_runner_token}' && nohup ./run.sh &\""]}' \
                         --output text > /dev/null 2>&1; echo $?
    sleep 5
  done

  echo ""
  echo "Wait for 90 seconds for runners to bootstrap on Git"
  echo ""

  sleep 90

  echo ""
  echo "All runners are online on Git"
  echo ""
fi


###################################################
# Terminate / Delete instances and remove runners #
###################################################
if [ "$SETUP_ACTION" = "terminate" ]
then
  echo "GIT_URL_REPO $GIT_URL_REPO"

  echo ""
  echo "Terminate / Delete instances and remove runners [${SETUP_RUNNER}]"
  echo ""

  for instance_name3 in $SETUP_RUNNER
  do
    instance_runner_id_git=`curl --silent -H "Authorization: token ${SETUP_GIT_TOKEN}" --request GET "${GIT_URL_API}/${GIT_URL_REPO}/actions/runners" | jq ".runners[] | select(.name == \"${instance_name3}\") | .id"`
    echo "[${instance_name3}]: Unbootstrap runner from Git"
    curl --silent -H "Authorization: token ${SETUP_GIT_TOKEN}" --request DELETE "${GIT_URL_API}/${GIT_URL_REPO}/actions/runners/${instance_runner_id_git}"; echo $?

    instance_runner_id_ec2=`aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance_name3" | jq -r '.Reservations[].Instances[] | select(.State.Code == 16) | .InstanceId'` # Only running instances
    echo "[${instance_name3}]: Remove tags Name"
    aws ec2 delete-tags --resources $instance_runner_id_ec2 --tags Key=Name > /dev/null 2>&1; echo $?

    echo "[${instance_name3}]: Terminate runner"
    aws ec2 terminate-instances --instance-ids $instance_runner_id_ec2 > /dev/null 2>&1; echo $?

    sleep 1
  done

  echo "All runners are offline on Git"
fi



