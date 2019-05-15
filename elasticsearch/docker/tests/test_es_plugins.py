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
# Test if all the open distro plugins are installed

from .fixtures import elasticsearch
import pytest
from requests import codes


def test_RequiredPlugins_are_installed(elasticsearch):
    # Ensure all required plugins are present on all nodes
    for nodeplugins in elasticsearch.get_node_plugins():
        plugin_classnames = [plugin['classname'] for plugin in nodeplugins]
        assert 'com.amazon.opendistro.elasticsearch.performanceanalyzer.PerformanceAnalyzerPlugin' in plugin_classnames
        assert 'com.amazon.opendistroforelasticsearch.alerting.AlertingPlugin' in plugin_classnames
        assert 'com.amazon.opendistroforelasticsearch.sql.plugin.SqlPlug' in plugin_classnames
        assert 'com.amazon.opendistroforelasticsearch.security.OpenDistroSecurityPlugin' in plugin_classnames
