/**
 * The VPC for all the jarombek.com infrastructure
 * Author: Andrew Jarombek
 * Date: 11/27/2018
 */

locals {
  jarombek_com_public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]

  jarombek_com_private_subnet_cidrs = [
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]

  public_cidr = "0.0.0.0/0"

  jarombek_com_vpc_sg_rules = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Inbound traffic for SSH
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Inbound traffic for ping
      type = "ingress"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic to the internet
      type = "egress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic to the internet
      type = "egress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = local.public_cidr
    },
  ]

  jarombek_com_public_subnet_azs = [
    "us-east-1a",
    "us-east-1b",
  ]

  jarombek_com_private_subnet_azs = [
    "us-east-1c",
    "us-east-1d",
  ]
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/apps/jarombek-com"
    region = "us-east-1"
  }
}

module "jarombek-com-vpc" {
  source = "github.com/ajarombek/terraform-modules//vpc?ref=v0.1.7"

  # Mandatory arguments
  name = "jarombek-com"
  tag_name = "jarombek-com"

  # Optional arguments
  public_subnet_count = 2
  private_subnet_count = 2
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = false

  public_subnet_names = ["jarombek-com-yeezus-public-subnet", "jarombek-com-yandhi-public-subnet"]
  private_subnet_names = ["jarombek-com-red-private-subnet", "jarombek-com-reputation-private-subnet"]

  public_subnet_azs = local.jarombek_com_public_subnet_azs
  private_subnet_azs = local.jarombek_com_private_subnet_azs
  public_subnet_cidrs = local.jarombek_com_public_subnet_cidrs
  private_subnet_cidrs = local.jarombek_com_private_subnet_cidrs

  enable_security_groups = true
  sg_rules = local.jarombek_com_vpc_sg_rules
}