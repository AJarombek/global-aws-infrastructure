/**
 * The VPC for all the saintsxctf.com infrastructure
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
    key = "global-aws-infrastructure/apps/saintsxctf-com"
    region = "us-east-1"
  }
}

module "saintsxctf-com-vpc" {
  source = "../../root/vpc"

  # Mandatory arguments
  name = "saintsxctfcom"
  tag_name = "SaintsXCTFcom"

  # Optional arguments
  enable_dns_support = true
  enable_dns_hostnames = true
}