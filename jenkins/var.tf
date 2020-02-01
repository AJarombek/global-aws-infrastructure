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

# Weekdays: 6:30PM - 8:00PM EST
variable "online_cron_weekday" {
  description = "The cron syntax for when the Jenkins server should go online on a weekday"
  default = "30 23 * * 1-5"
}

variable "offline_cron_weekday" {
  description = "The cron syntax for when the Jenkins server should go offline on a weekday"
  default = "0 1 * * 2-6"
}

# Weekends: 12:00PM - 8:00PM EST
variable "online_cron_weekend" {
  description = "The cron syntax for when the Jenkins server should go online on a weekend"
  default = "0 17 * * 0,6"
}

variable "offline_cron_weekend" {
  description = "The cron syntax for when the Jenkins server should go offline on a weekend"
  default = "0 1 * * 0,1"
}

variable "instance_port" {
  description = "The port on the EC2 instances to receive requests from the load balancer"
  default = 8080
}