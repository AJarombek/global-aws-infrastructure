### Overview

Module for a Jenkins server password stored in AWS Secrets Manager.

```bash
# Create Infrastructure
terraform init -upgrade
terraform validate
terraform plan -var 'jenkins_secret={ password = "XXX" }'
terraform apply -auto-approve -var 'jenkins_secret={ password = "XXX" }'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file that configures a Jenkins secret stored in AWS Secrets Manager.          |
| `var.tf`            | Input variables for AWS Secrets Manager secrets.                                             |