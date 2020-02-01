/**
 * ACM certificates for the jarombek.io applications
 * Author: Andrew Jarombek
 * Date: 2/1/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/acm"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_route53_zone" "jarombek-io-zone" {
  name = "jarombek.io."
  private_zone = false
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

#--------------------------------
# Protects '*.global.jarombek.io'
#--------------------------------

module "jarombek-io-global-acm-certificate" {
  source = "github.com/ajarombek/terraform-modules//acm-certificate?ref=v0.1.8"

  # Mandatory arguments
  name = "jarombek-io-global-acm-certificate"
  tag_name = "jarombek-io-global-acm-certificate"
  tag_application = "jarombek-io"
  tag_environment = "production"

  route53_zone_name = "jarombek.io."
  acm_domain_name = "*.global.jarombek.io"

  # Optional arguments
  route53_zone_private = false
}

#-------------------------
# Protects '*.jarombek.io'
#-------------------------

module "jarombek-io-acm-certificate" {
  source = "github.com/ajarombek/terraform-modules//acm-certificate?ref=v0.1.8"

  # Mandatory arguments
  name = "jarombek-io-acm-certificate"
  tag_name = "jarombek-io-acm-certificate"
  tag_application = "jarombek-io"
  tag_environment = "production"

  route53_zone_name = "jarombek.io."
  acm_domain_name = "*.jarombek.io"

  # Optional arguments
  route53_zone_private = false
}