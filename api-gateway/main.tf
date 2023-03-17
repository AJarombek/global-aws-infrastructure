/**
 * API Gateway global account settings.
 * Author: Andrew Jarombek
 * Date: 9/12/2020
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
    key     = "global-aws-infrastructure/api-gateway"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/api-gateway"
}

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name               = "api-gateway-cloudwatch-role"
  path               = "/global/"
  assume_role_policy = file("assume_role_policy.json")
  description        = "IAM Role for using Cloudwatch with API Gateway"

  tags = {
    Name        = "api-gateway-cloudwatch-role"
    Application = "all"
    Environment = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_iam_policy" "cloudwatch" {
  name        = "api-gateway-cloudwatch-policy"
  path        = "/global/"
  policy      = file("policy.json")
  description = "IAM Policy for using Cloudwatch with API Gateway"

  tags = {
    Name        = "api-gateway-cloudwatch-policy"
    Application = "all"
    Environment = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = aws_iam_policy.cloudwatch.arn
  role       = aws_iam_role.cloudwatch.id
}