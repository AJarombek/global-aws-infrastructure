/**
 * AWS Lambda functions definitions and configuration.
 * Author: Andrew Jarombek
 * Date: 7/15/2021
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
    key     = "global-aws-infrastructure/lambda"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/lambda"
}

resource "aws_lambda_function" "daily-cost" {
  function_name    = "AWSDailyCost"
  filename         = "${path.module}/AWSDailyCost.zip"
  description      = "AWS daily cost function"
  handler          = "lambda.handler"
  role             = aws_iam_role.daily-cost-lambda-role.arn
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/AWSDailyCost.zip")
  timeout          = 10
  memory_size      = 128

  tags = {
    Name        = "aws-daily-cost"
    Environment = "all"
    Application = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_cloudwatch_log_group" "daily-cost-log-group" {
  name              = "/aws/lambda/AWSDailyCost"
  retention_in_days = 7

  tags = {
    Name        = "aws-daily-cost"
    Environment = "all"
    Application = "all"
    Terraform   = local.terraform_tag
  }
}

data "aws_iam_policy_document" "daily-cost-lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "daily-cost-lambda-policy" {
  statement {
    sid    = "AWSDailyCostLambda"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "ce:GetCostAndUsage",
      "sns:Publish"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "daily-cost-lambda-role" {
  name               = "daily-cost-lambda-role"
  path               = "/global/"
  assume_role_policy = data.aws_iam_policy_document.daily-cost-lambda-assume-role-policy.json
  description        = "IAM role for an AWS Lambda function which computes daily AWS costs"

  tags = {
    Name        = "daily-cost-lambda-role"
    Environment = "all"
    Application = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_iam_policy" "daily-cost-lambda-policy" {
  name        = "daily-cost-lambda-policy"
  path        = "/global/"
  policy      = data.aws_iam_policy_document.daily-cost-lambda-policy.json
  description = "IAM policy for an AWS Lambda function which computes daily AWS costs"

  tags = {
    Name        = "daily-cost-lambda-policy"
    Environment = "all"
    Application = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_iam_role_policy_attachment" "lambda-logging-policy-attachment" {
  role       = aws_iam_role.daily-cost-lambda-role.name
  policy_arn = aws_iam_policy.daily-cost-lambda-policy.arn
}

resource "aws_cloudwatch_event_rule" "daily-cost-schedule-rule" {
  name                = "daily-cost-lambda-rule"
  description         = "Execute the Daily Cost Lambda Function Daily"
  schedule_expression = "cron(0 7 * * ? *)"
  is_enabled          = true

  tags = {
    Name        = "daily-cost-lambda-rule"
    Environment = "all"
    Application = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_cloudwatch_event_target" "daily-cost-schedule-target" {
  arn  = aws_lambda_function.daily-cost.arn
  rule = aws_cloudwatch_event_rule.daily-cost-schedule-rule.name
}

resource "aws_lambda_permission" "daily-cost-schedule-permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.daily-cost.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily-cost-schedule-rule.arn
}