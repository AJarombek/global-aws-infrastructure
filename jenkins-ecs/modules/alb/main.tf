/**
 * ALB for an ECS cluster
 * Author: Andrew Jarombek
 * Date: 6/5/2020
 */

locals {
  env = var.prod ? "prod" : "dev"
  env_tag = var.prod ? "production" : "development"
  domain_cert = var.prod ? "*.jarombek.io" : "*.jenkins.jarombek.io"
  wildcard_domain_cert = var.prod ? "*.jenkins.jarombek.io" : "*.dev.jenkins.jarombek.io"
  web_domain = var.prod ? "jenkins.jarombek.io." : "dev.jenkins.jarombek.io."
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_vpc" "resources-vpc" {
  tags = {
    Name = "resources-vpc"
  }
}

data "aws_subnet" "resources-dotty-public-subnet" {
  tags = {
    Name = "resources-dotty-public-subnet"
  }
}

data "aws_subnet" "resources-grandmas-blanket-public-subnet" {
  tags = {
    Name = "resources-grandmas-blanket-public-subnet"
  }
}

data "aws_acm_certificate" "jenkins-jarombek-io-certificate" {
  domain = local.domain_cert
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "jenkins-jarombek-io-wildcard-certificate" {
  domain = local.wildcard_domain_cert
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "jarombek-io" {
  name = "jarombek.io."
}

#--------------
# ALB Resources
#--------------

resource "aws_lb" "jenkins-jarombek-io-lb" {
  name = "jenkins-jarombek-io-${local.env}-alb"

  subnets = [
    data.aws_subnet.resources-dotty-public-subnet.id,
    data.aws_subnet.resources-grandmas-blanket-public-subnet.id
  ]

  security_groups = [aws_security_group.jenkins-jarombek-io-lb-security-group.id]

  tags = {
    Name = "jenkins-jarombek-io-${local.env}-alb"
    Application = "jenkins-jarombek-io"
    Environment = local.env_tag
  }
}

resource "aws_lb_target_group" "jenkins-jarombek-io-lb-target-group" {
  name = "jenkins-${local.env}-lb-target"

  health_check {
    enabled = true
    interval = 10
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 2
    port = 8080
    protocol = "HTTP"
    path = "/"
    matcher = "200-299"
  }

  port = 8080
  protocol = "HTTP"
  vpc_id = data.aws_vpc.resources-vpc.id
  target_type = "ip"

  tags = {
    Name = "jenkins-jarombek-io-${local.env}-lb-target-group"
    Application = "jenkins-jarombek-io"
    Environment = local.env_tag
  }
}

resource "aws_lb_listener" "jenkins-jarombek-io-lb-listener-https" {
  load_balancer_arn = aws_lb.jenkins-jarombek-io-lb.arn
  port = 443
  protocol = "HTTPS"

  certificate_arn = data.aws_acm_certificate.jenkins-jarombek-io-certificate.arn

  default_action {
    target_group_arn = aws_lb_target_group.jenkins-jarombek-io-lb-target-group.arn
    type = "forward"
  }
}

resource "aws_lb_listener_certificate" "jenkins-jarombek-io-lb-listener-wc-cert" {
  listener_arn    = aws_lb_listener.jenkins-jarombek-io-lb-listener-https.arn
  certificate_arn = data.aws_acm_certificate.jenkins-jarombek-io-wildcard-certificate.arn
}

resource "aws_lb_listener" "jenkins-jarombek-io-lb-listener-http" {
  load_balancer_arn = aws_lb.jenkins-jarombek-io-lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group" "jenkins-jarombek-io-lb-security-group" {
  name = "jenkins-jarombek-io-${local.env}-lb-security-group"
  vpc_id = data.aws_vpc.resources-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "jenkins-jarombek-io-${local.env}-lb-security-group"
    Application = "jenkins-jarombek-io"
  }
}

resource "aws_security_group_rule" "jenkins-jarombek-io-lb-security-group-rule-cidr" {
  count = length(var.load-balancer-sg-rules-cidr)

  security_group_id = aws_security_group.jenkins-jarombek-io-lb-security-group.id
  type = lookup(var.load-balancer-sg-rules-cidr[count.index], "type", "ingress")

  from_port = lookup(var.load-balancer-sg-rules-cidr[count.index], "from_port", 0)
  to_port = lookup(var.load-balancer-sg-rules-cidr[count.index], "to_port", 0)
  protocol = lookup(var.load-balancer-sg-rules-cidr[count.index], "protocol", "-1")

  cidr_blocks = [lookup(var.load-balancer-sg-rules-cidr[count.index], "cidr_blocks", "")]
}

resource "aws_security_group_rule" "jenkins-jarombek-io-lb-security-group-rule-source" {
  count = length(var.load-balancer-sg-rules-source)

  security_group_id = aws_security_group.jenkins-jarombek-io-lb-security-group.id
  type = lookup(var.load-balancer-sg-rules-source[count.index], "type", "ingress")

  from_port = lookup(var.load-balancer-sg-rules-source[count.index], "from_port", 0)
  to_port = lookup(var.load-balancer-sg-rules-source[count.index], "to_port", 0)
  protocol = lookup(var.load-balancer-sg-rules-source[count.index], "protocol", "-1")

  source_security_group_id = lookup(var.load-balancer-sg-rules-source[count.index], "source_sg", "")
}

#--------------
# DNS Resources
#--------------

resource "aws_route53_record" "jarombek_a" {
  name = local.web_domain
  type = "A"
  zone_id = data.aws_route53_zone.jarombek-io.zone_id

  alias {
    evaluate_target_health = true
    name = aws_lb.jenkins-jarombek-io-lb.dns_name
    zone_id = aws_lb.jenkins-jarombek-io-lb.zone_id
  }
}

resource "aws_route53_record" "jarombek_cname" {
  name = "www.${local.web_domain}"
  type = "CNAME"
  zone_id = data.aws_route53_zone.jarombek-io.zone_id
  ttl = 300

  records = [local.web_domain]
}