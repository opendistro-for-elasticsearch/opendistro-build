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
# Test the user & group running in docker is the currect one

from .fixtures import elasticsearch


def test_group_properties(host, elasticsearch):
    group = host.group('elasticsearch')
    assert group.exists
    assert group.gid == 1000


def test_user_properties(host, elasticsearch):
    user = host.user('elasticsearch')
    assert user.uid == 1000
    assert user.gid == 1000
    assert user.home == '/usr/share/elasticsearch'
    assert user.shell == '/bin/bash'
