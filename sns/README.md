### Overview

This directory contains topics and subscriptions for AWS SNS (Simple Notification System).

### Commands

```bash
# Create the infrastructure.
terraform init
terraform validate
terraform plan -var 'phone_number=1234567890' -detailed-exitcode -out=terraform-prod.tfplan
terraform apply -auto-approve terraform-prod.tfplan

# Destroy the infrastructure.
terraform plan -destroy
terraform destroy -auto-approve
```

### Files

| Filename                     | Description                                                                       |
|------------------------------|-----------------------------------------------------------------------------------|
| `main.tf`                    | The main Terraform module containing all the infrastructure for AWS SNS.          |
| `sns-email-subscription.yml` | CloudFormation template for creating an SNS email subscription.                   |