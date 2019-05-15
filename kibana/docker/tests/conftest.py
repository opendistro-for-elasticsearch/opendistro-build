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
# Configuration used for testing Kibana in docker

import requests

from subprocess import run
from retrying import retry
from .exceptions import ExplicitRetryError
from .retry import retry_settings


def docker_compose(config, *args):
    compose_flags = '-f docker-compose.yml'.split(' ')
    run(['docker-compose'] + compose_flags + list(args))


def pytest_addoption(parser):
    """Customize testinfra with config options via cli args"""
    # Let us specify which docker-compose-(image_flavor).yml file to use
    parser.addoption('--image', action='store', default='amazon/opendistro-for-elasticsearch-kibana:',
                     help='Docker image source')


@retry(**retry_settings)
def wait_for_kibana():
    response = requests.get('http://localhost:5601/')
    if response.status_code != requests.codes.ok:
        raise ExplicitRetryError


def pytest_configure(config):
    docker_compose(config, 'up', '-d')
    wait_for_kibana()


def pytest_unconfigure(config):
    docker_compose(config, 'down', '-v')
    docker_compose(config, 'rm', '-f', '-v')
