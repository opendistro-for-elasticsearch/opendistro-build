#!/bin/bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

# This script performs one-time setup for the Open Distro for ElasticSearch tarball distribution.
# It installs a demo security config and sets up the performance analyzer

ES_HOME=`dirname $(realpath $0)`; cd $ES_HOME

##Security Plugin
bash $ES_HOME/plugins/opendistro_security/tools/install_demo_configuration.sh -y -i -s

##Perf Plugin
chmod 755 $ES_HOME/plugins/opendistro-performance-analyzer/pa_bin/performance-analyzer-agent
chmod -R 755 /dev/shm
chmod 755 $ES_HOME/bin/performance-analyzer-agent-cli

if ! grep -q '## OpenDistro Performance Analyzer' $ES_HOME/config/jvm.options; then
   CLK_TCK=`/usr/bin/getconf CLK_TCK`
   echo >> $ES_HOME/config/jvm.options
   echo '## OpenDistro Performance Analyzer' >> $ES_HOME/config/jvm.options
   echo "-Dclk.tck=$CLK_TCK" >> $ES_HOME/config/jvm.options
   echo "-Djdk.attach.allowAttachSelf=true" >> $ES_HOME/config/jvm.options
   echo "-Djava.security.policy=$ES_HOME/plugins/opendistro-performance-analyzer/pa_config/es_security.policy" >> $ES_HOME/config/jvm.options
fi
