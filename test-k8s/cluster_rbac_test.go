/**
 * Kubernetes tests for Role Based Access Control objects used cluster-wide.
 * Author: Andrew Jarombek
 * Date: 7/8/2020
 */

package main

import (
	k8sfuncs "github.com/ajarombek/cloud-modules/kubernetes-test-functions"
	"testing"
)

// TestALBIngressControllerServiceAccountExists tests that the 'aws-alb-ingress-controller' service account exists in
// the 'kube-system' namespace.
func TestALBIngressControllerServiceAccountExists(t *testing.T)  {
	k8sfuncs.ServiceAccountExists(t, ClientSet, "aws-alb-ingress-controller", "kube-system")
}

// TestExternalDNSServiceAccountExists tests that the 'external-dns' service account exists in
// the 'kube-system' namespace.
func TestExternalDNSServiceAccountExists(t *testing.T)  {
	k8sfuncs.ServiceAccountExists(t, ClientSet, "external-dns", "kube-system")
}

// TestALBIngressControllerClusterRoleExists tests that the 'aws-alb-ingress-controller' cluster role exists in
// the 'kube-system' namespace.
func TestALBIngressControllerClusterRoleExists(t *testing.T)  {
	k8sfuncs.ClusterRoleExists(t, ClientSet, "aws-alb-ingress-controller")
}

// TestExternalDNSClusterRoleExists tests that the 'external-dns' cluster role exists in
// the 'kube-system' namespace.
func TestExternalDNSClusterRoleExists(t *testing.T)  {
	k8sfuncs.ClusterRoleExists(t, ClientSet, "external-dns")
}

// TestALBIngressControllerClusterRoleBindingExists tests that the 'aws-alb-ingress-controller' cluster role binding
// exists in the 'kube-system' namespace.
func TestALBIngressControllerClusterRoleBindingExists(t *testing.T)  {
	k8sfuncs.ClusterRoleBindingExists(t, ClientSet, "aws-alb-ingress-controller")
}

// TestExternalDNSClusterRoleExists tests that the 'external-dns' cluster role binding exists in
// the 'kube-system' namespace.
func TestExternalDNSClusterRoleBindingExists(t *testing.T)  {
	k8sfuncs.ClusterRoleBindingExists(t, ClientSet, "external-dns")
}
