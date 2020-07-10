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
