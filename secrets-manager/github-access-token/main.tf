/**
 * Infrastructure for GitHub account access token stored in Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 6/27/2020
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
    key     = "global-aws-infrastructure/secrets-manager/github-access-token"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/secrets-manager/github-access-token"
}

resource "aws_secretsmanager_secret" "github-access-token" {
  name        = "github-access-token"
  description = "GitHub access token for using the GitHub API"

  tags = {
    Name        = "github-access-token"
    Environment = "production"
    Application = "sandbox"
    Terraform   = local.terraform_tag
  }
}

resource "aws_secretsmanager_secret_version" "github-access-token-version" {
  secret_id     = aws_secretsmanager_secret.github-access-token.id
  secret_string = jsonencode(var.github_access_token)
}