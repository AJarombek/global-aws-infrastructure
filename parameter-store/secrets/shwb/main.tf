/**
 * Secret for an account with codename SHWB.
 * Author: Andrew Jarombek
 * Date: 9/2/2023
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
    key     = "global-aws-infrastructure/parameter-store/secrets/shwb"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/parameter-store/secrets/shwb"
}

data "aws_kms_alias" "parameter-store" {
  name = "alias/parameter-store-kms-key"
}

resource "aws_ssm_parameter" "shwb" {
  name  = "/external/SHWB"
  type  = "SecureString"
  value = var.secret

  description = "SHWB secret"
  tier        = "Standard"
  key_id      = data.aws_kms_alias.parameter-store.target_key_id
  overwrite   = false
  data_type   = "text"

  tags = {
    Name        = "external/SHWB"
    Application = "external"
    Environment = "external"
    Terraform   = local.terraform_tag
  }
}