### Overview

Module for a Github account access token stored in AWS Secrets Manager.

```bash
# Create Infrastructure
terraform init -upgrade
terraform validate
terraform plan -var 'github_access_token={ access_token = "XXX" }'
terraform apply -auto-approve -var 'github_access_token={ access_token = "XXX" }'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                      |
|---------------------|--------------------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file that configures a GitHub account access token stored in AWS Secrets Manager. |
| `var.tf`            | Input variables for AWS Secrets Manager secrets.                                                 |