/**
 * Route53 Configuration for my cloud
 * Author: Andrew Jarombek
 * Date: 11/19/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.15"

  required_providers {
    aws = ">= 3.27.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/route53"
    region  = "us-east-1"
  }
}

#---------------------------------------
# Existing AWS Resources used by Route53
#---------------------------------------

data "aws_sns_topic" "alert-email" {
  name = "alert-email-topic"
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

resource "aws_route53_zone" "jarombek-io-zone" {
  name = "jarombek.io."
}

resource "aws_route53_record" "jarombek-io-ns" {
  name    = "jarombek.io."
  type    = "NS"
  zone_id = aws_route53_zone.jarombek-io-zone.zone_id
  ttl     = 172800

  records = [
    aws_route53_zone.jarombek-io-zone.name_servers[0],
    aws_route53_zone.jarombek-io-zone.name_servers[1],
    aws_route53_zone.jarombek-io-zone.name_servers[2],
    aws_route53_zone.jarombek-io-zone.name_servers[3],
  ]
}

resource "aws_route53_health_check" "jarombek-com-health-check" {
  type              = "HTTPS"
  fqdn              = "jarombek.com"
  port              = 443
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name        = "jarombek-com-health-check"
    Application = "jarombek-com"
    Environment = "production"
  }
}

resource "aws_cloudwatch_metric_alarm" "jarombek-com-health-check-alarm" {
  alarm_name          = "jarombek-com-health-check-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Minimum"
  threshold           = 0
  alarm_description   = "Determine if jarombek.com is down."

  alarm_actions             = [data.aws_sns_topic.alert-email.arn]
  ok_actions                = []
  insufficient_data_actions = []

  dimensions = {
    HealthCheckId = aws_route53_health_check.jarombek-com-health-check.id
  }

  tags = {
    Name        = "jarombek-com-health-check-alarm"
    Application = "jarombek-com"
    Environment = "production"
  }
}

resource "aws_route53_health_check" "saints-xctf-com-health-check" {
  type              = "HTTPS"
  fqdn              = "saintsxctf.com"
  port              = 443
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name        = "saints-xctf-com-health-check"
    Application = "saints-xctf-com"
    Environment = "production"
  }
}

resource "aws_cloudwatch_metric_alarm" "saints-xctf-com-health-check-alarm" {
  alarm_name          = "saints-xctf-com-health-check-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Minimum"
  threshold           = 0
  alarm_description   = "Determine if saintsxctf.com is down."

  alarm_actions             = [data.aws_sns_topic.alert-email.arn]
  ok_actions                = []
  insufficient_data_actions = []

  dimensions = {
    HealthCheckId = aws_route53_health_check.saints-xctf-com-health-check.id
  }

  tags = {
    Name        = "saints-xctf-com-health-check-alarm"
    Application = "saints-xctf-com"
    Environment = "production"
  }
}

resource "aws_route53_health_check" "saints-xctf-com-api-health-check" {
  type              = "HTTPS"
  fqdn              = "api.saintsxctf.com"
  port              = 443
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name        = "saints-xctf-com-api-health-check"
    Application = "saints-xctf-com"
    Environment = "production"
  }
}

resource "aws_cloudwatch_metric_alarm" "saints-xctf-com-api-health-check-alarm" {
  alarm_name          = "saints-xctf-com-api-health-check-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Minimum"
  threshold           = 0
  alarm_description   = "Determine if api.saintsxctf.com is down."

  alarm_actions             = [data.aws_sns_topic.alert-email.arn]
  ok_actions                = []
  insufficient_data_actions = []

  dimensions = {
    HealthCheckId = aws_route53_health_check.saints-xctf-com-api-health-check.id
  }

  tags = {
    Name        = "saints-xctf-com-api-health-check-alarm"
    Application = "saints-xctf-com"
    Environment = "production"
  }
}