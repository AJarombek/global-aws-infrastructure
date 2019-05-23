/**
 * Variables for configuring the Jenkins server
 * Author: Andrew Jarombek
 * Date: 11/11/2018
 */

variable "max_size_on" {
  description = "Max number of instances in the auto scaling group during an online period"
  default = 1
}

variable "min_size_on" {
  description = "Min number of instances in the auto scaling group during an online period"
  default = 1
}

variable "max_size_off" {
  description = "Max number of instances in the auto scaling group during an offline period"
  default = 0
}

variable "min_size_off" {
  description = "Min number of instances in the auto scaling group during an offline period"
  default = 0
}

variable "desired_capacity_on" {
  description = "The desired number of intances in the autoscaling group when I am working"
  default = 1
}

variable "desired_capacity_off" {
  description = "The desired number of intances in the autoscaling group when I am NOT working"
  default = 0
}

variable "online_cron_morning" {
  description = "The cron syntax for when the Jenkins server should go online in the morning"
  default = "0 11 * * *"
}

variable "offline_cron_morning" {
  description = "The cron syntax for when the Jenkins server should go offline in the morning"
  default = "0 12 * * *"
}

variable "online_cron_evening" {
  description = "The cron syntax for when the Jenkins server should go online in the evening"
  default = "0 22 * * *"
}

variable "offline_cron_evening" {
  description = "The cron syntax for when the Jenkins server should go offline in the evening"
  default = "0 23 * * *"
}

variable "instance_port" {
  description = "The port on the EC2 instances to receive requests from the load balancer"
  default = 8080
}