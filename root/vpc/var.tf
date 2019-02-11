/**
 * Varaibles for creating a VPC
 * Author: Andrew Jarombek
 * Date: 11/4/2018
 */

#-----------------
# Naming Resources
#-----------------

variable "name" {
  description = "Name to use as a prefix for different resources"
}

variable "tag_name" {
  description = "Name to use for the Name property in the Tag objects"
}

#------------------
# aws_vpc Resources
#------------------

variable "vpc_cidr" {
  description = "The CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "enable_dns_support" {
  description = "Setting DNS support to 'true' enables private DNS"
  default = false
}

variable "enable_dns_hostnames" {
  description = "Setting DNS hostnames to 'true' enables private DNS"
  default = false
}

#---------------------
# aws_subnet Resources
#---------------------

#--------------
# Public Subnet
#--------------

variable "public_subnet_count" {
  description = "The number of public subnets in the VPC"
  default = 1
}

variable "public_subnet_cidr" {
  description = "The CIDR for the VPC public subnet"
  default = "10.0.1.0/24"
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the VPC public subnets"
  type = "list"
  default = []
}

variable "basic_public_subnet_sg_rules" {
  description = "Whether or not basic public subnet security group rules are used"
  default = true
}

variable "public_subnet_sg_rules" {
  description = "A list of security group rules for the VPC public subnet"
  type = "list"
  default = []
}

variable "public_subnet_sg_rules_advanced" {
  description = "A map of security group rules for each VPC public subnet"
  type = "map"
  default = {}
}

variable "public_subnet_sg_cidr_blocks" {
  description = "A list of CIDR blocks for the security group rules in the VPC public subnet"
  type = "list"
  default = []
}

#---------------
# Private Subnet
#---------------

variable "private_subnet_count" {
  description = "The number of private subnets in the VPC"
  default = 1
}

variable "private_subnet_cidr" {
  description = "The CIDR for the VPC private subnet"
  default = "10.0.2.0/24"
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the VPC private subnets"
  type = "list"
  default = []
}

variable "basic_private_subnet_sg_rules" {
  description = "Whether or not basic private subnet security group rules are used"
  default = true
}

variable "private_subnet_sg_rules" {
  description = "A list of security group rules for the VPC private subnet"
  type = "list"
  default = []
}

variable "private_subnet_sg_rules_advanced" {
  description = "A map of security group rules for each VPC private subnet"
  type = "map"
  default = {}
}

variable "private_subnet_sg_cidr_blocks" {
  description = "A list of CIDR blocks for the security group rules in the VPC private subnet"
  type = "list"
  default = []
}

variable "enable_nat_gateway" {
  description = "Turn on or off the NAT gateway, giving internet access to the private subnet (NAT costs a lot!)"
  default = false
}

#--------------------------
# aws_route_table Resources
#--------------------------

variable "routing_table_cidr" {
  description = "The CIDR block for incoming traffic to the public subnet"
  default = "0.0.0.0/0"
}