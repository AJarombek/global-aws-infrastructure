/**
 * Infrastructure for GitHub credentials stored in Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 6/6/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/secrets-manager/github"
    region = "us-east-1"
  }
}

resource "aws_secretsmanager_secret" "github-secret" {
  name = "github-secret"
  description = "GitHub key for cloning and pushing to repositories"

  tags = {
    Name = "github-secret"
    Environment = "production"
    Application = "sandbox"
  }
}

resource "aws_secretsmanager_secret_version" "github-secret-version" {
  secret_id = aws_secretsmanager_secret.github-secret.id
  secret_string = jsonencode(var.github_secret)
}