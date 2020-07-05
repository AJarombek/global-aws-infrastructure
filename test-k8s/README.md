### Commands

**Setting up Go and Kubernetes Client for Testing on MacOS**

```bash
brew install go@1.14
go version

# Setup Go module
go mod init jarombek.io/testeks
go get k8s.io/client-go@kubernetes-1.16.0
go get k8s.io/apimachinery@kubernetes-1.16.0
```

**Running the Go tests locally**

```bash
# Run the Kubernetes tests using the local Kubeconfig file.
go test --kubeconfig ~/Documents/global-aws-infrastructure/eks/kubeconfig_andrew-jarombek-eks-cluster
```

### Files

| Filename               | Description                                                                                  |
|------------------------|----------------------------------------------------------------------------------------------|
| `jenkins_test.go`      | Kubernetes tests for the 'jenkins' namespace.                                                |
| `utils.go`             | Utility functions to assist Kubernetes tests.                                                |
| `go.mod`               | Go module definition and dependency specification.                                           |
| `go.sum`               | Versions of modules installed as dependencies for this Go module.                            |

### Resources

1. [Setting up K8s Go Client](https://github.com/kubernetes/client-go/blob/master/INSTALL.md)
