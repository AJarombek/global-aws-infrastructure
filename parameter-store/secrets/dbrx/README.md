### Overview

Terraform module containing infrastructure for a Parameter Store secret with codename `DBRX`.

### Commands

```bash
# Create Infrastructure
terraform init -upgrade
terraform validate
terraform plan -var 'secret=XXX'
terraform apply -auto-approve -var 'secret=XXX'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                       |
|---------------------|-------------------------------------------------------------------|
| `main.tf`           | Main Terraform file for the Parameter Store `DBRX` secret.        |
| `var.tf`            | Variables used in the Terraform configuration.                    |