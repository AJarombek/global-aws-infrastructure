# Varaibles for creating a VPC
# Author: Andrew Jarombek
# Date: 11/4/2018

# naming resources
variable "name" {
  description = "Name to use as a prefix for different resources"
}

variable "tag_name" {
  description = "Name to use for the Name property in the Tag objects"
}

# aws_vpc resource
variable "vpc_cidr" {
  description = "The CIDR for the Resources VPC"
  default = "10.0.0.0/16"
}

# aws_subnet resources
variable "public_subnet_cidr" {
  description = "The CIDR for the Resources VPC public subnet"
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "The CIDR for the Resources VPC private subnet"
  default = "10.0.2.0/24"
}

# aws_route_table resources
variable "routing_table_cidr" {
  description = "The CIDR block for incoming traffic to the public subnet"
  default = "0.0.0.0/0"
}