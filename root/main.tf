/**
 * Top-Level AWS Infrastructure for my cloud
 * Author: Andrew Jarombek
 * Date: 11/3/2018
 */

locals {
  public_cidr = "0.0.0.0/0"

  sandbox_public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
  sandbox_private_subnet_cidrs = []

  sandbox_vpc_sg_rules = [
    {
      # Inbound traffic from the internet
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      type        = "ingress"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = local.public_cidr
    },
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for health checks
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for HTTP
      type        = "egress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for HTTPS
      type        = "egress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = local.public_cidr
    },
  ]

  sandbox_public_subnet_azs  = ["us-east-1a", "us-east-1b"]
  sandbox_private_subnet_azs = []
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/root"
    region  = "us-east-1"
  }
}

module "sandbox-vpc" {
  source = "github.com/ajarombek/terraform-modules//vpc?ref=v0.1.9"

  # Mandatory arguments
  name     = "sandbox"
  tag_name = "sandbox"

  # Optional arguments
  vpc_cidr             = "10.2.0.0/16"
  public_subnet_count  = 2
  private_subnet_count = 0
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = false

  public_subnet_names  = ["sandbox-vpc-fearless-public-subnet", "sandbox-vpc-speaknow-public-subnet"]
  private_subnet_names = []

  public_subnet_azs    = local.sandbox_public_subnet_azs
  private_subnet_azs   = local.sandbox_private_subnet_azs
  public_subnet_cidrs  = local.sandbox_public_subnet_cidrs
  private_subnet_cidrs = local.sandbox_private_subnet_cidrs

  enable_security_groups = true
  sg_rules               = local.sandbox_vpc_sg_rules
}