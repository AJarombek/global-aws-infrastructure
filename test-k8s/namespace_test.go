/**
 * Tests for namespaces created in the Kubernetes cluster.
 * Author: Andrew Jarombek
 * Date: 7/8/2020
 */

package main

import (
	k8sfuncs "github.com/ajarombek/cloud-modules/kubernetes-test-functions"
	"testing"
)

// TestJarombekComNamespaceExists determines if the 'jarombek-com' namespace exists in the cluster and is active.
func TestJarombekComNamespaceExists(t *testing.T) {
	k8sfuncs.NamespaceExists(t, ClientSet, "jarombek-com")
}

// TestJarombekComDevNamespaceExists determines if the 'jarombek-com-dev' namespace exists in the cluster and is active.
func TestJarombekComDevNamespaceExists(t *testing.T) {
	k8sfuncs.NamespaceExists(t, ClientSet, "jarombek-com-dev")
}

// TestSaintsXCTFNamespaceExists determines if the 'saints-xctf' namespace exists in the cluster and is active.
func TestSaintsXCTFNamespaceExists(t *testing.T) {
	k8sfuncs.NamespaceExists(t, ClientSet, "saints-xctf")
}

// TestSaintsXCTFDevNamespaceExists determines if the 'saints-xctf-dev' namespace exists in the cluster and is active.
func TestSaintsXCTFDevNamespaceExists(t *testing.T) {
	k8sfuncs.NamespaceExists(t, ClientSet, "saints-xctf-dev")
}

// TestSandboxNamespaceExists determines if the 'sandbox' namespace exists in the cluster and is active.
func TestSandboxNamespaceExists(t *testing.T) {
	k8sfuncs.NamespaceExists(t, ClientSet, "sandbox")
}
