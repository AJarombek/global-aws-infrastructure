/**
 * Secret for an account with codename TDAM.
 * Author: Andrew Jarombek
 * Date: 12/29/2021
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.1.2"

  required_providers {
    aws = ">= 3.70.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/parameter-store/secrets/tdam"
    region = "us-east-1"
  }
}

data "aws_kms_alias" "parameter-store" {
  name = "alias/parameter-store-kms-key"
}

resource "aws_ssm_parameter" "tdam" {
  name = "/external/TDAM"
  type = "SecureString"
  value = var.secret

  description = "TDAM secret"
  tier = "Standard"
  key_id = data.aws_kms_alias.parameter-store.target_key_id
  overwrite = false
  data_type = "text"

  tags = {
    Name = "external/TDAM"
    Application = "external"
  }
}