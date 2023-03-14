# Backend Infrastructure for my cloud
# Author: Andrew Jarombek
# Date: 11/3/2018

terraform {
  required_version = ">= 1.3.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.58.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  terraform_tag = "global-aws-infrastructure/backend"
}

resource "aws_s3_bucket" "s3-terraform-state" {
  bucket = "andrew-jarombek-terraform-state"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Andrew Jarombek Terraform State"
    Application = "all"
    Environment = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_s3_bucket_versioning" "s3-terraform-state" {
  bucket = aws_s3_bucket.s3-terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-terraform-state" {
  bucket = aws_s3_bucket.s3-terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}