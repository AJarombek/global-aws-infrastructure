/**
 * Infrastructure for AWS access secrets stored in Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 9/22/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.7.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/secrets-manager/aws-access"
    region = "us-east-1"
  }
}

resource "aws_secretsmanager_secret" "aws-access-secrets" {
  name = "aws-access-secrets"
  description = "AWS access secrets for using the AWS CLI and SDKs"

  tags = {
    Name = "aws-access-secrets"
    Environment = "production"
    Application = "all"
  }
}

resource "aws_secretsmanager_secret_version" "aws-access-secrets-version" {
  secret_id = aws_secretsmanager_secret.aws-access-secrets.id
  secret_string = jsonencode(var.aws_access_secret)
}