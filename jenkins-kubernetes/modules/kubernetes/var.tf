/**
 * Variables for the Kubernetes infrastructure
 * Author: Andrew Jarombek
 * Date: 6/15/2020
 */

variable "prod" {
  description = "If the environment for the Kubernetes infrastructure is production"
  default     = false
  type        = bool
}

variable "jenkins_access_cidr" {
  description = "CIDR block that has access to the Jenkins server"
  default     = "0.0.0.0/0"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.jenkins_access_cidr))
    error_message = "An invalid CIDR block was provided for Jenkins access."
  }
}

variable "terraform_tag" {
  description = "Name of the terraform backend key used to store the infrastructure state"
  type        = string
}