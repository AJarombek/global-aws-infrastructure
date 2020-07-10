/**
 * Kubernetes tests for Role Based Access Control objects used in the jenkins namespace.
 * Author: Andrew Jarombek
 * Date: 7/8/2020
 */

package main

import (
	v1meta "k8s.io/apimachinery/pkg/apis/meta/v1"
	"testing"
)

// TestJenkinsNamespaceServiceAccountCount determines if the expected number of service accounts (including 'default')
// exist in the 'jenkins' namespace.
func TestJenkinsNamespaceServiceAccountCount(t *testing.T) {
	expectedServiceAccountCount := 3
	serviceAccounts, err := ClientSet.CoreV1().ServiceAccounts("jenkins").List(v1meta.ListOptions{})

	if err != nil {
		panic(err.Error())
	}

	serviceAccountCount := len(serviceAccounts.Items)
	if serviceAccountCount == expectedServiceAccountCount {
		t.Logf(
			"The expected number of Service Accounts exist in the 'jenkins' namespace.  Expected %v, got %v.",
			expectedServiceAccountCount,
			serviceAccountCount,
		)
	} else {
		t.Errorf(
			"An unexpected number of Service Accounts exist in the 'jenkins' namespace.  Expected %v, got %v.",
			expectedServiceAccountCount,
			serviceAccountCount,
		)
	}
}

// TestJenkinsServerServiceAccountExists tests that the 'jenkins-server' service account exists in
// the 'jenkins' namespace.
func TestJenkinsServerServiceAccountExists(t *testing.T)  {
	serviceAccountExists(t, ClientSet, "jenkins-server", "jenkins")
}

// TestJenkinsServerServiceAccountExists tests that the 'jenkins-kubernetes-test' service account exists in
// the 'jenkins' namespace.
func TestJenkinsKubernetesTestServiceAccountExists(t *testing.T)  {
	serviceAccountExists(t, ClientSet, "jenkins-kubernetes-test", "jenkins")
}

// TestJenkinsNamespaceRoleCount determines if the expected number of roles exist in the 'jenkins' namespace.
func TestJenkinsNamespaceRoleCount(t *testing.T) {
	expectedRoleCount := 2
	roles, err := ClientSet.RbacV1().Roles("jenkins").List(v1meta.ListOptions{})

	if err != nil {
		panic(err.Error())
	}

	actualRoleCount := len(roles.Items)
	if expectedRoleCount == actualRoleCount {
		t.Logf(
			"The expected number of Roles exist in the 'jenkins' namespace.  Expected %v, got %v.",
			expectedRoleCount,
			actualRoleCount,
		)
	} else {
		t.Errorf(
			"An unexpected number of Roles exist in the 'jenkins' namespace.  Expected %v, got %v.",
			expectedRoleCount,
			actualRoleCount,
		)
	}
}

// TestJenkinsServerRoleExists tests that the 'jenkins-server' service account exists in the 'jenkins' namespace.
func TestJenkinsServerRoleExists(t *testing.T) {
	roleExists(t, ClientSet, "jenkins-server", "jenkins")
}

// TestJenkinsKubernetesTestRoleExists tests that the 'jenkins-kubernetes-test' service account exists in
// the 'jenkins' namespace.
func TestJenkinsKubernetesTestRoleExists(t *testing.T) {
	roleExists(t, ClientSet, "jenkins-kubernetes-test", "jenkins")
}

