# Top-Level AWS Infrastructure for my cloud
# Author: Andrew Jarombek
# Date: 11/3/2018

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/root"
    region = "us-east-1"
  }
}

module "resources-vpc" {
  source = "./vpc"

  vpc_tag_name = "Resources VPC"
  public_subnet_tag_name = "Resources VPC Public Subnet"
  private_subnet_tag_name = "Resources VPC Private Subnet"
  internet_gateway_tag_name = "Resources VPC Internet Gateway"
}

module "sandbox-vpc" {
  source = "./vpc"

  vpc_tag_name = "Sandbox VPC"
  public_subnet_tag_name = "Sandbox VPC Public Subnet"
  private_subnet_tag_name = "Sandbox VPC Private Subnet"
  internet_gateway_tag_name = "Sandbox VPC Internet Gateway"
}