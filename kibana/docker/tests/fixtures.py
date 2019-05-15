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
# This is a test fixture, which provides a fixed baseline upon which tests can reliably and repeatedly execute
# In particular, this file provides a Kibana object with all things configured
# so that tests can use this to communicate with Kibana.

import requests
import json
import urllib
import os
from retrying import retry
from pytest import fixture, config
from subprocess import run, PIPE
from .retry import retry_settings


@fixture
def kibana(host):
    class Kibana(object):
        def __init__(self):
            self.version = run(['../bin/version-info', '--es'], stdout=PIPE).stdout.decode().strip()
            self.url = 'http://localhost:5601'
            self.process = host.process.get(comm='node')
            self.environment = dict(
                [line.split('=', 1) for line in self.stdout_of('env').split('\n')]
            )
            self.tag = run(['../bin/version-info', '--od'], stdout=PIPE).stdout.decode().strip()
            self.image = config.getoption('--image') + self.tag
            self.docker_metadata = json.loads(
                run(['docker', 'inspect', self.image], stdout=PIPE).stdout.decode())[0]

        @retry(**retry_settings)
        def get(self, location='/', allow_redirects=True):
            """GET a page from Kibana."""
            url = urllib.parse.urljoin(self.url, location)
            return requests.get(url)

        def stdout_of(self, command):
            result = host.run(command)
            assert result.rc is 0
            return result.stdout.strip()

    return Kibana()
