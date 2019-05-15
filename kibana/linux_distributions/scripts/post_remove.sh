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
# Post-remove script to clean up the environment.

set -e

REMOVE_USER_AND_GROUP=false
REMOVE_DIRS=false

case $1 in
  # Includes cases for all valid arguments, exit 1 otherwise
  # Setup for Debian environment
  purge)
    REMOVE_USER_AND_GROUP=true
    REMOVE_DIRS=true
  ;;
  remove)
    REMOVE_DIRS=true
  ;;

  failed-upgrade|abort-install|abort-upgrade|disappear|upgrade|disappear)
  ;;

  # Setup for RPMs environment
  0)
    REMOVE_USER_AND_GROUP=true
    REMOVE_DIRS=true
  ;;

  1)
  ;;

  *)
      echo "post remove script called with unknown argument \`$1'" >&2
      exit 1
  ;;
esac

if [ "$REMOVE_USER_AND_GROUP" = "true" ]; then
  if getent passwd "<%= user %>" >/dev/null; then
    userdel "<%= user %>"
  fi

  if getent group "<%= group %>" >/dev/null; then
    groupdel "<%= group %>"
  fi
fi

if [ "$REMOVE_DIRS" = "true" ]; then
  if [ -d "<%= optimizeDir %>" ]; then
    rm -rf "<%= optimizeDir %>"
  fi

  if [ -d "<%= pluginsDir %>" ]; then
    rm -rf "<%= pluginsDir %>"
  fi

  if [ -d "<%= configDir %>" ]; then
    rmdir --ignore-fail-on-non-empty "<%= configDir %>"
  fi

  if [ -d "<%= dataDir %>" ]; then
    rmdir --ignore-fail-on-non-empty "<%= dataDir %>"
  fi
fi
