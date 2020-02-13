/**
 * Route53 Configuration for my cloud
 * Author: Andrew Jarombek
 * Date: 11/19/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/route53"
    region  = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_s3_bucket" "global-jarombek-io-bucket" {
  bucket = "global.jarombek.io"
}

data "aws_s3_bucket" "www-global-jarombek-io-bucket" {
  bucket = "www.global.jarombek.io"
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

resource "aws_route53_zone" "jarombek-io-zone" {
  name = "jarombek.io."
}

resource "aws_route53_record" "jarombek-io-ns" {
  name = "jarombek.io."
  type = "NS"
  zone_id = aws_route53_zone.jarombek-io-zone.zone_id
  ttl = 172800

  records = [
    aws_route53_zone.jarombek-io-zone.name_servers[0],
    aws_route53_zone.jarombek-io-zone.name_servers[1],
    aws_route53_zone.jarombek-io-zone.name_servers[2],
    aws_route53_zone.jarombek-io-zone.name_servers[3],
  ]
}