/**
 * Infrastructure for the dev.jenkins.jarombek.io ECS cluster.
 * Author: Andrew Jarombek
 * Date: 6/4/2020
 */

locals {
  prod = false
  env = "development"
  public_cidr = "0.0.0.0/0"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.66.0"
    kubernetes = ">= 1.11"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/jenkins-ecs/env/dev"
    region = "us-east-1"
  }
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  prod = local.prod
}