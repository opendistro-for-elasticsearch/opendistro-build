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
# Makefile for building & testing elasticsearch docker image.

SHELL=/bin/bash
OPENDISTRO_REPOSITORY ?= amazon/opendistro-for-elasticsearch
export PATH := ./bin:./venv/bin:$(PATH)

# Determine the version to build. Override by setting ELASTIC_VERSION env var.
ELASTIC_VERSION ?= $(shell ../../bin/version-info --es)
OPENDISTRO_VERSION ?= $(shell ../../bin/version-info --od)
OPENDISTRO_PLUGIN_VERSION ?= $(OPENDISTRO_VERSION).0.zip

#ENDS_WITH := SNAPSHOT
BUILD_TYPE := artifacts
ARTIFACT_REPO_URL ?= https://d3g5vo6xdbdb9a.cloudfront.net/downloads

PUSH_TAG ?= OPENDISTRO_VERSION
BUILD_DATE := $(shell date +'%y.%m.%d')
BUST_CACHE ?= $(shell date +'%s')

# Snapshot not used at the moment.
# ifeq ($(patsubst %$(ENDS_WITH),,$(lastword $(ELASTIC_VERSION))),)
#         BUILD_TYPE := snapshots
#         OPENDISTRO_PLUGIN_VERSION := $(OPENDISTRO_PLUGIN_VERSION)-SNAPSHOT
#         ARTIFACT_REPO_URL := https://d1mbdmiycff3en.cloudfront.net/downloads
#         OPENDISTRO_VERSION := $(OPENDISTRO_VERSION)-SNAPSHOT
 
# endif

ELASTIC_ARTIFACTS_URL ?= https://$(BUILD_TYPE).elastic.co/downloads/elasticsearch

# This is not used for now
PLUGIN_URL_PATHS ?= opendistro_sql-$(OPENDISTRO_PLUGIN_VERSION) \
                    opendistro_alerting-$(OPENDISTRO_PLUGIN_VERSION) \
                    opendistro-job-scheduler-$(OPENDISTRO_PLUGIN_VERSION) \
                    opendistro_security-$(OPENDISTRO_PLUGIN_VERSION) \
                    opendistro_performance_analyzer-$(OPENDISTRO_PLUGIN_VERSION) \
                    opendistro_index_management-$(OPENDISTRO_PLUGIN_VERSION) \
                    opendistro-knn-$(OPENDISTRO_PLUGIN_VERSION) \
                    opendistro-anomaly-detection-$(OPENDISTRO_PLUGIN_VERSION)

IMAGE_TAG ?= $(OPENDISTRO_REPOSITORY)
# When invoking docker-compose, use an extra config fragment to map Elasticsearch's
# listening port to the docker host.
DOCKER_COMPOSE := docker-compose \
	-f docker-compose.yml \
	-f docker-compose.hostports.yml

.PHONY: all dockerfile docker-compose test test-build lint clean pristine run run-single run-cluster build release-manager push

# Default target, build *and* run tests
all: build test

# Test specified versions without building
test: lint docker-compose
	docker run --rm -v "$(PWD):/mnt" bash rm -rf /mnt/tests/datadir1 /mnt/tests/datadir2
	pyfiglet -w 160 -f puffy "test: single"; \
	VERSION_TAG=${OPENDISTRO_VERSION} IMAGE_REPO=${IMAGE_TAG} ./bin/pytest --single-node tests; \
	pyfiglet -w 160 -f puffy "test: multi"; \
	VERSION_TAG=${OPENDISTRO_VERSION} IMAGE_REPO=${IMAGE_TAG} ./bin/pytest tests;

test-cluster: lint docker-compose
	docker run --rm -v "$(PWD):/mnt" bash rm -rf /mnt/tests/datadir1 /mnt/tests/datadir2
	pyfiglet -w 160 -f puffy "test: multi"; \
	VERSION_TAG=${OPENDISTRO_VERSION} IMAGE_REPO=${IMAGE_TAG} ./bin/pytest tests;

test-cluster-selected: lint docker-compose
	docker run --rm -v "$(PWD):/mnt" bash rm -rf /mnt/tests/datadir1 /mnt/tests/datadir2
	pyfiglet -w 160 -f puffy "test: selected"; \
	VERSION_TAG=${OPENDISTRO_VERSION} IMAGE_REPO=${IMAGE_TAG} ./bin/pytest tests -k "${SELECTED_TESTS}" -s;

