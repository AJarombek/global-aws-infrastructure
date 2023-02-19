/**
 * AWS cost management budget configuration for my account.
 * Author: Andrew Jarombek
 * Date: 2/10/2021
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.27.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/budgets"
    region  = "us-east-1"
  }
}

resource "aws_budgets_budget" "cost" {
  name              = "Andrew Jarombek AWS Budget"
  budget_type       = "COST"
  limit_amount      = "325"
  limit_unit        = "USD"
  time_period_start = "2021-02-01_12:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "FORECASTED"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = ["andrew@jarombek.com", "ajarombek95@gmail.com"]
  }
}