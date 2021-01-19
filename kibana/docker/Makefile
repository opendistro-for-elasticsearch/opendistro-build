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
# Makefile for building docker images

SHELL=/bin/bash
export PATH := ./bin:./venv/bin:$(PATH)
PYTHON ?= $(shell command -v python3.5 || command -v python3.6)
FIGLET := pyfiglet -w 160 -f puffy

BUILD_TYPE ?= OpenDistroForElasticSearch
BUILD_DATE := $(shell date +'%y.%m.%d')

OPENDISTRO_REGISTRY ?= amazon

ES_VERSION ?= $(shell ../../release-tools/scripts/version-info.sh --es)
OPENDISTRO_VERSION ?= $(shell ../../release-tools/scripts/version-info.sh --od)
OPENDISTRO_PLUGIN_VERSION ?= $(OPENDISTRO_VERSION).0.zip
IMAGE_TAG ?= $(OPENDISTRO_REGISTRY)/opendistro-for-elasticsearch-kibana
ARTIFACTS_URL='https://d3g5vo6xdbdb9a.cloudfront.net/downloads/kibana'

# These are not used for now
OPENDISTRO_PLUGINS ?= opendistro-sql-workbench/opendistro-sql-workbench-$(OPENDISTRO_PLUGIN_VERSION) \
                      opendistro-anomaly-detection/opendistro-anomaly-detection-kibana-$(OPENDISTRO_PLUGIN_VERSION) \
                      opendistro-security/opendistro_security_kibana_plugin-$(OPENDISTRO_PLUGIN_VERSION) \
                      opendistro-alerting/opendistro-alerting-$(OPENDISTRO_PLUGIN_VERSION) \
                      opendistro-index-management/opendistro_index_management_kibana-$(OPENDISTRO_PLUGIN_VERSION)


all: build test

test: lint docker-compose
	$(FIGLET) "test: $(BUILD_TYPE)"; \
	./bin/pytest tests; \

# Run selected test(s). Pass the file name(s) as an environment variable SELECTED_TESTS
test-selected: lint docker-compose
	pyfiglet -w 160 -f puffy "test: selected"; \
	./bin/pytest tests -k "${SELECTED_TESTS}" -s;

lint: venv
	  flake8 tests

build: dockerfile
	docker pull centos:7
	# $(FIGLET) "build: $(BUILD_TYPE)";
	docker build -t $(IMAGE_TAG):$(OPENDISTRO_VERSION) \
	  -f build/kibana/Dockerfile build/kibana; \
    docker tag $(IMAGE_TAG):$(OPENDISTRO_VERSION) $(IMAGE_TAG):$(OPENDISTRO_VERSION);

# Push the image to the dedicated push endpoint
push:
	docker tag $(IMAGE_TAG):$(OPENDISTRO_VERSION) $(IMAGE_TAG):$(OPENDISTRO_VERSION);
	docker push $(IMAGE_TAG):$(OPENDISTRO_VERSION);
	docker rmi $(IMAGE_TAG):$(OPENDISTRO_VERSION);

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

venv: requirements.txt
	test -d venv || virtualenv --python=$$PYTHON3 venv || python3 -m venv venv;\
	pip install -r requirements.txt
	touch venv

# Generate the Dockerfiles from Jinja2 templates.
#dockerfile: venv templates/Dockerfile.j2
dockerfile:
	jinja2 \
	  -D artifacts_url='$(ARTIFACTS_URL)' \
	  -D version_tag='${OPENDISTRO_VERSION}' \
	  -D es_version='$(ES_VERSION)' \
	  -D plugins='${OPENDISTRO_PLUGINS}' \
	  -D build_date='${BUILD_DATE}' \
	  templates/Dockerfile.j2 > build/kibana/Dockerfile; 

# Generate docker-compose files from Jinja2 templates.
docker-compose: venv
	jinja2 \
    -D version_tag='$(OPENDISTRO_VERSION)' \
		-D registry='$(OPENDISTRO_REGISTRY)' \
   templates/docker-compose.yml.j2 > docker-compose.yml

.PHONY: build clean flake8 push pytest test dockerfile docker-compose
