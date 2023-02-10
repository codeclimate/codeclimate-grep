.PHONY: image test release

IMAGE_NAME ?= codeclimate/codeclimate-grep
RELEASE_REGISTRY ?= codeclimate
RELEASE_TAG ?= latest

image:
	docker build --rm -t $(IMAGE_NAME) .

test: image
	docker run --rm --workdir /usr/src/app $(IMAGE_NAME) sh -c "rspec"

release:
	docker tag $(IMAGE_NAME) $(RELEASE_REGISTRY)/codeclimate-grep:$(RELEASE_TAG)
	docker push $(RELEASE_REGISTRY)/codeclimate-grep:$(RELEASE_TAG)
