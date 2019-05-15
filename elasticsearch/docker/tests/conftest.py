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

# Description:
# Configuration used for testing open distro for elasticsearch in docker

from subprocess import run
import os
import pytest


def pytest_addoption(parser):
    """Customize testinfra with config options via cli args"""

    # By default run tests in clustered mode, but allow dev mode with --single-node"""
    parser.addoption('--single-node', action='store_true',
                     help='non-clustered version')

    # Bind-mount a user specified dir for the data dir
    parser.addoption('--mount-datavolume1', action='store',
                     help='The host dir to be bind-mounted on data dir for the first node')

    # Bind-mount a user specified dir for the data dir
    parser.addoption('--mount-datavolume2', action='store',
                     help='The host dir to be bind-mounted on data dir for the second node')

    # Let us override the Dockerfile's USER; akin to specifying `--user` in the docker run.
    parser.addoption('--process-uid', action='store',
                     help='Used to override the Dockerfile\'s USER')


def pytest_configure(config):
    # Named volumes used by default for persistence of each container
    (datavolume1, datavolume2) = ("esdata1", "esdata2")
    # Our default is not to override uid; empty strings for --user are ignored by Docker.
    process_uid = ''
    compose_flags = ('-f docker-compose.yml -f tests/docker-compose.yml up -d').split(' ')

    if config.getoption('--single-node'):
        compose_flags.append('elasticsearch1')

    # Use a host dir for the data volume of Elasticsearch, if specified
    if config.getoption('--mount-datavolume1'):
        datavolume1 = config.getoption('--mount-datavolume1')
    if config.getoption('--mount-datavolume2'):
        datavolume2 = config.getoption('--mount-datavolume2')
    if config.getoption('--process-uid'):
        process_uid = config.getoption('--process-uid')

    env_vars = os.environ
    env_vars['DATA_VOLUME1'] = datavolume1
    env_vars['DATA_VOLUME2'] = datavolume2
    env_vars['PROCESS_UID'] = process_uid

    run(['docker-compose'] + compose_flags, env=env_vars)


def pytest_unconfigure(config):
    run(['docker-compose', '-f', 'docker-compose.yml', 'down', '-v'])
    run(['docker-compose', '-f', 'docker-compose.yml', 'rm', '-f', '-v'])
