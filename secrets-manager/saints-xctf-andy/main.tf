/**
 * Infrastructure for a SaintsXCTF password stored in Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 9/13/2020
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
    key     = "global-aws-infrastructure/secrets-manager/saints-xctf-andy"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/secrets-manager/saints-xctf-andy"
}

resource "aws_secretsmanager_secret" "saints-xctf-andy" {
  name        = "saints-xctf-andy-password"
  description = "SaintsXCTF Password"

  tags = {
    Name        = "saints-xctf-andy-password"
    Environment = "production"
    Application = "saints-xctf-com"
    Terraform   = local.terraform_tag
  }
}

resource "aws_secretsmanager_secret_version" "saints-xctf-andy-version" {
  secret_id     = aws_secretsmanager_secret.saints-xctf-andy.id
  secret_string = jsonencode(var.saints_xctf_password)
}