# Varaibles for creating a VPC
# Author: Andrew Jarombek
# Date: 11/4/2018

# aws_vpc resource
variable "vpc_cidr" {
  description = "The CIDR for the Resources VPC"
  default = "10.0.0.0/16"
}

variable "vpc_tag_name" {
  description = "The Name property in the Tag object for the VPC"
}

# aws_subnet resources
variable "public_subnet_cidr" {
  description = "The CIDR for the Resources VPC public subnet"
  default = "10.0.1.0/24"
}

variable "public_subnet_tag_name" {
  description = "The Name property in the Tag object for the public subnet"
}

variable "private_subnet_cidr" {
  description = "The CIDR for the Resources VPC private subnet"
  default = "10.0.2.0/24"
}

variable "private_subnet_tag_name" {
  description = "The Name property in the Tag object for the private subnet"
}

variable "internet_gateway_tag_name" {
  description = "The Name property in the Tag object for internet gateway"
}