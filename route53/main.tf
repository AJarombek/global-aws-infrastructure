/**
 * Route53 Configuration for my cloud
 * Author: Andrew Jarombek
 * Date: 11/19/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/route53"
    region = "us-east-1"
  }
}

# Route53 Config
resource "aws_route53_zone" "jarombek-com" {
  name = "jarombek.com."
}