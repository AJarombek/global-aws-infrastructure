/**
 * Secret for an account with codename AAPL.
 * Author: Andrew Jarombek
 * Date: 5/15/2022
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.1.2"

  required_providers {
    aws = ">= 4.10.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/parameter-store/secrets/aapl"
    region  = "us-east-1"
  }
}

data "aws_kms_alias" "parameter-store" {
  name = "alias/parameter-store-kms-key"
}

resource "aws_ssm_parameter" "aapl" {
  name  = "/external/AAPL"
  type  = "SecureString"
  value = var.secret

  description = "AAPL secret"
  tier        = "Standard"
  key_id      = data.aws_kms_alias.parameter-store.target_key_id
  overwrite   = false
  data_type   = "text"

  tags = {
    Name        = "external/AAPL"
    Application = "external"
  }
}