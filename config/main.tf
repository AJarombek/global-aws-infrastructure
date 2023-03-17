/**
 * AWS CloudTrail configuration for my account.
 * Author: Andrew Jarombek
 * Date: 3/5/2023
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.3.9"

  required_providers {
    aws = "~> 4.57.0"
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
  name     = "jarombek"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = false
    resource_types = [
      "AWS::ApiGateway::Stage",
      "AWS::ApiGateway::RestApi",
      "AWS::ApiGatewayV2::Stage",
      "AWS::ApiGatewayV2::Api",
      "AWS::AutoScaling::AutoScalingGroup",
      "AWS::AutoScaling::LaunchConfiguration",
      "AWS::DynamoDB::Table",
      "AWS::EC2::Instance",
      "AWS::EC2::InternetGateway",
      "AWS::EC2::NetworkAcl",
      "AWS::EC2::NetworkInterface",
      "AWS::EC2::RouteTable",
      "AWS::EC2::SecurityGroup",
      "AWS::EC2::Subnet",
      "AWS::EC2::VPC",
      "AWS::EC2::VPCEndpoint",
      "AWS::ECR::Repository",
      "AWS::ECR::PublicRepository",
      "AWS::ElasticLoadBalancing::LoadBalancer",
      "AWS::ElasticLoadBalancingV2::Listener",
      "AWS::IAM::Policy",
      "AWS::IAM::Role",
      "AWS::KMS::Key",
      "AWS::Lambda::Function",
      "AWS::RDS::DBInstance",
      "AWS::Route53::HostedZone",
      "AWS::S3::Bucket",
      "AWS::S3::AccountPublicAccessBlock",
      "AWS::SecretsManager::Secret",
      "AWS::SNS::Topic",
      "AWS::SQS::Queue"
    ]
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

data "aws_iam_policy_document" "policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.config_jarombek.arn,
      "${aws_s3_bucket.config_jarombek.arn}/*"
    ]
  }
}

resource "aws_iam_role" "config_role" {
  name               = "aws-config-jarombek"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Terraform = local.terraform_tag
  }
}

resource "aws_iam_role_policy" "config_policy" {
  name   = "aws-config-jarombek"
  policy = data.aws_iam_policy_document.policy.json
  role   = aws_iam_role.config_role.id
}

resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_s3_bucket" "config_jarombek" {
  bucket = "aws-config-jarombek"

  tags = {
    Terraform = local.terraform_tag
  }
}

resource "aws_config_delivery_channel" "delivery_channel" {
  name           = "aws-config-jarombek"
  s3_bucket_name = aws_s3_bucket.config_jarombek.bucket
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.delivery_channel]
}
