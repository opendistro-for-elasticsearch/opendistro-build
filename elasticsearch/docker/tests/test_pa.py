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
# Test if opendistro performance analyzer is working properly

import time

from .constants import version
from .fixtures import elasticsearch


def test_CPU_Utilization(elasticsearch):
    metrics = elasticsearch.get_metrics(["CPU_Utilization"], ["sum"])
    assert metrics['fields'][0]['name'] == 'CPU_Utilization'
    assert metrics['fields'][0]['type'] == 'DOUBLE'


def test_restart(elasticsearch):
    """
    Elasticsearch pid is set to 1. The other java process is assumed to be
    performance analyzer. We kill this java process and then assert that a new
    process is started.
    """
    o_pid = get_pa_process_id(elasticsearch)

    elasticsearch.run_command_on_host("kill -9 %s" % o_pid)

    n_pid = get_pa_process_id(elasticsearch)

    assert n_pid != o_pid

    # PA needs some time to restart
    time.sleep(20)

    metrics = elasticsearch.get_metrics(["CPU_Utilization"], ["sum"])

    assert metrics['fields'][0]['name'] == 'CPU_Utilization'
    assert metrics['fields'][0]['type'] == 'DOUBLE'


def get_pa_process_id(elasticsearch):
    processes = elasticsearch.get_java_processes()
    """
    This function assumes there are only 2 java processes running in the
    container. Sleep for 5 seconds and retry if the pa process is not up.
    """

    if len(processes) == 1:
        time.sleep(5)

    processes = elasticsearch.get_java_processes()
    assert len(processes) == 2

    for process in elasticsearch.get_java_processes():
        pid = process["pid"]
        if pid != 1:
            return pid
    assert False
