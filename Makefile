
DOCKER_IMAGE_NAME:=hwchiu/python-example
DOCKER_IMAGE_TAG:=latest

.PHONY: build push clean
build: ## build docker images
	docker build -t $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) .
	docker build -t $(DOCKER_IMAGE_NAME):latest .

push: build ## push docker image
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)

clean: ## clean docker images
	docker rmi $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)

deploy: ## deploy local application via KIND load
	docker build -t localbuild/python-example:latest .
	kind load docker-image localbuild/python-example:latest -n k8slab


help: ## Print
	@grep '^[[:alnum:]_-]*:.* ##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.* ## "}; {printf "%-25s %s\n", $$1, $$2};'
