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
# Test if Elasticsearch logs are in docker logs.

from .fixtures import elasticsearch
import pytest


def test_elasticsearch_logs_are_in_docker_logs(elasticsearch):
    elasticsearch.assert_in_docker_log('o.e.n.Node')
    # eg. elasticsearch1 | [2017-07-04T00:54:22,604][INFO ][o.e.n.Node  ] [docker-test-node-1] initializing ...


def test_info_level_logs_are_in_docker_logs(elasticsearch):
    elasticsearch.assert_in_docker_log('INFO')
