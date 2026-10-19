# Liongate workstation provisioning — entry point.
#
# `make bootstrap` is the one command to run on a freshly installed OS: it
# installs Ansible (via scripts/bootstrap.sh) and provisions the full stack.
# The other targets drive the same playbook (site.yml) for narrower runs.

SHELL := /bin/bash
ANSIBLE_PLAYBOOK ?= ansible-playbook
PLAYBOOK := site.yml

.DEFAULT_GOAL := help
.PHONY: help bootstrap dev-stack user-stack check

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

bootstrap: ## Install Ansible if missing, then provision the full technical stack
	@scripts/bootstrap.sh

# The stack targets go through bootstrap.sh too, so they also install Ansible
# when missing and prompt for the sudo password when one is required.
dev-stack: ## Provision the developer stack only (Ansible tag: dev)
	@scripts/bootstrap.sh --tags dev

user-stack: ## Provision the end-user stack only (Ansible tag: user)
	@scripts/bootstrap.sh --tags user

check: ## Dry-run the playbook and lint the provisioning code
	@scripts/bootstrap.sh --check
	@command -v ansible-lint >/dev/null 2>&1 || sudo apt-get install -y ansible-lint
	@ansible-lint $(PLAYBOOK)
