/**
 * Infrastructure for global Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 5/23/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/secrets-manager"
    region = "us-east-1"
  }
}

resource "aws_secretsmanager_secret" "google-account-secret" {
  name = "google-account-secret"
  description = "Google Account Credentials"

  tags = {
    Name = "google-account-secret"
    Environment = "production"
    Application = "sandbox"
  }
}

resource "aws_secretsmanager_secret_version" "saints-xctf-rds-secret-version" {
  secret_id = aws_secretsmanager_secret.google-account-secret.id
  secret_string = jsonencode(var.google_account_secrets)
}