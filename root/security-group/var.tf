/**
 * Varaibles for creating a Security Group
 * Author: Andrew Jarombek
 * Date: 2/11/2019
 */

# Needed since terraform modules do not support the 'count' property
variable "enabled" {
  description = "Whether or not the security group should be created"
  default = true
}

#-----------------
# Naming Variables
#-----------------

variable "name" {
  description = "Name to use as a prefix for different resources"
}

variable "tag_name" {
  description = "Name to use for the Name property in the Tag objects"
}

#-----------------------------
# aws_security_group Variables
#-----------------------------

variable "vpc_id" {
  description = "VPC identifier for the security group"
}

variable "description" {
  description = "Information about the security group"
  type = "string"
  default = "Security Group"
}

variable "sg_rules" {
  description = "A list of security group rules"
  type = "list"
  default = []
}