.PHONY: image test

IMAGE_NAME ?= codeclimate/codeclimate-grep

image:
	docker build --tag $(IMAGE_NAME) .

test-image: image
	docker build --tag $(IMAGE_NAME)-test --file Dockerfile.test .

test: test-image
	docker run --rm \
		--volume $(PWD)/spec:/usr/src/app/spec \
		$(IMAGE_NAME)-test \
		sh -c "bundle exec rspec"
