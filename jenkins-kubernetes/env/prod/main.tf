/**
 * Infrastructure for the jenkins.jarombek.io ECS cluster.
 * Author: Andrew Jarombek
 * Date: 6/4/2020
 */

locals {
  prod        = true
  env         = "production"
  public_cidr = "0.0.0.0/0"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.15"

  required_providers {
    aws        = ">= 2.66.0"
    kubernetes = ">= 1.11"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/jenkins-ecs/env/prod"
    region  = "us-east-1"
  }
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  prod   = local.prod
}