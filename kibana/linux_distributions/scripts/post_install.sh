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
# Post-install script to set up the environment.

set -e

case $1 in
  # Setup for Debian environment
  configure)
    if ! getent group "<%= group %>" >/dev/null; then
      addgroup --quiet --system "<%= group %>"
    fi

    if ! getent passwd "<%= user %>" >/dev/null; then
      adduser --quiet --system --no-create-home --disabled-password \
      --ingroup "<%= group %>" --shell /bin/false "<%= user %>"
    fi
  ;;
  abort-deconfigure|abort-upgrade|abort-remove)
  ;;

  # Setup for RPMs environment
  1|2)
    if ! getent group "<%= group %>" >/dev/null; then
      groupadd -r "<%= group %>"
    fi

    if ! getent passwd "<%= user %>" >/dev/null; then
      useradd -r -g "<%= group %>" -M -s /sbin/nologin \
      -c "kibana service user" "<%= user %>"
    fi
  ;;

  *)
      echo "post install script called with unknown argument \`$1'" >&2
      exit 1
  ;;
esac

chown -R <%= user %>:<%= group %> <%= optimizeDir %> || echo no optimize folder
chown <%= user %>:<%= group %> <%= dataDir %>
chown <%= user %>:<%= group %> <%= pluginsDir %>
