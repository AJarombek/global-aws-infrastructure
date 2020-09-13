### Overview

Global API Gateway configuration, specifically to enable AWS Cloudwatch logging.

### Files

| Filename                  | Description                                                                                      |
|---------------------------|--------------------------------------------------------------------------------------------------|
| `main.tf`                 | Main Terraform script for API Gateway account configuration.                                     |
| `assume_role_policy.json` | IAM role `api-gateway-cloudwatch-role` assume role policy document.                              |
| `policy.json`             | IAM policy `api-gateway-cloudwatch-policy` policy document.                                      |

### Resources

1. [Terraform API Gateway Account Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account)