# Run selected test(s). Pass the file name(s) as an environment variable SELECTED_TESTS
test-single-selected: lint docker-compose
	docker run --rm -v "$(PWD):/mnt" bash rm -rf /mnt/tests/datadir1 /mnt/tests/datadir2
	pyfiglet -w 160 -f puffy "test: selected"; \
	VERSION_TAG=${OPENDISTRO_VERSION} IMAGE_REPO=${IMAGE_TAG} ./bin/pytest --single-node tests -k "${SELECTED_TESTS}" -s;

# Build test
test-build: lint build docker-compose

lint: venv
	flake8 tests

clean:
	if [[ -f "docker-compose.yml" ]]; then \
	  docker-compose -f docker-compose.yml down && docker-compose -f docker-compose.yml rm -f -v; \
	fi; \
	rm -f docker-compose.yml; \
	rm -f tests/docker-compose.yml; \
	rm -f build/elasticsearch/Dockerfile; 

pristine: clean
	docker rmi -f $(IMAGE_TAG):$(OPENDISTRO_VERSION); 
	rm -rf venv

run: run-single

run-single: docker-compose
	DATA_VOLUME1=esdata1 $(DOCKER_COMPOSE) -f docker-compose.single.yml up elasticsearch1

run-cluster: docker-compose
	DATA_VOLUME1=esdata1 DATA_VOLUME2=esdata2 $(DOCKER_COMPOSE) -f docker-compose.cluster.yml up elasticsearch1 elasticsearch2

build: clean venv dockerfile docker-compose
	-pyfiglet -f puffy -w 160 "Building ES "; \
	docker build -t $(IMAGE_TAG):$(OPENDISTRO_VERSION) -f build/elasticsearch/Dockerfile build/elasticsearch || \
	docker tag $(IMAGE_TAG):$(OPENDISTRO_VERSION) $(IMAGE_TAG):$(OPENDISTRO_VERSION)

# Push the images to docker endpoint
push:  
	docker tag $(IMAGE_TAG):$(OPENDISTRO_VERSION) $(IMAGE_TAG):$(PUSH_TAG); \
	echo; echo "Pushing $(IMAGE_TAG):$(PUSH_TAG)"; echo; \
	docker push $(IMAGE_TAG):$(PUSH_TAG); \

# The tests are written in Python. Make a virtualenv to handle the dependencies.
venv: requirements.txt
	@if [ -z $$PYTHON3 ]; then\
	    PY3_MINOR_VER=`python3 --version 2>&1 | cut -d " " -f 2 | cut -d "." -f 2`;\
	    if (( $$PY3_MINOR_VER < 5 )); then\
		echo "Couldn't find python3 in \$PATH that is >=3.5";\
		echo "Please install python3.5 or later or explicity define the python3 executable name with \$PYTHON3";\
	        echo "Exiting here";\
	        exit 1;\
	    else\
		export PYTHON3="python3.$$PY3_MINOR_VER";\
	    fi;\
	fi;\
	test -d venv || virtualenv --python=$$PYTHON3 venv || python3 -m venv venv;\
	pip install -r requirements.txt;\
	touch venv;\

# Generate the Dockerfiles from a Jinja2 template.
dockerfile: venv templates/Dockerfile.j2
	jinja2 \
		-D elastic_version='$(ELASTIC_VERSION)' \
		-D plugin_url_paths='${PLUGIN_URL_PATHS}' \
		-D artifact_repo_url='${ARTIFACT_REPO_URL}' \
		-D elastic_artifacts_url='${ELASTIC_ARTIFACTS_URL}' \
		-D version_tag='${OPENDISTRO_VERSION}' \
		-D build_date='${BUILD_DATE}' \
		-D bust_cache='${BUST_CACHE}' \
		-D artifacts_dir='${ARTIFACTS_DIR}' \
		templates/Dockerfile.j2 > build/elasticsearch/Dockerfile; 

# Generate docker-compose and tests/docker-compose fragment files
# from a Jinja2 template.
docker-compose: venv templates/docker-compose.yml.j2 templates/docker-compose-fragment.yml.j2
	jinja2 \
	  -D elasticsearch_repository='$(OPENDISTRO_REPOSITORY)' \
	  -D version_tag='$(OPENDISTRO_VERSION)' \
	  templates/docker-compose.yml.j2 > docker-compose.yml; \
	jinja2 \
	  templates/docker-compose-fragment.yml.j2 > tests/docker-compose.yml; 
