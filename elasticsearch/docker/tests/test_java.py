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
# Test if all the Java related stuff is working

import re


def test_java_is_runnable_via_java_home_env_var(host):
    assert host.run('$JAVA_HOME/bin/java -version').exit_status == 0


def test_java_major_version(host):
    version = host.run('$JAVA_HOME/bin/java -version').stderr
    regexp = r"openjdk version \"11((\.0)*\.[1-9][0-9]*)*"
    assert re.match(regexp, version)


def test_java_uses_the_os_provided_keystore(host):
    realpath = host.run('realpath $JAVA_HOME/lib/security/cacerts').stdout.strip()
    assert realpath == '/etc/pki/ca-trust/extracted/java/cacerts'


def test_amazon_ca_certs_are_in_the_keystore(host):
    cmd = '$JAVA_HOME/bin/keytool -cacerts -storepass changeit -list | grep trustedCertEntry'
    certs = host.run(cmd).stdout.split('\n')
    assert any(['amazonrootca' in cert for cert in certs])
