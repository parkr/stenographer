IMAGE=parkr/stenographer
REV:=$(shell git rev-parse HEAD)

all: bootstrap test

bootstrap:
	script/bootstrap

test: bootstrap
	script/cibuild

dev:
	docker build -t $(IMAGE):$(REV)-dev -f Dockerfile.dev .
	docker run -it --rm --entrypoint /bin/sh -v "$(shell pwd):/app/stenographer" $(IMAGE):$(REV)-dev

docker-build:
	docker build -t $(IMAGE):$(REV) .

dive: docker-build
	dive $(IMAGE):$(REV)

docker-test: docker-build
	docker run --rm -it --name=stenographer_test --net=host --env-file=.env $(IMAGE):$(REV)

docker-release: docker-build
	docker push $(IMAGE):$(REV)
