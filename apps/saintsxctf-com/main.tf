/**
 * The VPC for all the saintsxctf.com infrastructure
 * Author: Andrew Jarombek
 * Date: 11/27/2018
 */

locals {
  public_cidr = "0.0.0.0/0"
  saintsxctf_public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  saintsxctf_private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

  saintsxctf_public_subnet_sg_rules_0 = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Inbound traffic for SSH
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
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

  saintsxctf_public_subnet_sg_rules_1 = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Inbound traffic for SSH
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
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
      # Outbound traffic for HTTP
      type = "egress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for HTTPS
      type = "egress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    }
  ]

  saintsxctf_private_subnet_sg_rules = [
    {
      # Inbound traffic for SSH
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${local.saintsxctf_public_subnet_cidrs[0]}"
    },
    {
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${local.saintsxctf_public_subnet_cidrs[1]}"
    },
    {
      # Inbound traffic for MySQL
      type = "ingress"
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = "${local.saintsxctf_public_subnet_cidrs[0]}"
    },
    {
      type = "ingress"
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = "${local.saintsxctf_public_subnet_cidrs[1]}"
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

  saintsxctf_public_subnet_azs = [
    "us-east-1b",
    "us-east-1d"
  ]

  saintsxctf_private_subnet_azs = [
    "us-east-1e",
    "us-east-1c"
  ]
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
  source = "github.com/ajarombek/terraform-modules//vpc"

  # Mandatory arguments
  name = "saintsxctfcom"
  tag_name = "SaintsXCTFcom"

  # Optional arguments
  public_subnet_count = 2
  private_subnet_count = 2
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = false

  public_subnet_azs = "${local.saintsxctf_public_subnet_azs}"
  private_subnet_azs = "${local.saintsxctf_private_subnet_azs}"
  public_subnet_cidrs = "${local.saintsxctf_public_subnet_cidrs}"
  private_subnet_cidrs = "${local.saintsxctf_private_subnet_cidrs}"

  enable_public_security_group = false

  enable_private_security_group = true
  private_subnet_sg_rules = "${local.saintsxctf_private_subnet_sg_rules}"
}

module "saintsxctf-com-public-subnet-security-group-0" {
  source = "github.com/ajarombek/terraform-modules//security-group"

  # Mandatory arguments
  name = "saintsxctfcom-vpc-public-security-0"
  tag_name = "SaintsXCTFcom VPC Public Subnet Security 0"
  vpc_id = "${module.saintsxctf-com-vpc.vpc_id}"

  # Optional arguments
  sg_rules = "${local.saintsxctf_public_subnet_sg_rules_0}"
  description = "Allow all incoming connections to public resources"
}

module "saintsxctf-com-public-subnet-security-group-1" {
  source = "github.com/ajarombek/terraform-modules//security-group"

  # Mandatory arguments
  name = "saintsxctfcom-vpc-public-security-1"
  tag_name = "SaintsXCTFcom VPC Public Subnet Security 1"
  vpc_id = "${module.saintsxctf-com-vpc.vpc_id}"

  # Optional arguments
  sg_rules = "${local.saintsxctf_public_subnet_sg_rules_1}"
  description = "Allow incoming SSH connections to bastion host"
}