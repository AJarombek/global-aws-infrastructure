/**
 * ACM resources needed for the *.jenkins.jarombek.io domain.
 * Author: Andrew Jarombek
 * Date: 6/5/2020
 */

#---------------------------------
# Protects '*.jenkins.jarombek.io'
#---------------------------------

module "jenkins-jarombek-io-acm-certificate" {
  source  = "github.com/ajarombek/terraform-modules//acm-certificate?ref=v0.1.9"
  enabled = true

  # Mandatory arguments
  name            = "jenkins-jarombek-io-acm-certificate"
  tag_name        = "jenkins-jarombek-io-acm-certificate"
  tag_application = "jarombek-io"
  tag_environment = "production"

  route53_zone_name = "jarombek.io."
  acm_domain_name   = "*.jenkins.jarombek.io"

  # Optional arguments
  route53_zone_private = false
}

#-------------------------------------
# Protects '*.dev.jenkins.jarombek.io'
#-------------------------------------

module "dev-jenkins-jarombek-io-acm-certificate" {
  source  = "github.com/ajarombek/terraform-modules//acm-certificate?ref=v0.1.9"
  enabled = true

  # Mandatory arguments
  name            = "dev-jenkins-jarombek-io-acm-certificate"
  tag_name        = "dev-jenkins-jarombek-io-acm-certificate"
  tag_application = "jarombek-io"
  tag_environment = "development"

  route53_zone_name = "jarombek.io."
  acm_domain_name   = "*.dev.jenkins.jarombek.io"

  # Optional arguments
  route53_zone_private = false
}