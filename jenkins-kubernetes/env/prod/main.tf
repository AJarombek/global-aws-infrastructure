/**
 * Infrastructure for the jenkins.jarombek.io ECS cluster.
 * Author: Andrew Jarombek
 * Date: 6/4/2020
 */

locals {
  prod          = true
  env           = "production"
  public_cidr   = "0.0.0.0/0"
  terraform_tag = "global-aws-infrastructure/jenkins-ecs/env/prod"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.3.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.61.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/jenkins-ecs/env/prod"
    region  = "us-east-1"
  }
}

module "kubernetes" {
  source        = "../../modules/kubernetes"
  prod          = local.prod
  terraform_tag = local.terraform_tag
}