/**
 * Infrastructure for both the dev.jenkins.jarombek.io and jenkins.jarombek.io ECS clusters.
 * Author: Andrew Jarombek
 * Date: 6/7/2020
 */


provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/jenkins-ecs/env/all"
    region = "us-east-1"
  }
}

module "acm" {
  source = "../../modules/acm"
}