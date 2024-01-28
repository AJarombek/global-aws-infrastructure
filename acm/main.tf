/**
 * ACM certificates for the jarombek.io applications
 * Author: Andrew Jarombek
 * Date: 2/1/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.6.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/acm"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "global-aws-infrastructure/acm"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_route53_zone" "jarombek-io-zone" {
  name         = "jarombek.io."
  private_zone = false
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

module "jarombek-io-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.13"

  # Mandatory arguments
  name              = "jarombek-io-acm-certificate"
  route53_zone_name = "jarombek.io."
  acm_domain_name   = "*.jarombek.io"

  # Optional arguments
  route53_zone_private = false

  tags = {
    Name        = "jarombek-io-acm-certificate"
    Application = "jarombek-io"
    Environment = "production"
    Terraform   = local.terraform_tag
  }
}