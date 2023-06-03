/**
 * Infrastructure for both the dev.jenkins.jarombek.io and jenkins.jarombek.io ECS clusters.
 * Author: Andrew Jarombek
 * Date: 6/7/2020
 */

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
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/jenkins-ecs/env/all"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/jenkins-ecs/env/all"
}

module "acm" {
  source        = "../../modules/acm"
  terraform_tag = local.terraform_tag
}

module "ecr" {
  source        = "../../modules/ecr"
  terraform_tag = local.terraform_tag
}