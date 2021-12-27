# Backend Infrastructure for my cloud
# Author: Andrew Jarombek
# Date: 11/3/2018

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.70.0"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "s3-terraform-state" {
  bucket = "andrew-jarombek-terraform-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "Andrew Jarombek Terraform State"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-terraform-state" {
  bucket = aws_s3_bucket.s3-terraform-state.id

  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}