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
# Starting Date: 2020-07-27
# Modified Date: 2020-10-07
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
SETUP_RUNNER=`echo $2 | sed 's/,/ /g'`
SETUP_GIT_TOKEN=$3
EC2_AMI_ID="ami-086e8a98280780e63"
EC2_AMI_USER="ec2-user"
EC2_INSTANCE_TYPE="m5.xlarge"
EC2_INSTANCE_SIZE=20 #GiB
EC2_KEYPAIR="odfe-release-runner"
EC2_SECURITYGROUP="odfe-release-runner"
IAM_ROLE="odfe-release-runner"
GIT_URL_API="https://api.github.com/repos"
GIT_URL_BASE="https://github.com"
GIT_URL_REPO="opendistro-for-elasticsearch/opendistro-build"
RUNNER_URL=`curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.assets[].browser_download_url' | grep linux-x64`
RUNNER_DIR="actions-runner"

echo "###############################################"
echo "Start Running $0 $1 $2"
echo "###############################################"

###############################################
# Run / Start instances and bootstrap runners #
###############################################
if [ "$SETUP_ACTION" = "run" ]
then

  echo ""
  echo "Run / Start instances and bootstrap runners [${SETUP_RUNNER}]"
  echo ""

  # Provision VMs
  for instance_name1 in $SETUP_RUNNER
  do
    echo "[${instance_name1}]: Start provisioning vm"
    aws ec2 run-instances --image-id $EC2_AMI_ID --count 1 --instance-type $EC2_INSTANCE_TYPE \
                          --block-device-mapping DeviceName=/dev/xvda,Ebs={VolumeSize=$EC2_INSTANCE_SIZE} \
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
                         --parameters '{"commands": ["#!/bin/bash", "sudo su - '${EC2_AMI_USER}' -c \"cd '${RUNNER_DIR}' && sleep 10 && ./config.sh --unattended --url '${GIT_URL_BASE}/${GIT_URL_REPO}' --labels '${instance_name2}' --token '${instance_runner_token}' && nohup ./run.sh &\""]}' \
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



