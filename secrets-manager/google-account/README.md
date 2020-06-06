### Overview

Module for a Google Account secret stored in AWS Secrets Manager.

```bash
# Create Infrastructure
terraform init -upgrade
terraform validate
terraform plan -var 'google_account_secrets={ password = "XXX" }'
terraform apply -auto-approve -var 'google_account_secrets={ password = "XXX" }'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file that configures a Google Account secret stored in AWS Secrets Manager.   |
| `var.tf`            | Input variables for AWS Secrets Manager secrets.                                             |