/**
 * Kubernetes tests for global objects used throughout the cluster.
 * Author: Andrew Jarombek
 * Date: 7/9/2020
 */

package main

import (
	v1meta "k8s.io/apimachinery/pkg/apis/meta/v1"
	"testing"
)

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

// TestALBIngressControllerDeploymentErrorFree determines if the 'aws-alb-ingress-controller' deployment is
// running error free.
func TestALBIngressControllerDeploymentErrorFree(t *testing.T) {
	deployment, err := ClientSet.AppsV1().Deployments("kube-system").Get("aws-alb-ingress-controller", v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	deploymentConditions := deployment.Status.Conditions

	conditionStatusMet(t, deploymentConditions, "Available", "True")
	conditionStatusMet(t, deploymentConditions, "Progressing", "True")

	UnavailableReplicas := deployment.Status.UnavailableReplicas
	var expectedUnavailableReplicas int32 = 0
	replicaCountAsExpected(t, expectedUnavailableReplicas, UnavailableReplicas, "number of unavailable replicas")
}

// TestExternalDNSDeploymentErrorFree determines if the 'aws-alb-ingress-controller' deployment is
// running error free.
func TestExternalDNSDeploymentErrorFree(t *testing.T) {
	deployment, err := ClientSet.AppsV1().Deployments("kube-system").Get("external-dns", v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	deploymentConditions := deployment.Status.Conditions

	conditionStatusMet(t, deploymentConditions, "Available", "True")
	conditionStatusMet(t, deploymentConditions, "Progressing", "True")

	UnavailableReplicas := deployment.Status.UnavailableReplicas
	var expectedUnavailableReplicas int32 = 0
	replicaCountAsExpected(t, expectedUnavailableReplicas, UnavailableReplicas, "number of unavailable replicas")
}