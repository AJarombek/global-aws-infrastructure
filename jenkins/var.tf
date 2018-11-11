/**
 * Variables for configuring the Jenkins server
 * Author: Andrew Jarombek
 * Date: 11/11/2018
 */

variable "max_size" {
  description = "Max number of instances in the auto scaling group"
  default = 2
}

variable "min_size" {
  description = "Min number of instances in the auto scaling group"
  default = 1
}

variable "instance_port" {
  description = "The port on the EC2 instances to receive requests from the load balancer"
  default = 8080
}