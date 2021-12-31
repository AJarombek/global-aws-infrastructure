### Overview

Terraform module containing all configuration needed for AWS Systems Manager Parameter Store.

### Commands

```bash
# Create Infrastructure
terraform init -upgrade
terraform validate
terraform plan
terraform apply

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                           |
|---------------------|---------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file for the AWS Systems Manager Parameter Store configuration.        |