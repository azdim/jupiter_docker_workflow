REGISTRY=ghcr.io/az-scp
APP=scp-nomad-pack-docker-image
VERSION=$(shell cat ../VERSION)

.PHONY: help
help: ## show this help
	@fgrep -h "## " $(MAKEFILE_LIST) | sed -e 's/\(\:.*\#\#\)/\:|/' | \
			fgrep -v fgrep | sed -e 's/\\$$//' | column -t -s '|'

.PHONY: validate
validate: ## Validate the project
	$(info * Validating the project...)
	pipenv run pre-commit run --all-files

.PHONY: test
test: build-test ## Run all tests

##-- Custom rules for docker
.PHONY: build
build: ## Build step
	$(info * Building image ...)
	DOCKER_BUILDKIT=1 docker build --no-cache \
	  --build-arg BUILD_VERSION=$(VERSION) \
	  --build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') \
	  --target distribution \
	   -t $(APP):$(VERSION) .

.PHONY: scan
scan: ## Scan container image using Trivy
	$(info * Scanning image ...)
	DOCKER_BUILDKIT=1 docker build --no-cache \
			--target trivy_scan \
	  -t $(APP):$(VERSION) .

.PHONY: build-test
build-test: ## Build and run tests
	$(info * Building test image ...)
	DOCKER_BUILDKIT=1 docker build --target test  -t $(APP):$(VERSION) .

.PHONY: run
run: ## Run container
	$(info * Run container)
	docker-compose up -f docker-compose.yml

.PHONY: push
push: ## Push image to remote registry
	$(info Push to remote registry: docker push $(REGISTRY)/$(APP):$(VERSION))
	docker tag $(APP):$(VERSION) $(REGISTRY)/$(APP):$(VERSION)
	docker push $(REGISTRY)/$(APP):$(VERSION)

.PHONY: history
history: ## Show docker history
	$(info Docker history for $(APP):$(VERSION))
	docker history $(APP):$(VERSION)
