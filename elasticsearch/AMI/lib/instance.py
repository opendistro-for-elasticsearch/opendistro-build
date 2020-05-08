# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
#
# Description:
# Instance class 

import logging
import os

import boto3

from .ODFEInstaller import ODFEInstaller


class Instance:
    """Representation of EC2 instance for this module."""

    def __init__(
        self,
        AWS_access_key_id,
        AWS_secret_access_key,
        region_name,
        base_image_id,
        os,
        security_group_id,
        AMI_name,
        RPM_package_version="1.4.0",
        APT_OSS_version="7.4.2",
    ):
        """ 
        Initiating all the necessory variables and objects.
        Args:
            AWS_access_key_id: str, awskeyid used for authentication
            AWS_secret_access_key: str, aws secretacesskey used for authentication
            region_name: str, region name where instance will be braught up
            imageId: str, AMI image id of base os
            user_name: str, Name of the user used in base AMI (ubuntu for ubuntu and ec2-user for amazonLinux)
            os: str, name of the base os (ubuntu or amazonLinux)
            security_group_id: str, security group id which allows ssh the script to ssh into the instance
            AMI_name: str, name of the output AMI
            RPM_package_version: str, version of ODFE to be installed if RPM is used for installation(used in amazon linux)
            APT_OSS_version: str, version of Elasticsearch OSS to be installed if apt is used for installation(used in ubuntu)
        """

        self.ec2_client = boto3.client(
            "ec2",
            aws_access_key_id=AWS_access_key_id,
            aws_secret_access_key=AWS_secret_access_key,
            region_name=region_name,
        )
        ec2_resource = boto3.resource(
            "ec2",
            aws_access_key_id=AWS_access_key_id,
            aws_secret_access_key=AWS_secret_access_key,
            region_name=region_name,
        )
        self.key_pair_name = "ODFEAMIInstanceKey"
        self.key_path = self._create_key_pair()
        logging.info("Creating instance")
        self.instance = ec2_resource.create_instances(
            ImageId=base_image_id,
            MinCount=1,
            MaxCount=1,
            InstanceType="t3a.2xlarge",
            KeyName=self.key_pair_name,
            SecurityGroupIds=[security_group_id],
            AdditionalInfo="ODFE AMI",
        )[0]
        logging.info(f"Instance created with instance id {self.instance.instance_id}")
        self.os = os
        self.AMI_name = AMI_name
        self.RPM_package_version = RPM_package_version
        self.APT_OSS_version = APT_OSS_version
        if os == "ubuntu":
            self.user_name = "ubuntu"
        elif os == "amazonLinux":
            self.user_name = "ec2-user"

    def wait_until_ready(self):
        """
        wait for the instance to be ready and status check to be completed
        args:none
        returns: none
        """
        logging.info("Waiting for the instance to be running")
        # if instance is not in pending or running state
        if self.instance.state not in [0, 16]:
            self.instance.start()
        self.instance.wait_until_running()
        logging.info("Instance is running\nWaiting for status check")
        waiter = self.ec2_client.get_waiter("instance_status_ok")
        waiter.wait(InstanceIds=[self.instance.instance_id])
        logging.info("status = ok")

    def _create_key_pair(self):
        """
        Creates key pair and returns path where it is stored
        args: none
        returns: 
            str, path where pem file is stored
        """
        # check if keypair already exists
        try:
            logging.debug("Checking if keypair already exists")
            self.ec2_client.describe_key_pairs(KeyNames=[self.key_pair_name])
        except Exception as e:
            logging.debug("Keypair doesn't exists")
        else:
            # delete the existing key
            logging.debug("Keypair exists. Deleting keypair")
            self.ec2_client.delete_key_pair(KeyName=self.key_pair_name)
        logging.debug("Creating key pair")
        key = self.ec2_client.create_key_pair(KeyName=self.key_pair_name)
        with open(f"./{self.key_pair_name}.pem", "w") as f:
            f.write(key["KeyMaterial"])
        return f"./{self.key_pair_name}.pem"

    def install_ODFE(self):
        """
        Install open distro for elastic search in the instance 
        args:none
        returns: none
        precondition:
            instance should be ready(wait_until_ready)
        """
        installer = ODFEInstaller(
            self.instance.public_dns_name,
            self.user_name,
            self.os,
            self.key_path,
            self.RPM_package_version,
            self.APT_OSS_version,
        )
        installer.install()

    def create_AMI(self):
        """
        create AMI of the instance 
        args:none
        returns: none
        precondition:
            instance should be ready(wait_until_ready)
            necessary packages should be installed (install_ODFE)
        """
        logging.info("Creating AMI")
        self.snapshot = self.instance.create_image(
            Description="From Open Distro for Elasticsearh", Name=self.AMI_name
        )
        # wait for snapshot creation
        waiter = self.ec2_client.get_waiter("image_available")
        waiter.wait(ImageIds=[self.snapshot.image_id])
        logging.info(
            "AMI has been created with name "
            + self.AMI_name
            + " and AMI id: "
            + self.snapshot.image_id
        )
        return self.snapshot.image_id

    def cleanup_instance(self):
        """
        Terminates the instance
        args: none
        returns: none
        precondition:
        instance should be ready(wait_until_ready)
        """
        logging.info("Terminating instance")
        self.instance.terminate()
        self.instance.wait_until_terminated()
        logging.info(f"Deleting key {self.key_pair_name}")
        os.remove(self.key_path)
        self.ec2_client.delete_key_pair(KeyName=self.key_pair_name)
        logging.info("Instance has been terminated")
