/**
 * Variables for AWS access secrets stored in AWS System Manager Parameter Store.
 * Author: Andrew Jarombek
 * Date: 4/20/2022
 */

variable "secret" {
  description = "Secret to store in System Manager Parameter Store"
  default     = ""
  type        = string
  sensitive   = true
}