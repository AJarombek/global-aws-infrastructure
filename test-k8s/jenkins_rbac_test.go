package main

import (
	v1meta "k8s.io/apimachinery/pkg/apis/meta/v1"
	"testing"
)

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

func TestJenkinsServerServiceAccountExists(t *testing.T)  {
	serviceAccount, err := ClientSet.CoreV1().ServiceAccounts("jenkins").Get("jenkins-server", v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}
}
