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

| Filename                 | Description                                                                                  |
|--------------------------|----------------------------------------------------------------------------------------------|
| `client.go`              | Kubernetes client creation.                                                                  |
| `cluster_object_test.go` | Kubernetes tests for objects used throughout the cluster.                                    |
| `cluster_rbac_test.go`   | Kubernetes tests for cluster Role Based Access Control objects.                              |
| `jenkins_rbac_test.go`   | Kubernetes tests for 'jenkins' namspace Role Based Access Control objects.                   |
| `jenkins_test.go`        | Kubernetes tests for the 'jenkins' namespace.                                                |
| `main_test.go`           | Setup functions for Kubernetes tests.                                                        |
| `namespace_test.go`      | Kubernetes tests for namespaces in the cluster.                                              |
| `utils.go`               | Utility functions to assist Kubernetes tests.                                                |
| `go.mod`                 | Go module definition and dependency specification.                                           |
| `go.sum`                 | Versions of modules installed as dependencies for this Go module.                            |

### Resources

1. [Setting up K8s Go Client](https://github.com/kubernetes/client-go/blob/master/INSTALL.md)
2. [Out-of-Cluster Config](https://github.com/kubernetes/client-go/blob/master/examples/out-of-cluster-client-configuration/main.go)
3. [In-Cluster Config](https://github.com/kubernetes/client-go/blob/master/examples/in-cluster-client-configuration/main.go)
4. [Go Unit Testing](https://medium.com/rungo/unit-testing-made-easy-in-go-25077669318)
5. [Go Modules](https://blog.golang.org/using-go-modules)
