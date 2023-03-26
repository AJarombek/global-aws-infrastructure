/**
 * ACM resources needed for the *.jenkins.jarombek.io domain.
 * Author: Andrew Jarombek
 * Date: 6/5/2020
 */

#---------------------------------
# Protects '*.jenkins.jarombek.io'
#---------------------------------

module "jenkins-jarombek-io-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.13"

  # Mandatory arguments
  name              = "jenkins-jarombek-io-acm-certificate"
  route53_zone_name = "jarombek.io."
  acm_domain_name   = "*.jenkins.jarombek.io"

  # Optional arguments
  route53_zone_private = false

  tags = {
    Name        = "jenkins-jarombek-io-acm-certificate"
    Application = "jarombek-io"
    Environment = "production"
    Terraform   = var.terraform_tag
  }
}

#-------------------------------------
# Protects '*.dev.jenkins.jarombek.io'
#-------------------------------------

module "dev-jenkins-jarombek-io-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.13"

  # Mandatory arguments
  name              = "dev-jenkins-jarombek-io-acm-certificate"
  route53_zone_name = "jarombek.io."
  acm_domain_name   = "*.dev.jenkins.jarombek.io"

  # Optional arguments
  route53_zone_private = false

  tags = {
    Name        = "dev-jenkins-jarombek-io-acm-certificate"
    Application = "jarombek-io"
    Environment = "development"
    Terraform   = var.terraform_tag
  }
}