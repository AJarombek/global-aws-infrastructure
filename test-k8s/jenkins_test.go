/**
 * Writing tests of Kubernetes infrastructure in the 'jenkins' namespace with the Go K8s client library.
 * Author: Andrew Jarombek
 * Date: 7/5/2020
 */

package main

import (
	"flag"
	"fmt"
	"k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"os"
	"testing"
)

var clientset *kubernetes.Clientset

// Setup code for the test suite.
func TestMain(m *testing.M) {
	var kubeconfig *string = flag.String("kubeconfig", "", "Absolute path to the kubeconfig file.")
	flag.Parse()

	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)

	if err != nil {
		panic(err.Error())
	}

	cs, err := kubernetes.NewForConfig(config)

	if err != nil {
		panic(err.Error())
	}

	clientset = cs
	os.Exit(m.Run())
}

// TestJenkinsNamespaceDeploymentCount determines if the number of 'Deployment' objects in the 'jenkins' namespace is
// as expected.
func TestJenkinsNamespaceDeploymentCount(t *testing.T) {
	expectedDeploymentCount := 1
	deployments, err := clientset.AppsV1().Deployments("jenkins").List(v1.ListOptions{})

	if err != nil {
		panic(err.Error())
	}

	var deploymentCount = len(deployments.Items)
	if deploymentCount == expectedDeploymentCount {
		t.Logf(
			"A single Deployment exists in the 'jenkins' namespace.  Expected %v, got %v.",
			expectedDeploymentCount,
			deploymentCount,
		)
	} else {
		t.Errorf(
			"An unexpected number of Deployments exist in the 'jenkins' namespace.  Expected %v, got %v.",
			expectedDeploymentCount,
			deploymentCount,
		)
	}
}

// TestJenkinsDeploymentExists determines if a deployment exists in the 'jenkins' namespace with the name
//'jenkins-deployment'.
func TestJenkinsDeploymentExists(t *testing.T) {
	deploymentName := "jenkins-deployment"
	deployment, err := clientset.AppsV1().Deployments("jenkins").Get("jenkins-deployment", v1.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	if deployment.Name == deploymentName {
		t.Logf(
			"Jenkins Deployment exists with the expected name.  Expected %v, got %v.",
			deploymentName,
			deployment.Name,
		)
	} else {
		t.Errorf(
			"Jenkins Deployment does not exist with the expected name.  Expected %v, got %v.",
			deploymentName,
			deployment.Name,
		)
	}
}

// TestJenkinsNamespaceIngressCount determines if the number of 'Ingress' objects in the 'jenkins' namespace is
// as expected.
func TestJenkinsNamespaceIngressCount(t *testing.T) {
	expectedIngressCount := 1
	ingresses, err := clientset.NetworkingV1beta1().Ingresses("jenkins").List(v1.ListOptions{})

	if err != nil {
		panic(err.Error())
	}

	var ingressCount = len(ingresses.Items)
	if ingressCount == expectedIngressCount {
		t.Logf(
			"A single Ingress object exists in the 'jenkins' namespace.  Expected %v, got %v.",
			expectedIngressCount,
			ingressCount,
		)
	} else {
		t.Errorf(
			"An unexpected number of Ingress objects exist in the 'jenkins' namespace.  Expected %v, got %v.",
			expectedIngressCount,
			ingressCount,
		)
	}
}

// TestJenkinsIngressExists determines if an ingress object exists in the 'jenkins' namespace with the name
//'jenkins-ingress'.
func TestJenkinsIngressExists(t *testing.T) {
	expectedIngressName := "jenkins-ingress"
	ingress, err := clientset.NetworkingV1beta1().Ingresses("jenkins").Get("jenkins-ingress", v1.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	if ingress.Name == expectedIngressName {
		t.Logf(
			"Jenkins Ingress exists with the expected name.  Expected %v, got %v.",
			expectedIngressName,
			ingress.Name,
		)
	} else {
		t.Errorf(
			"Jenkins Ingress does not exist with the expected name.  Expected %v, got %v.",
			expectedIngressName,
			ingress.Name,
		)
	}
}

// TestJenkinsIngressAnnotations determines if the 'jenkins-ingress' Ingress object contains the expected annotations.
func TestJenkinsIngressAnnotations(t *testing.T) {
	ingress, err := clientset.NetworkingV1beta1().Ingresses("jenkins").Get("jenkins-ingress", v1.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	annotations := ingress.Annotations

	// Kubernetes Ingress class and ExternalDNS annotations
	annotationsEqual(t, annotations, "kubernetes.io/ingress.class", "alb")
	annotationsEqual(t, annotations, "external-dns.alpha.kubernetes.io/hostname", "jenkins.jarombek.io,www.jenkins.jarombek.io")

	// ALB Ingress annotations
	annotationsEqual(t, annotations, "alb.ingress.kubernetes.io/backend-protocol", "HTTP")
	annotationsEqual(t, annotations, "alb.ingress.kubernetes.io/scheme", "internet-facing")
	annotationsEqual(t, annotations, "alb.ingress.kubernetes.io/listen-ports", "[{\"HTTP\":80}, {\"HTTPS\":443}]")
	annotationsEqual(t, annotations, "alb.ingress.kubernetes.io/healthcheck-path", "/login")
	annotationsEqual(t, annotations, "alb.ingress.kubernetes.io/healthcheck-protocol", "HTTP")
	annotationsEqual(t, annotations, "alb.ingress.kubernetes.io/target-type", "instance")
	annotationsEqual(t, annotations, "alb.ingress.kubernetes.io/tags", "Name=jenkins-load-balancer,Application=jenkins,Environment=production")

	// ALB Ingress annotations pattern matching
	uuidPattern := "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
	certificateArnPattern := fmt.Sprintf("arn:aws:acm:us-east-1:739088120071:certificate/%s", uuidPattern)
	certificatesPattern := fmt.Sprintf("^%s,%s$", certificateArnPattern, certificateArnPattern)
	annotationsMatchPattern(t, annotations, "alb.ingress.kubernetes.io/certificate-arn", certificatesPattern)

	sgPattern := "^sg-[0-9a-f]+$"
	annotationsMatchPattern(t, annotations, "alb.ingress.kubernetes.io/security-groups", sgPattern)

	subnetsPattern := "^subnet-[0-9a-f]+,subnet-[0-9a-f]+$"
	annotationsMatchPattern(t, annotations, "alb.ingress.kubernetes.io/subnets", subnetsPattern)

	expectedAnnotationsLength := 12
	annotationLength := len(annotations)

	if expectedAnnotationsLength == annotationLength {
		t.Logf(
			"Jenkins Ingress has the expected number of annotations.  Expected %v, got %v.",
			expectedAnnotationsLength,
			annotationLength,
		)
	} else {
		t.Errorf(
			"Jenkins Ingress does not have the expected number of annotations.  Expected %v, got %v.",
			expectedAnnotationsLength,
			annotationLength,
		)
	}
}