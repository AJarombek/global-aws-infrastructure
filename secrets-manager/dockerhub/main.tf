/**
 * Infrastructure for DockerHub credentials stored in Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 6/25/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/secrets-manager/dockerhub"
    region = "us-east-1"
  }
}

resource "aws_secretsmanager_secret" "dockerhub-secret" {
  name = "dockerhub-secret"
  description = "DockerHub key for cloning and pushing to repositories"

  tags = {
    Name = "dockerhub-secret"
    Environment = "production"
    Application = "sandbox"
  }
}

resource "aws_secretsmanager_secret_version" "dockerhub-secret-version" {
  secret_id = aws_secretsmanager_secret.dockerhub-secret.id
  secret_string = jsonencode(var.dockerhub_secret)
}