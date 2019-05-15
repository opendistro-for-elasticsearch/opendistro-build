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
# Customized retry settings

from .exceptions import DockerStackError, ExplicitRetryError
from requests.exceptions import ConnectionError, TooManyRedirects


retriable_exceptions = [
    ExplicitRetryError,
    DockerStackError,
    ConnectionError,
    ConnectionResetError,
    TooManyRedirects
]


def is_retriable(exception):
    for retriable in retriable_exceptions:
        if isinstance(exception, retriable):
            return True
    return False


retry_settings = {
    'stop_max_delay': 120000,
    'wait_exponential_multiplier': 100,
    'wait_exponential_max': 1000,
    'retry_on_exception': is_retriable
}
