### Overview

Module for global secrets stored in AWS Secrets Manager.

```bash
# Create Infrastructure
terraform init -upgrade
terraform validate
terraform plan
terraform apply -auto-approve -var 'google_account_secrets={ password = "XXX" }'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file that configures global secrets stored in AWS Secrets Manager.            |
| `var.tf`            | Input variables for AWS Secrets Manager secrets.                                             |