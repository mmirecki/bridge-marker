REGISTRY ?= quay.io/kubevirt
IMAGE_TAG ?= latest

COMPONENTS = $(sort \
			 $(subst /,-,\
			 $(patsubst cmd/%/,%,\
			 $(dir \
			 $(shell find cmd/ -type f -name '*.go')))))

all: build

build: format $(patsubst %, build-%, $(COMPONENTS))

build-%:
	hack/version.sh > ./cmd/$(subst -,/,$*)/.version
	cd cmd/$(subst -,/,$*) && go fmt && go vet && go build

format:
	go fmt ./pkg/...
	go vet ./pkg/...

test:
	go test ./cmd/... ./pkg/... -v --ginkgo.v

docker-test:
	hack/test-dockerized.sh

test-%:
	go test ./$(subst -,/,$*)/... -v --ginkgo.v

functest:
	hack/dockerized "hack/build-func-tests.sh"
	hack/functests.sh

docker-build: $(patsubst %, docker-build-%, $(COMPONENTS))

docker-build-%: build-%
	docker build -t ${REGISTRY}/bridge-$*:${IMAGE_TAG} ./cmd/$(subst -,/,$*)

docker-push: $(patsubst %, docker-push-%, $(COMPONENTS))

docker-push-%:
	docker push ${REGISTRY}/bridge-$*:${IMAGE_TAG}

dep:
	dep ensure -v

clean-dep:
	rm -f ./Gopkg.lock
	rm -rf ./vendor

manifests:
	./hack/build-manifests.sh

cluster-up:
	./cluster/up.sh

cluster-down:
	./cluster/down.sh

cluster-sync: build
	./cluster/sync.sh

.PHONY: build format test docker-build docker-push dep clean-dep manifests cluster-up cluster-down cluster-sync
