.PHONY: help install clean local-service docker-build-celery docker-build-service docker-push-service docker-push-celery test-service

.DEFAULT_GOAL := help
SHELL := /bin/bash
PATH := ${PWD}/venv/bin:${PATH}
PYTHONPATH := ${PWD}:${PYTHONPATH}
AWS_DEFAULT_REGION = eu-central-1

include .common.env

ifdef ENV
include .${ENV}.env
endif

export


BOLD=$(shell tput -T xterm bold)
RED=$(shell tput -T xterm setaf 1)
GREEN=$(shell tput -T xterm setaf 2)
YELLOW=$(shell tput -T xterm setaf 3)
RESET=$(shell tput -T xterm sgr0)

help:
	@awk 'BEGIN {FS = ":.*?##-.*?local.*?- "} /^[a-zA-Z_-]+:.*?##-.*?local.*?- / \
	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "${YELLOW}ENV=data${RESET}"
	@awk 'BEGIN {FS = ":.*?##-.*?data.*?- "} /^[a-zA-Z_-]+:.*?##-.*?data.*?- / \
	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "${YELLOW}ENV=sandbox${RESET}"
	@awk 'BEGIN {FS = ":.*?##-.*?sandbox.*?- "} /^[a-zA-Z_-]+:.*?##-.*?sandbox.*?- / \
	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


check-%:
	@if [ "${${*}}" = "" ]; then \
		echo -e "${RED} Variable $* not set ❌${RESET}"; \
		exit 1; \
	fi

nosudo:
	@if [ $(shell whoami) = root ]; then \
		echo -e "${RED} This command should not be run as root ❌${RESET}"; \
		exit 1; \
	fi

# -------------------------------------------------------------------
# DEPLOY
# -------------------------------------------------------------------

plan:
	export TF_VAR_ethereum_admin_account=${ETHEREUM_ADMIN_ACCOUNT} && \
	export TF_VAR_ethereum_admin_private_key=${ETHEREUM_ADMIN_PRIVATE_KEY} && \
	cd config && \
	terraform init && \
	terraform plan


deploy:
	export TF_VAR_ethereum_admin_account=${ETHEREUM_ADMIN_ACCOUNT} && \
	export TF_VAR_ethereum_admin_private_key=${ETHEREUM_ADMIN_PRIVATE_KEY} && \
	export TF_VAR_bsc_mainnet_provider_url=${BSC_MAINNET_PROVIDER_URL} && \
	cd config && \
	terraform init && \
	terraform apply -auto-approve



# -------------------------------------------------------------------
# DEPLOY
# -------------------------------------------------------------------


destroy:
	export TF_VAR_ethereum_admin_account=${ETHEREUM_ADMIN_ACCOUNT} && \
	export TF_VAR_ethereum_admin_private_key=${ETHEREUM_ADMIN_PRIVATE_KEY} && \
	cd config/${ENV} && \
	terraform init && \
	terraform destroy


