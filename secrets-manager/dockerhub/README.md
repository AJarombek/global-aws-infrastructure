### Overview

Module for a DockerHub secret stored in AWS Secrets Manager.

```bash
# Create Infrastructure
terraform init -upgrade
terraform validate
terraform plan -var 'dockerhub_secret={ username = "XXX", password = "XXX" }'
terraform apply -auto-approve -var 'dockerhub_secret={ private_key = "XXX", password = "XXX" }'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file that configures a DockerHub key stored in AWS Secrets Manager.           |
| `var.tf`            | Input variables for the DockerHub secret.                                                    |