# Top-Level AWS Infrastructure for my cloud
# Author: Andrew Jarombek
# Date: 11/3/2018

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/root"
    region = "us-east-1"
  }
}

module "resources-vpc" {
  source = "./vpc"

  name = "resources"
  tag_name = "Resources"
}

module "sandbox-vpc" {
  source = "./vpc"

  name = "sandbox"
  tag_name = "Sandbox"
}