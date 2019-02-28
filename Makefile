IMAGE=parkr/stenographer
REV=$(shell git rev-parse HEAD)

all: bootstrap test

bootstrap:
	script/bootstrap

test: bootstrap
	script/cibuild

docker-build:
	docker build -t $(IMAGE):$(REV) .

dive: docker-build
	dive $(IMAGE):$(REV)

docker-test: docker-build
	docker run --rm -it --net=host --env-file=.env $(IMAGE):$(REV)

docker-release: docker-build
	docker push $(IMAGE):$(REV)
