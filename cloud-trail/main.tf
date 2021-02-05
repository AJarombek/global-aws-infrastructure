/**
 * AWS CloudTrail configuration for my account.
 * Author: Andrew Jarombek
 * Date: 2/4/2021
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.26.0"
    template = ">= 2.2.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/cloud-trail"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

data "template_file" "cloud-trail-s3-bucket-policy" {
  template = file("bucket-policy.json")

  vars = {
    ACCOUNT_ID = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudtrail" "trail" {
  name = "andrew-jarombek-cloudtrail"
  s3_bucket_name = aws_s3_bucket.andrew-jarombek-cloud-trail.id
  enable_logging = true

  is_multi_region_trail = false
  is_organization_trail = false
  include_global_service_events = true

  tags = {
    Name = "andrew-jarombek-cloudtrail"
    Application = "global"
    Environment = "all"
  }
}

resource "aws_s3_bucket" "andrew-jarombek-cloud-trail" {
  bucket = "andrew-jarombek-cloud-trail"
  force_destroy = true

  tags = {
    Name = "andrew-jarombek-cloud-trail"
    Application = "global"
    Environment = "all"
  }
}

resource "aws_s3_bucket_policy" "andrew-jarombek-cloud-trail-policy" {
  bucket = aws_s3_bucket.andrew-jarombek-cloud-trail.id
  policy = data.template_file.cloud-trail-s3-bucket-policy.rendered
}