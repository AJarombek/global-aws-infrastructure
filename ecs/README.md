### Overview

Terraform infrastructure for building an ECS cluster.

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

### Files

| Filename   | Description                                  |
|------------|----------------------------------------------|
| `main.tf`  | Terraform configuration for the ECS cluster. |
