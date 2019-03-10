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
  zone_id = "${aws_route53_zone.jarombek-io-zone.zone_id}"
  ttl = 172800

  records = [
    "${aws_route53_zone.jarombek-io-zone.name_servers.0}",
    "${aws_route53_zone.jarombek-io-zone.name_servers.1}",
    "${aws_route53_zone.jarombek-io-zone.name_servers.2}",
    "${aws_route53_zone.jarombek-io-zone.name_servers.3}"
  ]
}

resource "aws_route53_record" "global-jarombek-io-a" {
  name = "global.jarombek.io."
  type = "A"
  zone_id = "${aws_route53_zone.jarombek-io-zone.zone_id}"

  # TTL for all alias records is 60 seconds
  alias {
    evaluate_target_health = false
    name = "${data.aws_s3_bucket.global-jarombek-io-bucket.website_domain}"
    zone_id = "${data.aws_s3_bucket.global-jarombek-io-bucket.hosted_zone_id}"
  }
}

resource "aws_route53_record" "www-global-jarombek-io-a" {
  name = "www.global.jarombek.io."
  type = "A"
  zone_id = "${aws_route53_zone.jarombek-io-zone.zone_id}"

  alias {
    evaluate_target_health = false
    name = "${data.aws_s3_bucket.www-global-jarombek-io-bucket.website_domain}"
    zone_id = "${data.aws_s3_bucket.www-global-jarombek-io-bucket.hosted_zone_id}"
  }
}