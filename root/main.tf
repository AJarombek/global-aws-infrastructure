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
  # routing_table_cidr = "192.168.1.123/32"
}

module "sandbox-vpc" {
  source = "./vpc"

  # Mandatory arguments
  name = "sandbox"
  tag_name = "Sandbox"

  # Optional arguments
  # routing_table_cidr = "192.168.1.123/32"
}

# Route53 Config
resource "aws_route53_zone" "jarombek-com" {
  name = "jarombek.com."
}