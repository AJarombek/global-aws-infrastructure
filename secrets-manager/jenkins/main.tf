/**
 * Infrastructure for a Jenkins server password stored in Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 6/7/2020
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
    key     = "global-aws-infrastructure/secrets-manager/jenkins"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/secrets-manager/jenkins"
}

resource "aws_secretsmanager_secret" "jenkins-secret" {
  name        = "jenkins-secret"
  description = "Jenkins Credentials"

  tags = {
    Name        = "jenkins-secret"
    Environment = "production"
    Application = "jenkins-jarombek-io"
    Terraform   = local.terraform_tag
  }
}

resource "aws_secretsmanager_secret_version" "jenkins-secret-version" {
  secret_id     = aws_secretsmanager_secret.jenkins-secret.id
  secret_string = jsonencode(var.jenkins_secret)
}