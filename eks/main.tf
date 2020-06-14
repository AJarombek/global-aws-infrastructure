/**
 * Infrastructure for an EKS cluster used by the entire AWS cloud account.
 * Author: Andrew Jarombek
 * Date: 6/12/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12.26"

  required_providers {
    aws = ">= 2.66.0"
    random = ">= 2.2"
    null = ">= 2.1"
    local = ">= 1.4"
    template = ">= 2.1"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/eks"
    region = "us-east-1"
  }
}

#----------------
# Local Variables
#----------------

locals {
  public_cidr = "0.0.0.0/0"
  cluster_name = "andrew-jarombek-eks-cluster"

  kubernetes_public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  kubernetes_private_subnet_cidrs = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]

  kubernetes_vpc_sg_rules = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      type = "ingress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      type = "ingress"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = local.public_cidr
    },
    {
      type = "ingress"
      from_port = 22
      to_port = 22
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

  kubernetes_public_subnet_azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  kubernetes_private_subnet_azs = [
    "us-east-1b",
    "us-east-1c"
  ]

  subnet_tags = {
    Application = "kubernetes",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "kubernetes.io/role/elb" = "1"
  }

  kubernetes_public_subnet_tags = [local.subnet_tags, local.subnet_tags]
  kubernetes_private_subnet_tags = [local.subnet_tags, local.subnet_tags]
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_eks_cluster" "cluster" {
  name = module.andrew-jarombek-eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.andrew-jarombek-eks-cluster.cluster_id
}

#----------------------
# AWS Resources for EKS
#----------------------

module "kubernetes-vpc" {
  source = "github.com/ajarombek/terraform-modules//vpc?ref=v0.1.11"

  # Mandatory arguments
  name = "kubernetes"
  tag_name = "kubernetes"

  # Optional arguments
  public_subnet_count = 2
  private_subnet_count = 2
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = false

  public_subnet_names = ["kubernetes-dotty-public-subnet", "kubernetes-grandmas-blanket-public-subnet"]
  private_subnet_names = ["kubernetes-lily-private-subnet", "kubernetes-teddy-private-subnet"]

  public_subnet_azs = local.kubernetes_public_subnet_azs
  private_subnet_azs = local.kubernetes_private_subnet_azs
  public_subnet_cidrs = local.kubernetes_public_subnet_cidrs
  private_subnet_cidrs = local.kubernetes_private_subnet_cidrs

  public_subnet_tags = local.kubernetes_public_subnet_tags
  private_subnet_tags = local.kubernetes_private_subnet_tags

  public_subnet_map_public_ip_on_launch = true

  enable_security_groups = true
  sg_rules = local.kubernetes_vpc_sg_rules
}

module "andrew-jarombek-eks-cluster" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 12.1.0"

  create_eks = true
  cluster_name = local.cluster_name
  cluster_version = "1.16"
  vpc_id = module.kubernetes-vpc.vpc_id
  subnets = module.kubernetes-vpc.public_subnet_ids

  worker_groups = [
    {
      instance_type = "t2.medium"
      asg_max_size = 2
      asg_desired_capacity = 1
    }
  ]
}
