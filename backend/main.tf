# Backend Infrastructure for my cloud
# Author: Andrew Jarombek
# Date: 11/3/2018

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

  tags {
    Name = "Andrew Jarombek Terraform State"
  }
}