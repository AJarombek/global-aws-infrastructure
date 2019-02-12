/**
 * Top-Level AWS Infrastructure for my cloud
 * Author: Andrew Jarombek
 * Date: 11/3/2018
 */

locals {
  public_cidr = "0.0.0.0/0"
  resources_public_subnet_cidr = "10.0.1.0/24"
  resources_private_subnet_cidr = "10.0.2.0/24"

  sandbox_public_subnet_cidr = "10.0.1.0/24"
  sandbox_private_subnet_cidr = "10.0.2.0/24"

  resources_public_subnet_sg_rules = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
      # 'null' is coming in Terraform v0.12
      # source_security_group_id = null
    },
    {
      # ICMP is used for sending error messages or operational information.  ICMP has no ports,
      # and a common tool that uses ICMP is ping.
      type = "ingress"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      type = "ingress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = "${local.public_cidr}"
    }
  ]

  resources_private_subnet_sg_rules = [
    {
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${local.resources_public_subnet_cidr}"
    },
    {
      # Inbound traffic for ping
      type = "ingress"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = "${local.public_cidr}"
    }
  ]

  sandox_public_subnet_sg_rules = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = "${local.public_cidr}"
    }
  ]

  sandox_private_subnet_sg_rules = []
}

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
  public_subnet_count = 1
  private_subnet_count = 1
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = false
  public_subnet_cidr = "${local.resources_public_subnet_cidr}"
  private_subnet_cidr = "${local.resources_private_subnet_cidr}"

  enable_public_security_group = true
  public_subnet_sg_rules = "${local.resources_public_subnet_sg_rules}"

  enable_private_security_group = true
  private_subnet_sg_rules = "${local.resources_private_subnet_sg_rules}"
}

module "sandbox-vpc" {
  source = "./vpc"

  # Mandatory arguments
  name = "sandbox"
  tag_name = "Sandbox"

  # Optional arguments
  public_subnet_count = 1
  private_subnet_count = 1
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = false
  public_subnet_cidr = "${local.sandbox_public_subnet_cidr}"
  private_subnet_cidr = "${local.sandbox_private_subnet_cidr}"

  enable_public_security_group = true
  public_subnet_sg_rules = "${local.sandox_public_subnet_sg_rules}"

  enable_private_security_group = true
  private_subnet_sg_rules = "${local.sandox_private_subnet_sg_rules}"
}