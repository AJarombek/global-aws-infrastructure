/**
 * Infrastructure for the dev.jenkins.jarombek.io ECS cluster.
 * Author: Andrew Jarombek
 * Date: 6/4/2020
 */

locals {
  prod = false
  env = "dev"
  public_cidr = "0.0.0.0/0"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/jenkins-ecs/env/dev"
    region = "us-east-1"
  }
}

module "acm" {
  source = "../../modules/acm"
  prod = local.prod
}

module "alb" {
  source = "../../modules/alb"
  prod = local.prod

  load-balancer-sg-rules-cidr = [
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
      # Outbound traffic on all ports
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = local.public_cidr
    }
  ]

  load-balancer-sg-rules-source = []
}

module "ecs" {
  source = "../../modules/ecs"
  prod = local.prod
  jenkins-jarombek-io-desired-count = 1
  alb-security-group = module.alb.alb-security-group
  jenkins-jarombek-io-lb-target-group = module.alb.jenkins-jarombek-io-lb-target-group

  dependencies = [
    module.alb.depended_on
  ]
}