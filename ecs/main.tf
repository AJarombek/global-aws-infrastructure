/**
 * Infrastructure for creating an ECS cluster for my small applications.
 * Author: Andrew Jarombek
 * Date: 1/13/2024
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.6.6"

  required_providers {
    aws = "~> 5.32.1"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/ecs"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/ecs"
}

resource "aws_ecs_cluster" "andrew-jarombek" {
  name = "andrew-jarombek-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "andrew-jarombek-ecs-cluster"
    Application = "all"
    Environment = "all"
    Terraform   = local.terraform_tag
  }
}
