/**
 * The VPC for all the jarombek.com infrastructure
 * Author: Andrew Jarombek
 * Date: 11/27/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/apps/jarombek-com"
    region = "us-east-1"
  }
}

module "jarombek-com-vpc" {
  source = "../../root/vpc"

  # Mandatory arguments
  name = "jarombekcom"
  tag_name = "Jarombekcom"

  # Optional arguments
  enable_dns_support = true
  enable_dns_hostnames = true
}