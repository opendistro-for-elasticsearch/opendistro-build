#!/bin/bash

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

ES_HOME=`pwd`
##Security Plugin
bash $ES_HOME/plugins/opendistro_security/tools/install_demo_configuration.sh -y -i -s

##Perf Plugin
chmod 755 $ES_HOME/plugins/opendistro_performance_analyzer/pa_bin/performance-analyzer-agent
chmod -R 755 /dev/shm
echo "done security"
PA_AGENT_JAVA_OPTS="-Dlog4j.configurationFile=$ES_HOME/plugins/opendistro_performance_analyzer/pa_config/log4j2.xml \
              -Xms64M -Xmx64M -XX:+UseSerialGC -XX:CICompilerCount=1 -XX:-TieredCompilation -XX:InitialCodeCacheSize=4096 \
              -XX:InitialBootClassLoaderMetaspaceSize=30720 -XX:MaxRAM=400m"

ES_MAIN_CLASS="com.amazon.opendistro.elasticsearch.performanceanalyzer.PerformanceAnalyzerApp" \
ES_ADDITIONAL_CLASSPATH_DIRECTORIES=plugins/opendistro_performance_analyzer \
ES_JAVA_OPTS=$PA_AGENT_JAVA_OPTS

if ! grep -q '## OpenDistro Performance Analyzer' $ES_HOME/config/jvm.options; then
   CLK_TCK=`/usr/bin/getconf CLK_TCK`
   echo >> $ES_HOME/config/jvm.options
   echo '## OpenDistro Performance Analyzer' >> $ES_HOME/config/jvm.options
   echo "-Dclk.tck=$CLK_TCK" >> $ES_HOME/config/jvm.options
   echo "-Djdk.attach.allowAttachSelf=true" >> $ES_HOME/config/jvm.options
   echo "-Djava.security.policy=$ES_HOME/plugins/opendistro_performance_analyzer/pa_config/es_security.policy" >> $ES_HOME/config/jvm.options
fi
echo "done plugins"

#Move k-NN library in the /usr/lib
echo "Fetching kNN library"
FILE=/usr/lib/libKNNIndexV1_7_3_6.so
if sudo test -f "$FILE"; then
    echo "FILE EXISTS: removing $FILE"
    sudo rm $FILE
fi

sudo cp $ES_HOME/plugins/opendistro-knn/knn-lib/libKNNIndexV1_7_3_6.so /usr/lib 

##Start Elastic Search
bash $ES_HOME/bin/elasticsearch "$@"
