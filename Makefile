REGISTRY=ghcr.io/azdim
APP=scp-template-docker-image
VERSION=$(shell cat VERSION)

ifeq ($(GITHUB_ACTIONS), true)
	PIPENV ?=
else
	PIPENV ?= pipenv run
endif

.PHONY: help
help: ## show this help
	@fgrep -h "## " $(MAKEFILE_LIST) | sed -e 's/\(\:.*\#\#\)/\:|/' | \
			fgrep -v fgrep | sed -e 's/\\$$//' | column -t -s '|'

##-- Common rules

.PHONY: setup
setup: ## Setup python environment with pipenv
	@echo "* Installing pipenv"
	pipenv install && pipenv sync

.PHONY: init
init: ## Init your environment
	@echo "* Preparing project"
	$(PIPENV) pre-commit install
	$(PIPENV) pre-commit autoupdate

.PHONY: validate
validate: ## Validate the project
	@echo "* Validating the project..."
	$(PIPENV) pre-commit run --all-files

##-- Release and version management
.PHONY: release-patch
release-patch: ## Bump patched version
	$(PIPENV) bumpversion patch

.PHONY: release-minor
release-minor: ## Bump minor version
	$(PIPENV) bumpversion minor

.PHONY: release
release: ## Bump major version
	$(PIPENV) bumpversion major

.PHONY: publish
publish: ## Push release remote
	git push --progress
	git push --progress --tags --follow-tags
