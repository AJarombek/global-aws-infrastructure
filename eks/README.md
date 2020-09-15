### Overview

Terraform infrastructure for building an EKS cluster.  Infrastructure includes a VPC, EKS cluster, and EC2 worker nodes.

### Files

| Filename                              | Description                                                                  |
|---------------------------------------|------------------------------------------------------------------------------|
| `k8s-config`                          | Kubernetes YAML config files for the EKS cluster.                            |
| `alb-ingress-controller-policy.json`  | IAM Policy for the ALB Ingress Controller in EKS.                            |
| `external-dns-policy.json`            | IAM Policy for External DNS in EKS.                                          |
| `main.tf`                             | Terraform configuration for the EKS cluster.                                 |

### Commands

**Build the Infrastructure**

```bash
# Create the infrastructure.
terraform init
terraform validate
terraform plan -detailed-exitcode -out=terraform-prod.tfplan
terraform apply -auto-approve terraform-prod.tfplan

# Destroy the infrastructure.
terraform plan -destroy
terraform destroy -auto-approve
```

**Inspect EKS Locally**

> WGet, AWS Iam Authenticator, and Kubectl are dependencies for inspecting EKS locally (MacOS)

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
kubectl config view
kubectl get all
kubectl get nodes
```

### Resources

1) [EKS Control Plane Logging](https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)
2) [Barebones EKS Cluster](https://www.padok.fr/en/blog/aws-eks-cluster-terraform)
3) [Local-Exec for Subnet Tags](https://github.com/hashicorp/terraform/issues/17352)
4) [AWS EKS Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/12.1.0)
5) [Local Kubectl/Auth Setup](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
6) [ALB Ingress Controller Terraform Example](https://github.com/iplabs/terraform-kubernetes-alb-ingress-controller/blob/master/main.tf)
7) [Replica Set Fix for Ingress Controller](https://github.com/hashicorp/terraform-provider-kubernetes/issues/678)
8) [ALB Ingress External DNS](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/external-dns/setup/)
9) [External DNS New Endpoints Permissions](https://github.com/kubernetes-sigs/external-dns/issues/961#issuecomment-664849509)
10) [ALB Ingress Controller Annotations](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/ingress/annotation/#annotations)