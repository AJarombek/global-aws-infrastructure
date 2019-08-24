### Overview

VPC infrastructure for the [jarombek.com](https://www.jarombek.com/) website.  Application specific infrastructure 
exists in the [jarombek-com-infrastructure](https://github.com/AJarombek/jarombek-com-infrastructure.git) repository.  
Execute the Terraform configuration with the following commands:

```bash
# Create the Infrastructure
terraform init -upgrade
terraform validate
terraform plan
terraform apply -auto-approve

# Destroy the Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                                      |
|---------------------|------------------------------------------------------------------------------------------------------------------|
| `main.tf`           | The main Terraform script for configuring the `jarombek.com` websites VPC.                                       |