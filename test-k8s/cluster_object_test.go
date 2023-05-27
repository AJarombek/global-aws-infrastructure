/**
 * Kubernetes tests for global objects used throughout the cluster.
 * Author: Andrew Jarombek
 * Date: 7/9/2020
 */

package main

import (
	k8sfuncs "github.com/ajarombek/cloud-modules/kubernetes-test-functions"
	v1meta "k8s.io/apimachinery/pkg/apis/meta/v1"
	"testing"
)

// TestKubeSystemNamespaceDeploymentCount determines if the number of 'Deployment' objects in the 'kube-system'
// namespace is as expected.  Deployments should be for aws-alb-ingress-controller, coredns, and external-dns.
func TestKubeSystemNamespaceDeploymentCount(t *testing.T) {
	k8sfuncs.ExpectedDeploymentCount(t, ClientSet, "kube-system", 3)
}

// TestAWSLoadBalancerControllerDeploymentExists determines if a deployment exists in the 'kube-system' namespace with
// the name 'aws-alb-ingress-controller'.
func TestAWSLoadBalancerControllerDeploymentExists(t *testing.T) {
	k8sfuncs.DeploymentExists(t, ClientSet, "aws-load-balancer-controller", "kube-system")
}

// TestExternalDNSDeploymentExists determines if a deployment exists in the 'kube-system' namespace with the name
// 'external-dns'.
func TestExternalDNSDeploymentExists(t *testing.T) {
	k8sfuncs.DeploymentExists(t, ClientSet, "external-dns", "kube-system")
}

// TestAWSLoadBalancerControllerDeploymentErrorFree determines if the 'aws-alb-ingress-controller' deployment is
// running error free.
func TestAWSLoadBalancerControllerDeploymentErrorFree(t *testing.T) {
	deployment, err := ClientSet.AppsV1().Deployments("kube-system").Get("aws-load-balancer-controller", v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	deploymentConditions := deployment.Status.Conditions

	k8sfuncs.ConditionStatusMet(t, deploymentConditions, "Available", "True")
	k8sfuncs.ConditionStatusMet(t, deploymentConditions, "Progressing", "True")

	UnavailableReplicas := deployment.Status.UnavailableReplicas
	var expectedUnavailableReplicas int32 = 0
	k8sfuncs.ReplicaCountAsExpected(t, expectedUnavailableReplicas, UnavailableReplicas, "number of unavailable replicas")
}

// TestExternalDNSDeploymentErrorFree determines if the 'aws-alb-ingress-controller' deployment is
// running error free.
func TestExternalDNSDeploymentErrorFree(t *testing.T) {
	deployment, err := ClientSet.AppsV1().Deployments("kube-system").Get("external-dns", v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	deploymentConditions := deployment.Status.Conditions

	k8sfuncs.ConditionStatusMet(t, deploymentConditions, "Available", "True")
	k8sfuncs.ConditionStatusMet(t, deploymentConditions, "Progressing", "True")

	UnavailableReplicas := deployment.Status.UnavailableReplicas
	var expectedUnavailableReplicas int32 = 0
	k8sfuncs.ReplicaCountAsExpected(t, expectedUnavailableReplicas, UnavailableReplicas, "number of unavailable replicas")
}
