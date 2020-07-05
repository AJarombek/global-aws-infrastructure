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

**Running the Go script locally**

```bash
go run main.go --kubeconfig ~/Documents/global-aws-infrastructure/eks/kubeconfig_andrew-jarombek-eks-cluster
```

### Resources

1. [Setting up K8s Go Client](https://github.com/kubernetes/client-go/blob/master/INSTALL.md)
