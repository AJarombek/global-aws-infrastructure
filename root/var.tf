/**
 * Variables for my clouds Top-Level AWS Infrastructure
 * Author: Andrew Jarombek
 * Date: 11/4/2018
 */

# Variables for Resources VPC
variable "resources_vpc_cidr" {
  description = "The CIDR for the Resources VPC"
  default     = "10.0.0.0/16"
}

variable "resources_public_subnet_cidr" {
  description = "The CIDR for the Resources VPC public subnet"
  default     = "10.0.1.0/24"
}

variable "resources_private_subnet_cidr" {
  description = "The CIDR for the Resources VPC private subnet"
  default     = "10.0.2.0/24"
}

# Variables for Sandbox VPC
variable "sandbox_vpc_cidr" {
  description = "The CIDR for the Sandbox VPC"
  default     = "10.0.0.0/16"
}

variable "sandbox_public_subnet_cidr" {
  description = "The CIDR for the Sandbox VPC public subnet"
  default     = "10.0.1.0/24"
}

variable "sandbox_private_subnet_cidr" {
  description = "The CIDR for the Sandbox VPC private subnet"
  default     = "10.0.2.0/24"
}

