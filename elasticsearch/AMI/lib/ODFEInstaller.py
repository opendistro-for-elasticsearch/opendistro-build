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
# ODFE installer class

import logging

import paramiko


class ODFEInstaller:
    """
    Used to install ODFE on the specified instance
    """

    def __init__(
        self, public_DNS_name, user_name, os, key_path, RPM_package_version="", APT_OSS_version=""
    ):
        """
        args:
            user_name: str, Name of the user used in base AMI (ubuntu for ubuntu and ec2-user for amazonLinux)
            os: str, name of the base os (ubuntu or amazonLinux)
            key_path: str, private key path
            RPM_package_version: str, version of ODFE to be installed if RPM is used for installation(used in amazon linux)
            APT_OSS_version: str, version of Elasticsearch OSS to be installed if apt is used for installation(used in ubuntu)
        Make sure to:
            specify RPM_package_version if  amazon linux base image is used
            specify APT_OSS_version if  ubuntu base image is used
        """
        self.user_name = user_name
        self.os = os
        self.key_path = key_path
        self.host_name = public_DNS_name
        self.SSH_client = self._get_SSH_client()
        self.RPM_package_version = RPM_package_version
        self.APT_OSS_version = APT_OSS_version

    def _pretty_print(self, stdout, stderr):
        """
        used to decode and print the output and error returned by sshclient
        args:
            stdout = str, output returned by sshclient
            stderr = str, output returned by sshclient
        returns: none
        """
        output = stdout.read().splitlines()
        logging.debug("Output from the instance shell : ")
        if len(output) == 0:
            logging.debug("None")
        else:
            for line in output:
                logging.debug(line.decode())
        logging.debug("Error from the instance shell : ")
        error = stderr.read().splitlines()
        if len(error) == 0:
            logging.debug("None")
        else:
            for line in error:
                logging.debug(line.decode())

    def _get_SSH_client(self):
        """
        used to get ssh client created by paramiko
        args: none
        returns: pramiko ssh client
        """
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        private_key = paramiko.RSAKey.from_private_key_file(self.key_path)
        ssh.connect(hostname=self.host_name, username=self.user_name, pkey=private_key)
        return ssh

    def _run_command(self, description, command):
        """used to run commands in the instance 
            args:
                description : str, description of the command
                command: str, command to be run
            returns:
                stdout = str, output returned by the shell
                stderr = str, error returned by the shell
        """
        logging.info(description)
        stdin, stdout, stderr = self.SSH_client.exec_command(command)
        stdin.flush()
        return stdout, stderr

    def _get_commands(self):
        """
        returns the commands specific to the os to install opendistro for elastic search
        args: none
        returns:
            list({description: "", command: ""}), commands with their description
        """
        commands = []
        if self.os == "ubuntu":
            commands = [
                {
                    "description": "installing jdk11",
                    "command": "sudo add-apt-repository ppa:openjdk-r/ppa -y && sudo apt update -y &&  sudo apt install openjdk-11-jdk -y",
                },
                {
                    "description": "installing unzip",
                    "command": "sudo apt-get install unzip -y"
                },
                {
                    "description": "Downloading and add signing keys for the repositories",
                    "command": "wget -qO - https://d3g5vo6xdbdb9a.cloudfront.net/GPG-KEY-opendistroforelasticsearch | sudo apt-key add -",
                },
                {
                    "description": "Adding the repositories",
                    "command": 'echo "deb https://d3g5vo6xdbdb9a.cloudfront.net/apt stable main" | sudo tee -a   /etc/apt/sources.list.d/opendistroforelasticsearch.list',
                },
                {
                    "description": "Installing elasting search",
                    "command": "wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-"
                    + self.APT_OSS_version
                    + "-amd64.deb && sudo dpkg -i elasticsearch-oss-"
                    + self.APT_OSS_version
                    + "-amd64.deb",
                },
                {
                    "description": "Installing openDistro",
                    "command": "sudo apt-get update && sudo apt-get install opendistroforelasticsearch -y",
                },
                {
                    "description": "Installing kibana",
                    "command": "sudo apt-get install opendistroforelasticsearch-kibana -y",
                },
                # couldnt figure this out | leaving this for now  as this is not that important
                # {
                #     "description" : "Add message of the day",
                #     "command": " sudo rm -f !(00-*|50-*) && echo  -e 'echo \t\t\tOpen Distro for Elastic Search AMI\necho \t\t\thttps://opendistro.github.io'  | sudo tee /etc/update-motd.d/00-header > /dev/null"
                # }
            ]
        elif self.os == "amazonLinux":
            commands =  [
                {
                    "description": "Creating repository file",
                    "command": "sudo curl https://d3g5vo6xdbdb9a.cloudfront.net/yum/opendistroforelasticsearch-artifacts.repo -o /etc/yum.repos.d/opendistroforelasticsearch-artifacts.repo",
                },
                {
                    "description": "Installing jdk",
                    "command": "sudo amazon-linux-extras install java-openjdk11 -y",
                },
                {
                    "description": "Installing opendistro",
                    "command": "sudo yum install opendistroforelasticsearch-"
                    + self.RPM_package_version
                    + " -y",
                },
                {
                    "description": "Installing kibana",
                    "command": "sudo yum install opendistroforelasticsearch-kibana -y",
                },
                {
                    "description" : "Add message of the day",
                    "command": "echo  -e 'echo \t\t\tOpen Distro for Elastic Search AMI\necho \t\t\thttps://opendistro.github.io'  | sudo tee /etc/update-motd.d/30-banner > /dev/null"
                }
            ]
        #add cleanup commands
        commands.extend(
            [
                {
                    "description" : "Clearing user data",
                    "command": "sudo shred -u /etc/ssh/*_key /etc/ssh/*_key.pub /home/*/.ssh/authorized_keys /root/.ssh/authorized_keys && sudo rm -rf /var/lib/cloud/instances/*"
                }
            ]
        )
        return commands

    def verify_installation(self):
        """
        To verify if ODFE is installed or not
        args: none
        returns:
            "Success" (str) if installation was successful
            "Fail" (str) if installation was unsuccessful
        """
        stdout, stderr = self._run_command(
            "Verifying open distro installation", "sudo systemctl status elasticsearch.service"
        )
        self._pretty_print(stdout, stderr)
        errors = stderr.read().splitlines()
        if len(errors) == 0:
            return "Success"
        else:
            return "Fail"
    
    def install(self):
        """
        installs opendistro on the instance
        args: none
        returns:none
        raises: 
            Exception if installation was unsuccessful
        """
        logging.info("Installing ODFE on " + self.host_name)
        commands = self._get_commands()
        for command in commands:
            stdout, stderr = self._run_command(command["description"], command["command"])
            self._pretty_print(stdout, stderr)
            ##check if the command ran successfully
            exit_code = stdout.channel.recv_exit_status()
            if exit_code != 0:
                error = command["description"] + " failed with error code " + str(exit_code)
                logging.error(error)
                raise Exception(error)
