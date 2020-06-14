### Overview

Terraform infrastructure for building an EKS cluster.  Infrastructure includes a VPC, EKS cluster, and EC2 worker nodes.

### Commands

**WGet, AWS Iam Authenticator, and Kubectl are dependencies for running locally (MacOS)**

```bash
brew install wget
brew install aws-iam-authenticator
aws-iam-authenticator help

cd ~
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/darwin/amd64/kubectl
chmod +x ./kubectl
cp ./kubectl /usr/local/bin/kubectl
kubectl version

cd -
kubectl help --kubeconfig ./kubeconfig_andrew-jarombek-eks-cluster
kubectl get all --kubeconfig ./kubeconfig_andrew-jarombek-eks-cluster

export KUBECONFIG=~/Documents/global-aws-infrastructure/eks/kubeconfig_andrew-jarombek-eks-cluster
kubcetl config view
kubectl get all
```

### Resources

1) [EKS Control Plane Logging](https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)
2) [Barebones EKS Cluster](https://www.padok.fr/en/blog/aws-eks-cluster-terraform)
3) [Local-Exec for Subnet Tags](https://github.com/hashicorp/terraform/issues/17352)