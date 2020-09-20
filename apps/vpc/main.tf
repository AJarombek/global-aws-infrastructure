/**
 * The VPC for all the saintsxctf.com infrastructure
 * Author: Andrew Jarombek
 * Date: 11/27/2018
 */

locals {
  public_cidr = "0.0.0.0/0"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

  vpc_sg_rules = [
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
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for HTTP
      type = "egress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for HTTPS
      type = "egress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
  ]

  public_subnet_azs = [
    "us-east-1b",
    "us-east-1d",
    "us-east-1a",
    "us-east-1b"
  ]

  private_subnet_azs = [
    "us-east-1e",
    "us-east-1c",
  ]

  saints_xctf_subnet_tags = {
    Application = "saints-xctf"
  }

  kubernetes_subnet_tags = {
    Application = "all"
  }

  public_subnet_tags = [
    local.saints_xctf_subnet_tags,
    local.saints_xctf_subnet_tags,
    local.kubernetes_subnet_tags,
    local.kubernetes_subnet_tags
  ]
  private_subnet_tags = [
    local.saints_xctf_subnet_tags,
    local.saints_xctf_subnet_tags
  ]
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.7.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/apps/vpc"
    region = "us-east-1"
  }
}

module "application-vpc" {
  source = "github.com/ajarombek/terraform-modules//vpc?ref=v0.1.12"

  # Mandatory arguments
  name = "application"
  tag_name = "application"

  # Optional arguments
  vpc_cidr = "10.0.0.0/16"
  public_subnet_count = 4
  private_subnet_count = 2
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = false

  public_subnet_names = [
    "saints-xctf-com-lisag-public-subnet",
    "saints-xctf-com-megank-public-subnet",
    "kubernetes-grandmas-blanket-public-subnet",
    "kubernetes-dotty-public-subnet"
  ]
  private_subnet_names = [
    "saints-xctf-com-cassiah-private-subnet",
    "saints-xctf-com-carolined-private-subnet"
  ]

  public_subnet_azs    = local.public_subnet_azs
  private_subnet_azs   = local.private_subnet_azs
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs

  public_subnet_tags = local.public_subnet_tags
  private_subnet_tags = local.private_subnet_tags

  public_subnet_map_public_ip_on_launch = true

  enable_security_groups = true
  sg_rules = local.vpc_sg_rules
}