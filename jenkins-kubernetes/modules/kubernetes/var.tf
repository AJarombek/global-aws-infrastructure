/**
 * Variables for the Kubernetes infrastructure
 * Author: Andrew Jarombek
 * Date: 6/15/2020
 */

variable "prod" {
  description = "If the environment for the Kubernetes infrastructure is production"
  default = false
}