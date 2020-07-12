/**
 * Kubernetes tests for Role Based Access Control objects used cluster-wide.
 * Author: Andrew Jarombek
 * Date: 7/8/2020
 */

package main

import "testing"

// TestALBIngressControllerServiceAccountExists tests that the 'aws-alb-ingress-controller' service account exists in
// the 'kube-system' namespace.
func TestALBIngressControllerServiceAccountExists(t *testing.T)  {
	serviceAccountExists(t, ClientSet, "aws-alb-ingress-controller", "kube-system")
}

// TestExternalDNSServiceAccountExists tests that the 'external-dns' service account exists in
// the 'kube-system' namespace.
func TestExternalDNSServiceAccountExists(t *testing.T)  {
	serviceAccountExists(t, ClientSet, "external-dns", "kube-system")
}
