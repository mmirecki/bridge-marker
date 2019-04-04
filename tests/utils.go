/*
 * This file is part of the KubeVirt project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Copyright 2018 Red Hat, Inc.
 *
 */

package tests

import (
	"os"
	"os/exec"
	"strings"
)

// TODO: Use job with a node affinity instead
func RunOnNode(node string, command string) (string, error) {
	provider, ok := os.LookupEnv("KUBEVIRT_PROVIDER")
	if !ok {
		panic("KUBEVIRT_PROVIDER environment variable must be specified")
	}

	out, err := exec.Command("docker", "exec", provider+"-"+node, "ssh.sh", command).CombinedOutput()
	outString := string(out)
	outLines := strings.Split(outString, "\n")
	// first two lines of output indicate that connection was successful
	outStripped := outLines[2:]
	outStrippedString := strings.Join(outStripped, "\n")

	return outStrippedString, err
}
