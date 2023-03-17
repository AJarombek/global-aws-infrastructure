/**
 * Variables for AWS access secrets stored in AWS System Manager Parameter Store.
 * Author: Andrew Jarombek
 * Date: 3/17/2023
 */

variable "secret" {
  description = "Secret to store in System Manager Parameter Store"
  default     = ""
  type        = string
  sensitive   = true
}