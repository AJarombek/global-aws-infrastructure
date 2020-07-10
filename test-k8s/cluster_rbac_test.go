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

// TestKubeSystemNamespaceDeploymentCount determines if the number of 'Deployment' objects in the 'kube-system'
// namespace is as expected.  Deployments should be for aws-alb-ingress-controller, coredns, and external-dns.
func TestKubeSystemNamespaceDeploymentCount(t *testing.T) {
	expectedDeploymentCount(t, ClientSet, "kube-system", 3)
}

// TestALBIngressControllerDeploymentExists determines if a deployment exists in the 'kube-system' namespace with
// the name 'aws-alb-ingress-controller'.
func TestALBIngressControllerDeploymentExists(t *testing.T) {
	deploymentExists(t, ClientSet, "aws-alb-ingress-controller", "kube-system")
}

// TestExternalDNSDeploymentExists determines if a deployment exists in the 'kube-system' namespace with the name
// 'external-dns'.
func TestExternalDNSDeploymentExists(t *testing.T) {
	deploymentExists(t, ClientSet, "external-dns", "kube-system")
}
