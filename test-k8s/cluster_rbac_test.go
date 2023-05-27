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

// TestAWSLoadBalancerControllerServiceAccountExists tests that the 'aws-load-balancer-controller' service account exists in
// the 'kube-system' namespace.
func TestAWSLoadBalancerControllerServiceAccountExists(t *testing.T) {
	k8sfuncs.ServiceAccountExists(t, ClientSet, "aws-load-balancer-controller", "kube-system")
}

// TestExternalDNSServiceAccountExists tests that the 'external-dns' service account exists in
// the 'kube-system' namespace.
func TestExternalDNSServiceAccountExists(t *testing.T) {
	k8sfuncs.ServiceAccountExists(t, ClientSet, "external-dns", "kube-system")
}

// TestAWSLoadBalancerControllerClusterRoleExists tests that the 'aws-load-balancer-controller-role' cluster role exists in
// the 'kube-system' namespace.
func TestAWSLoadBalancerControllerClusterRoleExists(t *testing.T) {
	k8sfuncs.ClusterRoleExists(t, ClientSet, "aws-load-balancer-controller-role")
}

// TestExternalDNSClusterRoleExists tests that the 'external-dns' cluster role exists in
// the 'kube-system' namespace.
func TestExternalDNSClusterRoleExists(t *testing.T) {
	k8sfuncs.ClusterRoleExists(t, ClientSet, "external-dns")
}

// TestAWSLoadBalancerControllerClusterRoleBindingExists tests that the 'aws-load-balancer-controller-rolebinding' cluster role binding
// exists in the 'kube-system' namespace.
func TestAWSLoadBalancerControllerClusterRoleBindingExists(t *testing.T) {
	k8sfuncs.ClusterRoleBindingExists(t, ClientSet, "aws-load-balancer-controller-rolebinding")
}

// TestExternalDNSClusterRoleExists tests that the 'external-dns' cluster role binding exists in
// the 'kube-system' namespace.
func TestExternalDNSClusterRoleBindingExists(t *testing.T) {
	k8sfuncs.ClusterRoleBindingExists(t, ClientSet, "external-dns")
}
