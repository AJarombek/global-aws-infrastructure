/**
 * Variables for the ECS cluster
 * Author: Andrew Jarombek
 * Date: 6/4/2020
 */

variable "dependencies" {
  description = "Resources that this module is dependent on"
  type = list
}

variable "prod" {
  description = "If the environment for the ECS cluster is production"
  default = false
}

variable "jenkins-jarombek-io-desired-count" {
  description = "The desired number of jenkins-jarombek-io task instances to run in the ECS cluster"
  default = 1
}

variable "alb-security-group" {
  description = "Security group for the ALB used by the ECS cluster"
}

variable "jenkins-jarombek-io-lb-target-group" {
  description = "Target Group for the jenkins-jarombek-io Load Balancer"
}