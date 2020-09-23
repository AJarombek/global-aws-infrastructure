### Overview

Module for AWS access secrets stored in AWS Secrets Manager.

```bash
# Create Infrastructure
terraform init -upgrade
terraform validate
terraform plan -var 'aws_access_secret={ aws_access_key_id = "XXX", aws_secret_access_key = "XXX" }'
terraform apply -auto-approve -var 'aws_access_secret={ aws_access_key_id = "XXX", aws_secret_access_key = "XXX" }'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file that configures AWS access secrets stored in AWS Secrets Manager.        |
| `var.tf`            | Input variables for AWS Secrets Manager secrets.                                             |