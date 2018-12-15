/**
 * Varaibles for creating a VPC
 * Author: Andrew Jarombek
 * Date: 11/4/2018
 */

# naming resources
variable "name" {
  description = "Name to use as a prefix for different resources"
}

variable "tag_name" {
  description = "Name to use for the Name property in the Tag objects"
}

# aws_vpc resource
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

# aws_subnet resources
variable "public_subnet_cidr" {
  description = "The CIDR for the VPC public subnet"
  default = "10.0.1.0/24"
}

variable "public_subnet_sg_rules" {
  description = "A list of security group rules for the VPC public subnet"
  type = "list"
  default = []
}

variable "public_subnet_sg_cidr_blocks" {
  description = "A list of CIDR blocks for the security group rules in the VPC public subnet"
  type = "list"
  default = []
}

variable "private_subnet_cidr" {
  description = "The CIDR for the VPC private subnet"
  default = "10.0.2.0/24"
}

variable "private_subnet_sg_rules" {
  description = "A list of security group rules for the VPC private subnet"
  type = "list"
  default = []
}

variable "private_subnet_sg_cidr_blocks" {
  description = "A list of CIDR blocks for the security group rules in the VPC private subnet"
  type = "list"
  default = []
}

# aws_route_table resources
variable "routing_table_cidr" {
  description = "The CIDR block for incoming traffic to the public subnet"
  default = "0.0.0.0/0"
}