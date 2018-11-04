# Top-Level AWS Infrastructure for my cloud
# Author: Andrew Jarombek
# Date: 11/3/2018

provider "aws" {
  region = "us-east-1"
}

data "aws_s3_bucket" "tf-state-bucket" {
  bucket = "andrew-jarombek-terraform-state"
}

terraform {
  backend "s3" {
    bucket = "${data.aws_s3_bucket.tf-state-bucket.bucket}"
    encrypt = true
    key = "global/root"
    region = "us-east-1"
  }
}

resource "aws_vpc" "resources-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "sandbox-vpc" {
  cidr_block = "10.0.0.0/16"
}