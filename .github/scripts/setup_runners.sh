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
# Requirements:  The env that runs this script must have its AWS IAM with these configurations
#                
#                * SSM Role
#                AmazonEC2RoleforSSM
#                AmazonSSMManagedInstanceCore 
#                
#                * EC2 User with FullAccess Policy requires these policies to attach to SSM Role
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
#                                "arn:aws:iam::<User ID>:role/<SSM Role Name>"
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
# Starting Date: 2020-07-27
# Modified Date: 2020-08-09
###############################################################################################

set -e

#####################################
# Variables / Parameters / Settings #
#####################################

# This script allows users to manually assign parameters
if [ "$#" -ne 3 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
  echo "Please assign at 3 parameters when running this script"
  echo "Example: $0 \$ACTION \$EC2_INSTANCE_NAMES(,) \$GITHUB_TOKEN"
  echo "Example: $0 \"run\" \"odfe-rpm-ism,odfe-rpm-sql\" \"<GitHub PAT>\""
  exit 1
fi

SETUP_ACTION=$1
SETUP_INSTANCE=`echo $2 | sed 's/,/ /g'`
SETUP_TOKEN=$3
SETUP_AMI_ID="ami-042f29d2ac35db697"
SETUP_AMI_USER="ec2-user"
SETUP_INSTANCE_TYPE="m5.xlarge"
SETUP_INSTANCE_SIZE=20 #GiB
SETUP_KEYNAME="odfe-release-runner"
SETUP_SECURITY_GROUP="odfe-release-runner"
SETUP_IAM_NAME="odfe-release-runner"
GIT_URL_API="https://api.github.com/repos"
GIT_URL_BASE="https://github.com"
GIT_URL_REPO="opendistro-for-elasticsearch/opendistro-build"

echo "###############################################"
echo "Start Running $0 $1 $2"
echo "###############################################"

###############################################
# Run / Start instances and bootstrap runners #
###############################################
if [ "$SETUP_ACTION" = "run" ]
then

  echo ""
  echo "Run / Start instances and bootstrap runners [${SETUP_INSTANCE}]"
  echo ""

  # Provision VMs
  for instance_name1 in $SETUP_INSTANCE
  do
    echo "[${instance_name1}]: Start provisioning vm"
    aws ec2 run-instances --image-id $SETUP_AMI_ID --count 1 --instance-type $SETUP_INSTANCE_TYPE \
                          --block-device-mapping DeviceName=/dev/xvda,Ebs={VolumeSize=$SETUP_INSTANCE_SIZE} \
                          --key-name $SETUP_KEYNAME --security-groups $SETUP_SECURITY_GROUP \
                          --iam-instance-profile Name=$SETUP_IAM_NAME \
                          --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name1}]" > /dev/null 2>&1; echo $?
    sleep 1
  done

  echo ""
  echo "Sleep for 120 seconds for EC2 instances to start running"
  echo ""

  sleep 120

  # Setup VMs to register as runners
  for instance_name2 in $SETUP_INSTANCE
  do
    echo "[${instance_name2}]: Make change of the runner hostname"
    aws ssm send-command --targets Key=tag:Name,Values=$instance_name2 --document-name "AWS-RunShellScript" \
                         --parameters '{"commands": ["#!/bin/bash", "sudo hostnamectl set-hostname '${instance_name2}'"]}' \
                         --output text > /dev/null 2>&1; echo $?

    echo "[${instance_name2}]: Get runner token and bootstrap on Git"
    instance_runner_token=`curl --silent -H "Authorization: token ${SETUP_TOKEN}" --request POST "${GIT_URL_API}/${GIT_URL_REPO}/actions/runners/registration-token" | jq -r .token`
    aws ssm send-command --targets Key=tag:Name,Values=$instance_name2 --document-name "AWS-RunShellScript" \
                         --parameters '{"commands": ["#!/bin/bash", "sudo su - '${SETUP_AMI_USER}' -c \"cd actions-runner && ./config.sh --unattended --url '${GIT_URL_BASE}/${GIT_URL_REPO}' --labels '${instance_name2}' --token '${instance_runner_token}' && nohup ./run.sh &\""]}' \
                         --output text > /dev/null 2>&1; echo $?
    sleep 5
  done

  echo ""
  echo "Wait for 60 seconds for runners to bootstrap on Git"
  echo ""

  sleep 60

  echo ""
  echo "All runners are online on Git"
  echo ""
fi


###################################################
# Terminate / Delete instances and remove runners #
###################################################
if [ "$SETUP_ACTION" = "terminate" ]
then

  echo ""
  echo "Terminate / Delete instances and remove runners [${SETUP_INSTANCE}]"
  echo ""

  for instance_name3 in $SETUP_INSTANCE
  do
    instance_runner_id_git=`curl --silent -H "Authorization: token ${SETUP_TOKEN}" --request GET "${GIT_URL_API}/${GIT_URL_REPO}/actions/runners" | jq ".runners[] | select(.name == \"${instance_name3}\") | .id"`
    echo "[${instance_name3}]: Unbootstrap runner from Git"
    curl --silent -H "Authorization: token ${SETUP_TOKEN}" --request DELETE "${GIT_URL_API}/${GIT_URL_REPO}/actions/runners/${instance_runner_id_git}"; echo $?

    instance_runner_id_ec2=`aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance_name3" | jq -r '.Reservations[].Instances[] | select(.State.Code == 16) | .InstanceId'` # Only running instances
    echo "[${instance_name3}]: Remove tags Name"
    aws ec2 delete-tags --resources $instance_runner_id_ec2 --tags Key=Name > /dev/null 2>&1; echo $?

    echo "[${instance_name3}]: Terminate runner"
    aws ec2 terminate-instances --instance-ids $instance_runner_id_ec2 > /dev/null 2>&1; echo $?

    sleep 1
  done

  echo "All runners are offline on Git"
fi


