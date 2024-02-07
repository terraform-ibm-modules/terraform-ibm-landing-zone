# -*- mode:makefile; coding:utf-8 -*-

CONFIG_ENV:= common-dev-assets/module-assets/config.env
COMMON_DEV_ASSETS_CONFIG_ENV:= module-assets/config.env
ifneq ("$(wildcard $(CONFIG_ENV))","")
	include $(CONFIG_ENV)
else
ifneq ("$(wildcard $(COMMON_DEV_ASSETS_CONFIG_ENV))","")
	include $(COMMON_DEV_ASSETS_CONFIG_ENV)
endif
endif
export

# explicitly tell Make these commands not associated with files
.PHONY: all dependency-install-darwin-linux dependency-pre-commit docker-pull docker-run pre-commit pre-commit-no-terraform go-mod-tidy run-tests run-tests-local run-go-module-tests renovate-sweeper netrc ghe-netrc

#
# simply expanded variables
#

IMAGE := ${IMAGE_NAME}:stable

ifeq ($(OS),Windows_NT)     # is Windows_NT on XP, 2000, 7, Vista, 10...
    detected_OS := Windows
else
    detected_OS := $(shell uname)  # same as "uname -s"
endif

.DEFAULT_GOAL = dependency-pre-commit
ifneq (,$(filter $(detected_OS), Darwin Linux))
	.DEFAULT_GOAL = all
endif

ifndef DOCKER_ENV
	DOCKER_ENV := common-dev-assets/module-assets/docker.env
endif

ifndef GO_TEST_DIR
	GO_TEST_DIR := tests
endif

ifndef GO_MOD_DIR
	GO_MOD_DIR := tests
endif

ifndef RUN
	RUN := ''
endif

ifndef CONTAINER_RUNTIME
	CONTAINER_RUNTIME := 'docker'
endif

ifneq (,$(findstring github.ibm.com,$(shell git config --get remote.origin.url)))
	GHE := 'true'
endif

#
# install dependencies
#

all: dependency-install-darwin-linux dependency-pre-commit

dependency-install-darwin-linux:
	./ci/install-deps.sh

dependency-pre-commit:
	pre-commit install

#
# docker
#

docker-pull:
	${CONTAINER_RUNTIME} pull "${DOCKER_REGISTRY}/$(IMAGE)"

docker-run:
	@# create all of the directories + files we are mounting if they do not already exist to prevent "Error response from daemon: error while creating mount source path"
	@mkdir -p ~/.ssh
	@touch ~/.netrc ~/.gitconfig
	@# Mount into /tmp (as read only) so files can be moved and permissions updated for root user
	@${CONTAINER_RUNTIME} run -it -v $$(pwd):/mnt \
		--platform linux/amd64 \
		-v ~/.ssh:/tmp/.ssh:ro \
		-v ~/.netrc:/tmp/.netrc:ro \
		-v ~/.gitconfig:/tmp/.gitconfig:ro \
		${DOCKER_REGISTRY}/$(IMAGE) \
		bash -c "cp -R /tmp/.ssh /root && \
			 cp /tmp/.netrc /root/.netrc && \
			 cp /tmp/.gitconfig /etc/gitconfig && \
			 chown -R root /root/.ssh /root/.netrc /etc/gitconfig && \
			 chgrp -R root /root/.ssh /root/.netrc && \
 			 git config --global --add safe.directory '*' && \
 			 bash"

#
# pre-commit
#

# pre-commit for repos with terraform code
pre-commit: ghe-netrc
	@echo "Running terraform init .."
	@terraform init
	@echo
	@echo "Running terragrunt run-all init .."
	@terragrunt run-all init || echo 'Ignoring failure incase this is a non terragrunt project'
	@echo "Running pre-commit hooks .."
	@pre-commit run --all-files

# pre-commit for non-terraform repos
pre-commit-no-terraform:
	@echo "Running pre-commit hooks .."
	@pre-commit run --all-files

# run pre-commit checks against renovate PRs, and commit back any changes to the PR (e.g. doc updates, secrets baseline etc)
renovate-sweeper: ghe-netrc
	ci/renovate-sweeper.sh

#
# tests
#

# run tests for terraform repos (pipeline execution only - not for local usage)
run-tests: SHELL:=/bin/bash
run-tests: ghe-netrc
	ci/run-tests.sh

# run tests for terraform repos locally
run-tests-local:
	cd ${GO_TEST_DIR} && go test -run ${RUN} -count=1 -v -timeout 300m

# run unit tests for golang projects
run-go-module-tests:
	go test $$(go list ./... | grep -v /common-dev-assets/) -count=1 -v -timeout 5m

# go mod tidy
go-mod-tidy:
	@cd ${GO_MOD_DIR}; go mod tidy -v ${GO_MOD_ARGS}

#
# netrc
#

# Create entry in ~/.netrc for cm.globalcatalog.cloud.ibm.com using IAM bearer token
netrc:
	@if [ -z "$${TF_VAR_ibmcloud_api_key}" ]; then echo "Error: TF_VAR_ibmcloud_api_key is undefined"; exit 1; fi
	ibmcloud login --no-region --apikey "$$TF_VAR_ibmcloud_api_key"
	while true ; do \
	    ibmcloud catalog netrc ; \
	    echo "refreshed netrc" ; \
	    sleep 10m ; \
	done & \
	sleep 5


# Create entry in ~/.netrc for github.ibm.com using $GH_TOKEN (no action taken if github.com detected)
ghe-netrc:
ifdef GHE
ifndef GH_TOKEN
	$(error Error: GH_TOKEN is undefined)
endif
	@touch ~/.netrc
	@if ! grep -q "machine github.ibm.com" ~/.netrc; then \
		echo -e "machine github.ibm.com\n  login $$GH_TOKEN" >> ~/.netrc; \
	else \
		echo "Found entry already exists in ~/.netrc for github.ibm.com. Taking no action."; \
	fi
endif
