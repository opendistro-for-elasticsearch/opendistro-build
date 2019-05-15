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
# Test user related settings

from .fixtures import kibana


def test_group_properties(host):
    group = host.group('kibana')
    assert group.exists
    assert group.gid == 1000


def test_user_properties(host):
    user = host.user('kibana')
    assert user.uid == 1000
    assert user.gid == 1000
    assert user.home == '/usr/share/kibana'
    assert user.shell == '/bin/bash'


def test_default_user_is_kibana(kibana):
    assert kibana.stdout_of('whoami') == 'kibana'


def test_that_the_user_home_directory_is_usr_share_kibana(kibana):
    assert kibana.environment['HOME'] == '/usr/share/kibana'
