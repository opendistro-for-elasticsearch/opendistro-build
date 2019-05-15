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
# Test if the version of Kibana is correct
# and if the permissions of files are correct

from .constants import version
from .fixtures import kibana


def exclude_browser_files(files):
    '''Return all files that are not part of a browser

    Useful for permission tests, since browsers get installed at runtime and
    can have unexpected ownership, group or mode.
    '''
    # REF: https://github.com/elastic/kibana/blob/fe4609647dd2a7a7fedfb23d63f5886a24eacbe1/x-pack/plugins/reporting/server/browsers/install.js#L41  # noqa
    files = [f for f in files if not f.startswith('/usr/share/kibana/data/phantomjs-')]
    files = [f for f in files if not f.startswith('/usr/share/kibana/data/headless_shell-')]
    return files


def test_kibana_is_the_correct_version(kibana):
    assert version in kibana.stdout_of('kibana --version')


def test_opt_kibana_is_a_symlink_to_usr_share_kibana(kibana):
    assert kibana.stdout_of('realpath /opt/kibana') == '/usr/share/kibana'


def test_all_files_in_optimize_directory_are_owned_by_kibana(kibana):
    bad_files = kibana.stdout_of('find /usr/share/kibana/optimize ! -user kibana').split()
    assert len(bad_files) is 0


def test_all_files_in_kibana_directory_are_gid_zero(kibana):
    bad_files = kibana.stdout_of('find /usr/share/kibana ! -gid 0').split()
    assert len(exclude_browser_files(bad_files)) is 0


def test_all_files_in_kibana_directory_are_writable(kibana):
    bad_files = kibana.stdout_of('find -not -writable').split()
    assert len(bad_files) is 0


def test_all_directories_in_kibana_directory_are_setgid(kibana):
    bad_files = kibana.stdout_of('find /usr/share/kibana -type d ! -perm /g+s').split()
    assert len(exclude_browser_files(bad_files)) is 0


def test_all_files_in_kibana_directory_are_group_writable(kibana):
    bad_files = kibana.stdout_of('find /usr/share/kibana ! -perm /g+w').split()
    assert len(exclude_browser_files(bad_files)) is 0
