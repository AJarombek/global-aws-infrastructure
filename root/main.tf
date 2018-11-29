/**
 * Top-Level AWS Infrastructure for my cloud
 * Author: Andrew Jarombek
 * Date: 11/3/2018
 */

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

  # Mandatory arguments
  name = "resources"
  tag_name = "Resources"

  # Optional arguments
  enable_dns_support = true
  enable_dns_hostnames = true
}

module "sandbox-vpc" {
  source = "./vpc"

  # Mandatory arguments
  name = "sandbox"
  tag_name = "Sandbox"

  # Optional arguments
  enable_dns_support = true
  enable_dns_hostnames = true
}