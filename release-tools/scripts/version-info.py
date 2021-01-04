#!/usr/bin/env python
#
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

###### Information ############################################################################
# Name:          version-info.py
# Maintainer:    ODFE Infra Team
# Language:      Python
#
# About:         Print the ES/ODFE/VersionCut related information and values
#                as defined in the 'manifest.yml' file
#
# Usage:         [python] ./version-info.py $VERSION_TYPE
#                $VERSION_TYPE (required): --od | --od-prev | --od-next
#                                          --es | --es-prev | --es-next
#
# Requirements:  Need to install PyYAML with pip
#
# Starting Date: 2019-05-15
# Modified Date: 2020-11-16
###############################################################################################

import sys
import yaml
from os import environ


def get_hard_coded_version(key1, key2):
    version_file = sys.path[0] + '/' + 'manifest.yml'
    version_info = yaml.load(open(version_file), yaml.Loader)
    return version_info['versions'][key1][key2]


def get_es_version(user_param):
    if 'ES_VERSION' in environ:
        # Then the user has forced the version. Do as they say!
        return(environ['ES_VERSION'])
    else:
        if user_param == '--es-prev':
          return(get_hard_coded_version('ES', 'previous'))
        elif user_param == '--es-next':
          return(get_hard_coded_version('ES', 'next'))
        else:
          return(get_hard_coded_version('ES', 'current'))

def get_od_version(user_param):
    if 'OD_VERSION' in environ:
        # Then the user has forced the version. Do as they say!
        return(environ['OD_VERSION'])
    else:
        if user_param == '--od-prev':
          return(get_hard_coded_version('ODFE', 'previous'))
        elif user_param == '--od-next':
          return(get_hard_coded_version('ODFE', 'next'))
        else:
          return(get_hard_coded_version('ODFE', 'current'))

def get_version_cut(user_param):
    if user_param == '--is-cut':
      return(get_hard_coded_version('versionCut', 'is_cut'))

if __name__ == '__main__':
    # Provide a shell compatible interface, defaults to OD version
    if len(sys.argv) == 2 :
        arg_value = sys.argv[1]
        if (arg_value == '--es') or (arg_value == '--es-prev') or (arg_value == '--es-next'):
            print(get_es_version(arg_value))
        elif (arg_value == '--od') or (arg_value == '--od-prev') or (arg_value == '--od-next'):
            print(get_od_version(arg_value))
        else:
          raise Exception('invalid argument, use --es OR --od ',
                          'OR --es-prev OR --od-prev ',
                          'OR --es-next OR --od-next ')
    else:
      raise Exception('invalid argument, use --es OR --od ',
                      'OR --es-prev OR --od-prev ',
                      'OR --es-next OR --od-next ')


