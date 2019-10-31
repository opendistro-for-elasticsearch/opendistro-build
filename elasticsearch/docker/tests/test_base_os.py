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
# Test if Elasticsearch is running in centos7

from .fixtures import elasticsearch


def test_base_os(host):
    assert host.system_info.distribution == 'centos'
    assert host.system_info.release == '7'


def test_no_core_files_exist_in_root(host):
    core_file_check_cmdline = 'ls -l /core*'

    assert host.run(core_file_check_cmdline).exit_status != 0


def test_all_elasticsearch_files_are_gid_0(host):
    check_for_files_with_gid_0_command = (
        "cd /usr/share && "
        "find ./elasticsearch ! -gid 0 | "
        "egrep '.*'"
    )

    assert host.run(check_for_files_with_gid_0_command).exit_status != 0


def test_supervisord_log_dir_is_gid_0_and_writable_for_group(host):
    check_supervisor_dir_permissions_command = (
        "find /usr/share -name supervisor -gid 0 -perm -g+w | "
        "egrep '.*'"
    )

    assert host.run(check_supervisor_dir_permissions_command).exit_status == 0
