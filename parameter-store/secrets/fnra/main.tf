/**
 * Secret for an account with codename FNRA.
 * Author: Andrew Jarombek
 * Date: 7/18/2025
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/parameter-store/secrets/fnra"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/parameter-store/secrets/fnra"
}

data "aws_kms_alias" "parameter-store" {
  name = "alias/parameter-store-kms-key"
}

resource "aws_ssm_parameter" "fnra" {
  name  = "/external/FNRA"
  type  = "SecureString"
  value = var.secret

  description = "FNRA secret"
  tier        = "Standard"
  key_id      = data.aws_kms_alias.parameter-store.target_key_id
  overwrite   = false
  data_type   = "text"

  tags = {
    Name        = "external/FNRA"
    Application = "external"
    Environment = "external"
    Terraform   = local.terraform_tag
  }
}