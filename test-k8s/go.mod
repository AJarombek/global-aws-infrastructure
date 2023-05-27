// Go module definition for the global-k8s-infrastructure-tests module.
// Author: Andrew Jarombek
// Date: 11/28/2020

module github.com/ajarombek/global-k8s-infrastructure-tests

go 1.14

require (
	github.com/ajarombek/cloud-modules/kubernetes-test-functions v0.2.6
	golang.org/x/sys v0.8.0 // indirect
	k8s.io/api v0.17.0
	k8s.io/apimachinery v0.17.3-beta.0
	k8s.io/client-go v0.17.0
)

// For local use - replace the github repository module with a local path.
// replace github.com/ajarombek/cloud-modules/kubernetes-test-functions => ../../cloud-modules/kubernetes-test-functions
