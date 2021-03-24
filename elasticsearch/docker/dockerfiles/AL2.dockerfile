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

# This dockerfile generates an AmazonLinux-based image containing an OpenDistro for Elasticsearch (ODFE) installation.
# It assumes that the working directory contains four files: an ODFE tarball (odfe.tgz), log4j2.properties, elasticsearch.yml, docker-entrypoint.sh.
# Build arguments:
#   ODFE_VERSION: Required. Used to label the image.
#   BUILD_DATE: Required. Used to label the image. Should be in the form 'yyyy-mm-ddThh:mm:ssZ', i.e. a date-time from https://tools.ietf.org/html/rfc3339. The timestamp must be in UTC.
#   UID: Optional. Specify the elasticsearch userid. Defaults to 1000.
#   GID: Optional. Specify the elasticsearch groupid. Defaults to 1000.

FROM amazonlinux:2 AS build

ARG ODFE_VERSION
ARG BUILD_DATE
ARG UID=1000
ARG GID=1000

# Install the tools we need: tar and gzip to unpack the ODFE tarball, and shadow-utils to give us `groupadd` and `useradd`.
RUN yum install -y tar gzip shadow-utils

# Create an elasticsearch user, group, and directory
RUN groupadd -g $GID elasticsearch && \
    adduser -u $UID -g $GID -d /usr/share/elasticsearch elasticsearch

RUN mkdir /tmp/elasticsearch

COPY odfe.tgz /tmp/elasticsearch/odfe.tgz

RUN tar -xzf /tmp/elasticsearch/odfe.tgz -C /usr/share/elasticsearch --strip-components=1
COPY log4j2.properties /usr/share/elasticsearch/config/
COPY elasticsearch.yml /usr/share/elasticsearch/config/
COPY docker-entrypoint.sh /usr/share/elasticsearch/

# TODO: Temporary, until we get changes to opendistro-tar-install.sh built into ODFE
# Once https://github.com/opendistro-for-elasticsearch/opendistro-build/pull/697 is built into the next version of ODFE and we have a tarball we can delete the next three lines
COPY opendistro-onetime-setup.sh /usr/share/elasticsearch/
COPY opendistro-run.sh /usr/share/elasticsearch/
COPY opendistro-tar-install.sh /usr/share/elasticsearch/

RUN /usr/share/elasticsearch/opendistro-onetime-setup.sh

# Clean up
RUN rm -rf /tmp/elasticsearch
RUN chown -R $UID:$GID /usr/share/elasticsearch

# Set up the entry point, working directory, exposed ports etc
USER $UID
WORKDIR /usr/share/elasticsearch
# Expose ports for the elasticsearch service (9200 for HTTP and 9300 for internal transport) and performance analyzer (9600 for the agent and 9650 for the root cause analysis component)
EXPOSE 9200 9300 9600 9650

ENTRYPOINT ["/usr/share/elasticsearch/docker-entrypoint.sh"]
CMD ["eswrapper"]

# Label
LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.name="opendistroforelasticsearch" \
  org.label-schema.version="$ODFE_VERSION" \
  org.label-schema.url="https://opendistro.github.io" \
  org.label-schema.vcs-url="https://github.com/opendistro-for-elasticsearch/opendistro-build" \
  org.label-schema.license="Apache-2.0" \
  org.label-schema.vendor="Amazon" \
  org.label-schema.build-date="$BUILD_DATE"
