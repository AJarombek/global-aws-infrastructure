/**
 * Secret for an account with codename GEMI.
 * Author: Andrew Jarombek
 * Date: 4/20/2022
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
    key     = "global-aws-infrastructure/parameter-store/secrets/gemi"
    region  = "us-east-1"
  }
}

data "aws_kms_alias" "parameter-store" {
  name = "alias/parameter-store-kms-key"
}

resource "aws_ssm_parameter" "gemi" {
  name  = "/external/GEMI"
  type  = "SecureString"
  value = var.secret

  description = "GEMI secret"
  tier        = "Standard"
  key_id      = data.aws_kms_alias.parameter-store.target_key_id
  overwrite   = false
  data_type   = "text"

  tags = {
    Name        = "external/GEMI"
    Application = "external"
  }
}