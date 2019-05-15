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
# Test if mounted data diretories work.

from .fixtures import elasticsearch
import pytest
import random


def test_es_can_write_to_bind_mounted_datadir(elasticsearch):
    """ datadir paths are relative to the Makefile directory"""
    elasticsearch.assert_bind_mount_data_dir_is_writable(
        datadir1="tests/datadir1",
        datadir2="tests/datadir2",
        datadir_uid=1000,
        datadir_gid=0)


def test_es_can_write_to_bind_mounted_datadir_with_different_uid(elasticsearch):
    """Test the use case where a directory on the host contains data owned by a different UID
    to the default uid (1000) that elasticsearch starts as.
    As long as the host dir was created with gid=0, it should always be writable.
    This can happen in Openshift if the container restarts, as random UIDs are used.
    """
    elasticsearch.assert_bind_mount_data_dir_is_writable(
        datadir1="tests/datadir1",
        datadir2="tests/datadir2",
        datadir_uid=5555,
        datadir_gid=0)


@pytest.mark.skip(reason="breaks with security plugin")
def test_es_can_run_with_random_uid_and_write_to_bind_mounted_datadir(elasticsearch):
    """Test the Openshift Open use case where the Dockerfile USER is overriden
    with one that has uid set to a high random value
    and a host directory with the same uid and gid=0 gets bind-mounted.
    """

    # Pick a random UID value to override `USER` with
    process_uid = random.randint(1000, 65000)
    elasticsearch.assert_bind_mount_data_dir_is_writable(
        datadir1="tests/datadir1",
        datadir2="tests/datadir2",
        process_uid=process_uid,
        datadir_uid=5555,
        datadir_gid=0)
