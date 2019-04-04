#!/bin/bash
#
# Copyright 2018 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

source hack/common.sh
source cluster/$KUBEVIRT_PROVIDER/provider.sh
source hack/config.sh
source ./cluster/gocli.sh

registry_port=$($gocli --prefix $provider_prefix ports registry | tr -d '\r')
registry=localhost:$registry_port

REGISTRY=$registry make docker-build
REGISTRY=$registry make docker-push

if [[ $KUBEVIRT_PROVIDER == "k8s-"* ]]; then
    bridge_marker_manifest="./cluster/examples/kubernetes-bridge-marker.yml"
elif [[ $KUBEVIRT_PROVIDER == "os-"* ]]; then
    bridge_marker_manifest="./cluster/examples/openshift-bridge-marker.yml"
else
    exit 1
fi

./cluster/kubectl.sh delete --ignore-not-found -f $bridge_marker_manifest

# Delete daemon sets that were deprecated/renamed
./cluster/kubectl.sh -n kube-system delete --ignore-not-found ds bridge-marker

# Wait until all objects are deleted
until [[ $(./cluster/kubectl.sh get --ignore-not-found -f $bridge_marker_manifest 2>&1 | wc -l) -eq 0 ]]; do sleep 1; done
until [[ $(./cluster/kubectl.sh get --ignore-not-found ds bridge-marker 2>&1 | wc -l) -eq 0 ]]; do sleep 1; done

./cluster/kubectl.sh create -f $bridge_marker_manifest
