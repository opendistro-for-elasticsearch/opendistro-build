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

echo "DEPRECATION NOTICE: opendistro-tar-install.sh is deprecated and will be removed in a future release. You should invoke opendistro-onetime-setup.sh when you install OpenDistro for Elasticsearch, and opendistro-run.sh when you want to start your node."

./opendistro-onetime-setup.sh
./opendistro-run.sh "$@"
