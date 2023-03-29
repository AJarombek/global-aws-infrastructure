/**
 * AWS SNS (Simple Notification Service) Configuration for my cloud
 * Author: Andrew Jarombek
 * Date: 2/12/2021
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
    key     = "global-aws-infrastructure/sns"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/sns"
}

# NOTE - an email subscription to this topic needs to be created manually through the console or CloudFormation,
# not Terraform.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#protocol
resource "aws_sns_topic" "alert-email" {
  name = "alert-email-topic"

  tags = {
    Name        = "alert-email-topic"
    Environment = "all"
    Application = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_sns_topic_policy" "alert-email" {
  arn    = aws_sns_topic.alert-email.arn
  policy = data.aws_iam_policy_document.sns-email-topic-policy.json
}

data "aws_iam_policy_document" "sns-email-topic-policy" {
  statement {
    sid    = "PublishEventsToEmailTopic"
    effect = "Allow"

    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alert-email.arn]
  }
}

resource "aws_cloudformation_stack" "sns-email-subscription" {
  name               = "sns-email-subscription"
  template_body      = file("sns-email-subscription.yml")
  on_failure         = "DELETE"
  timeout_in_minutes = 20

  parameters = {
    SNSTopicArn = aws_sns_topic.alert-email.arn
  }

  tags = {
    Name        = "sns-email-subscription"
    Environment = "all"
    Application = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_sns_topic" "alert-sms" {
  name = "alert-sms-topic"

  tags = {
    Name        = "alert-sms-topic"
    Environment = "all"
    Application = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_sns_topic_subscription" "sns-sms-subscription" {
  endpoint  = var.phone_number
  protocol  = "sms"
  topic_arn = aws_sns_topic.alert-sms.arn
}

resource "aws_sns_topic_policy" "alert-sms" {
  arn    = aws_sns_topic.alert-sms.arn
  policy = data.aws_iam_policy_document.sns-sms-topic-policy.json
}

data "aws_iam_policy_document" "sns-sms-topic-policy" {
  statement {
    sid    = "PublishEventsToSMSTopic"
    effect = "Allow"

    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alert-sms.arn]
  }
}

resource "aws_sns_sms_preferences" "preferences" {
  monthly_spend_limit = "1"
  default_sender_id   = "JarombekAWS"
  default_sms_type    = "Promotional"
}