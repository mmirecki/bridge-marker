#!/usr/bin/env bash
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

namespace=${NAMESPACE:-kube-system}


bridge_marker_image_repo=${BRIDGE_MARKER_IMAGE_REPO:-quay.io/mmirecki}
bridge_marker_image_name=${BRIDGE_MARKER_IMAGE_NAME:-bridge-marker}
bridge_marker_image_version=${BRIDGE_MARKER_IMAGE_VERSION:-latest}
bridge_marker_image_pull_policy=${BRIDGE_MARKER_IMAGE_PULL_POLICY:-IfNotPresent}


openshift_node_image_repo=${OPENSHIFT_NODE_IMAGE_REPO:-docker.io/openshift}
openshift_node_image_name=${OPENSHIFT_NODE_IMAGE_NAME:-origin-node}
openshift_node_image_version=${OPENSHIFT_NODE_IMAGE_VERSION:-v3.10.0-rc.0}
openshift_node_image_pull_policy=${OPENSHIFT_NODE_IMAGE_PULL_POLICY:-IfNotPresent}

for template in manifests/*.in; do
    name=$(basename ${template%.in})
    sed \
        -e "s#\${NAMESPACE}#${namespace}#g" \
        -e "s#\${BRIDGE_MARKER_IMAGE_REPO}#${bridge_marker_image_repo}#g" \
        -e "s#\${BRIDGE_MARKER_IMAGE_NAME}#${bridge_marker_image_name}#g" \
        -e "s#\${BRIDGE_MARKER_IMAGE_VERSION}#${bridge_marker_image_version}#g" \
        -e "s#\${BRIDGE_MARKER_IMAGE_PULL_POLICY}#${bridge_marker_image_pull_policy}#g" \
        -e "s#\${OPENSHIFT_NODE_IMAGE_REPO}#${openshift_node_image_repo}#g" \
        -e "s#\${OPENSHIFT_NODE_IMAGE_NAME}#${openshift_node_image_name}#g" \
        -e "s#\${OPENSHIFT_NODE_IMAGE_VERSION}#${openshift_node_image_version}#g" \
        -e "s#\${OPENSHIFT_NODE_IMAGE_PULL_POLICY}#${openshift_node_image_pull_policy}#g" \
        ${template} > examples/${name}
done
