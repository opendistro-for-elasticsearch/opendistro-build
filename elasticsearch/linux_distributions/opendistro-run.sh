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

ES_HOME=`dirname $(realpath $0)`; cd $ES_HOME
ES_KNN_LIB_DIR=$ES_HOME/plugins/opendistro-knn/knn-lib

function isDarwin {
    echo "$OSTYPE" | grep -qi "darwin"
}

# Set up LD_LIBRARY_PATH (for *nix) or JAVA_LIBRARY_PATH (for macOS) so we can find the kNN native library
# Obviously we only do this if knn is installed
if [ -e "$ES_KNN_LIB_DIR" ]; then
   echo "Looking for k-NN libraries"

   FILE=`ls $ES_KNN_LIB_DIR/libKNNIndex*.so`
   if test -f "$FILE"; then
       echo "Found: $FILE"
   else
       echo "Could not find k-NN libraries"
       exit 1
   fi

   if isDarwin; then
       export JAVA_LIBRARY_PATH=$JAVA_LIBRARY_PATH:$ES_KNN_LIB_DIR
       echo "Updated JAVA_LIBRARY_PATH to $JAVA_LIBRARY_PATH"
   else
       export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ES_KNN_LIB_DIR
       echo "Updated LD_LIBRARY_PATH to $LD_LIBRARY_PATH"
   fi
fi

##Start Elastic Search
bash $ES_HOME/bin/elasticsearch "$@"
