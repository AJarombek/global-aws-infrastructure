/**
 * Route53 Configuration for my Jenkins server
 * Author: Andrew Jarombek
 * Date: 3/9/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/jenkins-route53"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_route53_zone" "jarombek-io-zone" {
  name = "jarombek.io."
}

data "aws_elb" "jenkins-server-elb" {
  name = "global-jenkins-server-elb"
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

resource "aws_route53_record" "jenkins-jarombek-io-a" {
  name = "jenkins.jarombek.io"
  type = "A"
  zone_id = data.aws_route53_zone.jarombek-io-zone.zone_id

  alias {
    evaluate_target_health = true
    name = data.aws_elb.jenkins-server-elb.dns_name
    zone_id = data.aws_elb.jenkins-server-elb.zone_id
  }
}