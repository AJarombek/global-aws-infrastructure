/**
 * Infrastructure for AWS access secrets stored in Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 9/22/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.3.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.58.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/secrets-manager/aws-access"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/secrets-manager/aws-access"
}

resource "aws_secretsmanager_secret" "aws-access-secrets" {
  name        = "aws-access-secrets"
  description = "AWS access secrets for using the AWS CLI and SDKs"

  tags = {
    Name        = "aws-access-secrets"
    Environment = "production"
    Application = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_secretsmanager_secret_version" "aws-access-secrets-version" {
  secret_id     = aws_secretsmanager_secret.aws-access-secrets.id
  secret_string = jsonencode(var.aws_access_secret)
}