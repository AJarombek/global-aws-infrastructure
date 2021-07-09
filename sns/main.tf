/**
 * AWS SNS (Simple Notification Service) Configuration for my cloud
 * Author: Andrew Jarombek
 * Date: 2/12/2021
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = ">= 3.48.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/sns"
    region  = "us-east-1"
  }
}

# NOTE - an email subscription to this topic needs to be created manually through the console or CloudFormation,
# not Terraform.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#protocol
resource "aws_sns_topic" "alert-email" {
  name = "alert-email-topic"

  tags = {
    Name = "alert-email-topic"
  }
}

resource "aws_sns_topic_policy" "alert-email" {
  arn = aws_sns_topic.alert-email.arn
  policy = data.aws_iam_policy_document.sns-topic-policy.json
}

data "aws_iam_policy_document" "sns-topic-policy" {
  statement {
    sid = "PublishEventsToEmailTopic"
    effect = "Allow"

    principals {
      identifiers = ["events.amazonaws.com"]
      type = "Service"
    }

    actions = ["sns:Publish"]
    resources = [aws_sns_topic.alert-email.arn]
  }
}

resource "aws_cloudformation_stack" "sns-email-subscription" {
  name = "sns-email-subscription"
  template_body = file("sns-email-subscription.yml")
  on_failure = "DELETE"
  timeout_in_minutes = 20

  parameters = {
    SNSTopicArn = aws_sns_topic.alert-email.arn
  }

  tags = {
    Name = "sns-email-subscription"
  }
}