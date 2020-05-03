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
# AMI builder main file

import logging
from os import environ
import sys
import time

import boto3

from lib.instance import Instance


def copy_AMI_to_regions(
    AWS_access_key_id, AWS_secret_access_key, AMI_id, AMI_source_region, AMI_copy_regions, AMI_name
):
    """
    Copies the AMI to specified regions
    args: 
        AWS_access_key_id: str, aws key id
        AWS_secret_access_key: str, aws secret access key
        AMI_id: str, AMI_id of the ami to be copied
        AMI_source_region: str, region where the AMI is present
        AMI_copy_regions: list(str)regions where the ami has to be copied
    returns: none
    """
    for region in AMI_copy_regions:
        try:
            logging.info(
                f"Copying ami {AMI_id} from {AMI_source_region} to {region}")
            ec2_client = boto3.client(
                "ec2",
                aws_access_key_id=AWS_access_key_id,
                aws_secret_access_key=AWS_secret_access_key,
                region_name=region,
            )
            AMI_copy = ec2_client.copy_image(
                Name=AMI_name, SourceImageId=AMI_id, SourceRegion=AMI_source_region
            )
            logging.info(
                f"Wait for the copy process to complete. Region name: {region}, AMI-id:{AMI_copy['ImageId']}")
        except Exception as e:
            logging.error(
                f"There was an exception while copying ami from {AMI_source_region} to {region}. "
                + str(e)
            )


def AMI_builder(
    AWS_access_key_id,
    AWS_secret_access_key,
    region_name,
    base_image_id,
    os,
    security_group_id,
    AMI_name,
    RPM_package_version,
    APT_OSS_version,
):
    """
    Builds the ODFE AMI
    args: 
        AWS_access_key_id: str, aws key id
        AWS_secret_access_key: str, aws secret access key
        region_name: str, region where the Instance will be created
        base_image_id: str, base os AMI id,  
        os: str, ubuntu or amazonLinux
        security_group_id: str, security group with port 22 open
        AMI_name: str, Name of the AMI that will be created
        RPM_package_version: str, version of ODFE to be installed if RPM is used for installation(used in amazon linux)
        APT_OSS_version: str, version of Elasticsearch OSS to be installed if apt is used for installation(used in ubuntu)
    returns: none
    """
    try:
        instance = Instance(
            AWS_access_key_id=AWS_access_key_id,
            AWS_secret_access_key=AWS_secret_access_key,
            region_name=region_name,
            base_image_id=base_image_id,
            os=os,  # ubuntu, amazonLinux
            security_group_id=security_group_id,
            AMI_name=AMI_name,
            RPM_package_version=RPM_package_version,
            APT_OSS_version=APT_OSS_version,
        )
    except Exception as err:
        logging.error("Could not bring up the instance. " + str(err))
        sys.exit(-1)
    AMI_id = ""
    installation_failed = False
    try:
        instance.wait_until_ready()
    except Exception as err:
        logging.error(
            "Could not bring the instance to ready state. " + str(err))
        installation_failed = True
    else:
        try:
            instance.install_ODFE()
            AMI_id = instance.create_AMI()
        except Exception as err:
            installation_failed = True
            logging.error(
                "AMI creation failed there was an error see the logs. " + str(err))
    finally:
        try:
            instance.cleanup_instance()
        except Exception as err:
            logging.error(
                "Could not cleanup the instance. There could be an instance currently running, terminate it. " + str(err))
            installation_failed = True
    if installation_failed:
        sys.exit(-1)
    # copy the AMI to the required regions
    ec2_client = boto3.client(
        "ec2",
        aws_access_key_id=AWS_access_key_id,
        aws_secret_access_key=AWS_secret_access_key,
        region_name=region_name,
    )
    AMI_copy_regions = [region["RegionName"]
                        for region in ec2_client.describe_regions()["Regions"]]
    AMI_copy_regions.remove(region_name)  # since AMI is created here
    copy_AMI_to_regions(
        AWS_access_key_id=AWS_access_key_id,
        AWS_secret_access_key=AWS_secret_access_key,
        AMI_id=AMI_id,
        AMI_name=AMI_name,
        AMI_source_region=region_name,
        AMI_copy_regions=AMI_copy_regions,
    )


def main():
    logging.basicConfig(filename="./AMI.log",
                        filemode="w", level=logging.DEBUG)
    logging.getLogger().addHandler(logging.StreamHandler(sys.stdout))
    # disable DEBUG logs from imported modules
    logging.getLogger("boto3").setLevel(logging.CRITICAL)
    logging.getLogger("botocore").setLevel(logging.CRITICAL)
    logging.getLogger("nose").setLevel(logging.CRITICAL)
    logging.getLogger("s3transfer").setLevel(logging.CRITICAL)
    logging.getLogger("urllib3").setLevel(logging.CRITICAL)
    logging.getLogger("paramiko").setLevel(logging.CRITICAL)
    required_environment_variables = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY",
                                      "region_name", "base_image_id", "os", "security_group_id", "AMI_name"]
    for var in required_environment_variables:
        if environ.get(var) == None:
            logging.error("Need to specify environment variable " + var)
            sys.exit(-1)
    
    logging.info("Starting AMI creation with following config")
    for var in required_environment_variables:
        logging.info(f'{var} : {environ[var]}')

    AMI_builder(
        AWS_access_key_id=environ["AWS_ACCESS_KEY_ID"],
        AWS_secret_access_key=environ["AWS_SECRET_ACCESS_KEY"],
        region_name=environ["region_name"],
        base_image_id=environ["base_image_id"],
        os=environ["os"],
        security_group_id=environ["security_group_id"],
        AMI_name=environ["AMI_name"],
        RPM_package_version=environ.get("RPM_package_version", "1.4.0"),
        APT_OSS_version=environ.get("APT_OSS_version", "7.4.2"),
    )


if __name__ == "__main__":
    main()
