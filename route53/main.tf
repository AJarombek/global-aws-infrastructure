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
resource "aws_route53_zone" "jarombek-io" {
  name = "jarombek.org."
}

resource "aws_route53_record" "jarombek-io-ns" {
  name = "jarombek.org."
  type = "NS"
  zone_id = "${aws_route53_zone.jarombek-io.zone_id}"
  ttl = 172800

  records = [
    "${aws_route53_zone.jarombek-io.name_servers.0}",
    "${aws_route53_zone.jarombek-io.name_servers.1}",
    "${aws_route53_zone.jarombek-io.name_servers.2}",
    "${aws_route53_zone.jarombek-io.name_servers.3}"
  ]
}