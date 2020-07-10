/**
 * Reusable utility functions used for testing Kubernetes infrastructure.
 * Author: Andrew Jarombek
 * Date: 7/5/2020
 */

package main

import (
	v1 "k8s.io/api/apps/v1"
	v1core "k8s.io/api/core/v1"
	v1meta "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"regexp"
	"testing"
)
// expectedDeploymentCount determines if the number of 'Deployment' objects in a namespace is as expected.
func expectedDeploymentCount(t *testing.T, clientset *kubernetes.Clientset, namespace string, expectedCount int) {
	deployments, err := clientset.AppsV1().Deployments(namespace).List(v1meta.ListOptions{})

	if err != nil {
		panic(err.Error())
	}

	var actualCount = len(deployments.Items)
	if actualCount == expectedCount {
		t.Logf(
			"The expected number of Deployments exist in the '%v' namespace.  Expected %v, got %v.",
			namespace,
			expectedCount,
			actualCount,
		)
	} else {
		t.Errorf(
			"An unexpected number of Deployments exist in the '%v' namespace.  Expected %v, got %v.",
			namespace,
			expectedCount,
			actualCount,
		)
	}
}

func deploymentExists(t *testing.T, clientset *kubernetes.Clientset, name string, namespace string)  {
	deployment, err := clientset.AppsV1().Deployments(namespace).Get(name, v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	actualName := deployment.Name
	if actualName == name {
		t.Logf("Jenkins Deployment exists with the expected name.  Expected %v, got %v.", name, actualName)
	} else {
		t.Errorf("Jenkins Deployment does not exist with the expected name.  Expected %v, got %v.", name, actualName)
	}
}

// annotationsEqual logs a failure to a test suite if an annotation in the annotations map does not have its expected
//value.  Otherwise, it logs a success message and the test suite will proceed with a success code.
func annotationsEqual(t *testing.T, annotations map[string]string, name string, expectedValue string) {
	value := annotations[name]

	if expectedValue == value {
		t.Logf(
			"Annotation %v exists with its expected value.  Expected %v, got %v.",
			name,
			expectedValue,
			value,
		)
	} else {
		t.Errorf(
			"Annotation %v does not exist with its expected value.  Expected %v, got %v.",
			name,
			expectedValue,
			value,
		)
	}
}

// annotationsMatchPattern logs a failure to a test suite if an annotation in the annotations map does not match its
// expected pattern.  Otherwise, it logs a success message and the test suite will proceed with a success code.
func annotationsMatchPattern(t *testing.T, annotations map[string]string, name string, expectedPattern string) {
	value := annotations[name]
	pattern, err := regexp.Compile(expectedPattern)

	if err != nil {
		panic(err.Error())
	}

	if pattern.MatchString(value) {
		t.Logf(
			"Annotation %v exists and matches its expected pattern.  Expected %v, got %v.",
			name,
			expectedPattern,
			value,
		)
	} else {
		t.Errorf(
			"Annotation %v does not exist and match its expected pattern.  Expected %v, got %v.",
			name,
			expectedPattern,
			value,
		)
	}
}

// conditionStatusMet checks a condition on a Deployment and sees if its status is as expected.
func conditionStatusMet(t *testing.T, conditions []v1.DeploymentCondition,
	conditionType v1.DeploymentConditionType, expectedStatus v1core.ConditionStatus) {

	matches := make([]v1.DeploymentCondition, 0, 1)
	for _, condition := range conditions {
		if condition.Type == conditionType {
			matches = append(matches, condition)
		}
	}

	status := matches[0].Status

	if status == expectedStatus {
		t.Logf(
			"Deployment condition type %v has its expected status.  Expected %v, got %v.",
			conditionType,
			expectedStatus,
			status,
		)
	} else {
		t.Errorf(
			"Deployment condition type %v does not have its expected status.  Expected %v, got %v.",
			conditionType,
			expectedStatus,
			status,
		)
	}
}

func replicaCountAsExpected(t *testing.T, expectedReplicas int32, actualReplicas int32, description string)  {
	if expectedReplicas == actualReplicas {
		t.Logf(
			"Jenkins Deployment has expected %v.  Expected %v, got %v.",
			description,
			expectedReplicas,
			actualReplicas,
		)
	} else {
		t.Errorf(
			"Jenkins Deployment has unexpected %v.  Expected %v, got %v.",
			description,
			expectedReplicas,
			actualReplicas,
		)
	}
}

// namespaceExists determines if a Namespace exists and is active in a cluster.
func namespaceExists(t *testing.T, clientset *kubernetes.Clientset, name string) {
	namespace, err := clientset.CoreV1().Namespaces().Get(name, v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	var status v1core.NamespacePhase = "Active"
	if namespace.Status.Phase == status {
		t.Logf("Cluster has a namespace named %v.", name)
	} else {
		t.Errorf("Cluster does not have a namespace named %v.", name)
	}
}

// namespaceExists determines if a ServiceAccount exists in a cluster.
func serviceAccountExists(t *testing.T, clientset *kubernetes.Clientset, name string, namespace string) {
	serviceAccount, err := clientset.CoreV1().ServiceAccounts(namespace).Get(name, v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	var now = v1meta.Now()
	if serviceAccount.CreationTimestamp.Before(&now) {
		t.Logf("A ServiceAccount named '%v' exists in the '%v' namespace.", name, namespace)
	} else {
		t.Errorf("A ServiceAccount named '%v' does not exist in the '%v' namespace.", name, namespace)
	}
}

// roleExists determines if a Role exists in a cluster.
func roleExists(t *testing.T, clientset *kubernetes.Clientset, name string, namespace string) {
	role, err := clientset.RbacV1().Roles(namespace).Get(name, v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	var now = v1meta.Now()
	if role.CreationTimestamp.Before(&now) {
		t.Logf("A Role named '%v' exists in the '%v' namespace.", name, namespace)
	} else {
		t.Errorf("A Role named '%v' does not exist in the '%v' namespace.", name, namespace)
	}
}
