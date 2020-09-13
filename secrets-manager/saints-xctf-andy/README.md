### Overview

Module for a SaintsXCTF password stored in AWS Secrets Manager.

```bash
# Create Infrastructure
terraform init -upgrade
terraform validate
terraform plan -var 'saints_xctf_password={ password = "XXX" }'
terraform apply -auto-approve -var 'saints_xctf_password={ password = "XXX" }'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file that configures a SaintsXCTF password stored in AWS Secrets Manager.     |
| `var.tf`            | Input variables for AWS Secrets Manager secrets.                                             |