/**
 * AWS CloudTrail configuration for my account.
 * Author: Andrew Jarombek
 * Date: 3/5/2023
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.3.9"

  required_providers {
    aws = ">= 4.57.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/config"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/config"
}

resource "aws_config_configuration_recorder" "recorder" {
  name = "jarombek"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["config.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "config_role" {
  name = "aws-config-jarombek"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Terraform = local.terraform_tag
  }
}
