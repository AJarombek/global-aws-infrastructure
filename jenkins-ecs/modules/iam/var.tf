/**
 * Variables for IAM roles and policies used by the jenkins.jarombek.io application.
 * Author: Andrew Jarombek
 * Date: 6/5/2020
 */

variable "prod" {
  description = "If the environment for the IAM roles and policies is production"
  default = false
}