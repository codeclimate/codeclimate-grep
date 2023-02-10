.PHONY: image test release

IMAGE_NAME ?= codeclimate/codeclimate-grep
RELEASE_REGISTRY ?= codeclimate
RELEASE_TAG ?= latest

image:
	docker build --tag $(IMAGE_NAME) .

test-image: image
	docker build --tag $(IMAGE_NAME)-test --file Dockerfile.test .

test: test-image
	docker run --rm \
		--volume $(PWD)/spec:/usr/src/app/spec \
		$(IMAGE_NAME)-test \
		sh -c "bundle exec rspec"

release:
	docker tag $(IMAGE_NAME) $(RELEASE_REGISTRY)/codeclimate-grep:$(RELEASE_TAG)
	docker push $(RELEASE_REGISTRY)/codeclimate-grep:$(RELEASE_TAG)
