/**
 * The VPC for all the saintsxctf.com infrastructure
 * Author: Andrew Jarombek
 * Date: 11/27/2018
 */

locals {
  saintsxctf_public_subnet_cidr = "10.0.1.0/24"
  public_cidr = "0.0.0.0/0"
}

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
  public_subnet_count = 2
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = false
  public_subnet_cidr = "${local.saintsxctf_public_subnet_cidr}"

  public_subnet_sg_rules = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
    },
    {
      # Inbound traffic for ping
      type = "ingress"
      from_port = -1
      to_port = -1
      protocol = "icmp"
    },
    {
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
    }
  ]

  public_subnet_sg_cidr_blocks = [
    "${local.public_cidr}",
    "${local.public_cidr}",
    "${local.public_cidr}"
  ]

  private_subnet_sg_rules = [
    {
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
    }
  ]

  private_subnet_sg_cidr_blocks = [
    "${local.public_cidr}"
  ]
}