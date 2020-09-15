/**
 * Infrastructure for a Jenkins server password stored in Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 6/7/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.66.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/secrets-manager/jenkins"
    region = "us-east-1"
  }
}

resource "aws_secretsmanager_secret" "jenkins-secret" {
  name = "jenkins-secret"
  description = "Jenkins Credentials"

  tags = {
    Name = "jenkins-secret"
    Environment = "production"
    Application = "jenkins-jarombek-io"
  }
}

resource "aws_secretsmanager_secret_version" "jenkins-secret-version" {
  secret_id = aws_secretsmanager_secret.jenkins-secret.id
  secret_string = jsonencode(var.jenkins_secret)
}