/**
 * Infrastructure for a SaintsXCTF password stored in Secrets Manager.
 * Author: Andrew Jarombek
 * Date: 9/13/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/secrets-manager/saints-xctf-andy"
    region = "us-east-1"
  }
}

resource "aws_secretsmanager_secret" "saints-xctf-andy" {
  name = "saints-xctf-andy-password"
  description = "SaintsXCTF Password"

  tags = {
    Name = "saints-xctf-andy-password"
    Environment = "production"
    Application = "saints-xctf-com"
  }
}

resource "aws_secretsmanager_secret_version" "saints-xctf-andy-version" {
  secret_id = aws_secretsmanager_secret.saints-xctf-andy.id
  secret_string = jsonencode(var.saints_xctf_password)
}