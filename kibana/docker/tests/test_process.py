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
# Test process related settings

from .constants import version
from .fixtures import kibana


def test_process_is_pid_1(kibana):
    assert kibana.process.pid == 1


def test_process_is_running_as_the_correct_user(kibana):
    assert kibana.process.user == 'kibana'


def test_default_environment_contains_no_kibana_config(kibana):
    acceptable_vars = [
        'ELASTIC_CONTAINER', 'HOME', 'HOSTNAME',
        'TERM', 'PATH', 'PWD',
        'SHLVL', '_', 'ELASTICSEARCH_HOSTS'
    ]
    for var in kibana.environment.keys():
        assert var in acceptable_vars
