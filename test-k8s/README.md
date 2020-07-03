### Commands

**Setting up Go and Kubernetes Client for Testing on MacOS**

```bash
brew install go@1.14
go version

# Setup Go module
go mod init jarombek.io/testeks
go get k8s.io/client-go@kubernetes-1.16.0
```

### Resources

1. [Setting up K8s Go Client](https://github.com/kubernetes/client-go/blob/master/INSTALL.md)
