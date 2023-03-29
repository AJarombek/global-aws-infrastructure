/**
 * Infrastructure for a Google account secret stored in Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 5/23/2020
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
    key     = "global-aws-infrastructure/secrets-manager/google-account"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/secrets-manager/google-account"
}

resource "aws_secretsmanager_secret" "google-account-secret" {
  name        = "google-account-secret"
  description = "Google Account Credentials"

  tags = {
    Name        = "google-account-secret"
    Environment = "production"
    Application = "sandbox"
    Terraform   = local.terraform_tag
  }
}

resource "aws_secretsmanager_secret_version" "google-account-secret-version" {
  secret_id     = aws_secretsmanager_secret.google-account-secret.id
  secret_string = jsonencode(var.google_account_secrets)
}