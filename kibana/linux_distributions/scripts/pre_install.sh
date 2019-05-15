#!/bin/sh

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
# Pre-install script to stop kibanan.service if it's running.

set -e

if command -v systemctl >/dev/null && systemctl is-active kibana.service >/dev/null; then
    systemctl --no-reload stop kibana.service
elif [ -x /etc/init.d/kibana ]; then
    if command -v invoke-rc.d >/dev/null; then
        invoke-rc.d kibana stop
    elif command -v service >/dev/null; then
        service kibana stop
    else
        /etc/init.d/kibana stop
    fi
fi
