// Copyright 2018 Red Hat, Inc.
// Copyright 2014 CNI authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package tests_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var _ = Describe("bridge-marker", func() {
	Describe("pod availability tests", func() {
		Context("pod availability tests", func() {
			It("assert pods exists", func() {
				isPodPresent := false
				pods, _ := clientset.CoreV1().Pods("").List(v1.ListOptions{})
				for _, pod := range pods.Items {
					if len(pod.ObjectMeta.OwnerReferences) == 0 {
						continue
					}
					owner := pod.ObjectMeta.OwnerReferences[0].Name
					if owner == "bridge-marker" {
						isPodPresent = true
					}
				}
				Expect(isPodPresent)
			})
		})
	})
})
