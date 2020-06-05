/**
 * Variables for the ALB needed for ECS
 * Author: Andrew Jarombek
 * Date: 6/4/2020
 */

variable "prod" {
  description = "If the environment for the ALB is production"
  default = false
}

variable "load-balancer-sg-rules-cidr" {
  description = "A list of security group rules for the load balancer (using CIDR blocks)"
  type = list
  default = []
}

variable "load-balancer-sg-rules-source" {
  description = "A list of security group rules for the load balancer (using source Security Groups)"
  type = list
  default = []
}