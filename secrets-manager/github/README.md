### Overview

Module for a GitHub secret stored in AWS Secrets Manager.

```bash
# Create Infrastructure
terraform init -upgrade
terraform validate
terraform plan -var 'github_secret={ private_key = "XXX" }'
terraform apply -auto-approve -var 'github_secret={ private_key = "XXX" }'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file that configures a GitHub key stored in AWS Secrets Manager.              |
| `var.tf`            | Input variables for AWS Secrets Manager secrets.                                             |