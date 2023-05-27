### Overview

V2 Terraform infrastructure for building an EKS cluster.

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

**Create KubeConfig Locally**

```bash
# Creates KubeConfig in ~/.kube/config
aws eks update-kubeconfig --region us-east-1 --name andrew-jarombek-eks-v2
```

**Debugging a Pod**

```bash
kubectl get po -n my-namespace
kubectl get deployment -n my-namespace
kubectl get clusterrole -n my-namespace
kubectl get clusterrolebinding -n my-namespace
kubectl logs -f my-pod-name -n my-namespace
```

### Files

| Filename   | Description                                    |
|------------|------------------------------------------------|
| `main.tf`  | Terraform configuration for the EKS cluster.   |

### Resources

1. [Helm Terraform Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
2. [Kubernetes Terraform Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
3. [EKS Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
4. [Very Useful EKS Setup Guide](https://andrewtarry.com/posts/terraform-eks-alb-setup/)