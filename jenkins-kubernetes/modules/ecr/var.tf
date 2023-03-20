/**
 * Variables for the Kubernetes ACM infrastructure
 * Author: Andrew Jarombek
 * Date: 3/19/2023
 */

variable "terraform_tag" {
  description = "Name of the terraform backend key used to store the infrastructure state"
  type        = string
}