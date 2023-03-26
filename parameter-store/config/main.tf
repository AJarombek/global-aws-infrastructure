/**
 * System Manager Parameter Store configuration for my cloud
 * Author: Andrew Jarombek
 * Date: 12/29/2021
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
    key     = "global-aws-infrastructure/parameter-store/config"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/parameter-store/config"
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "key" {
  description             = "KMS Key for Parameter Store"
  deletion_window_in_days = 10
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
  policy                  = data.aws_iam_policy_document.key-policy.json

  tags = {
    Name        = "parameter-store-kms-key"
    Application = "external"
    Environment = "external"
    Terraform   = local.terraform_tag
  }
}

data "aws_iam_policy_document" "key-policy" {
  policy_id = "key-default"

  statement {
    sid    = "AllKMSAccess"
    effect = "Allow"

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kms_alias" "key-alias" {
  target_key_id = aws_kms_key.key.id
  name          = "alias/parameter-store-kms-key"
}