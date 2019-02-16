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

variable "online_cron_weekday_morning" {
  description = "The cron syntax for when the Jenkins server should be online weekday mornings"
  default = "30 11 * * 1-5"
}

variable "offline_cron_weekday_morning" {
  description = "The cron syntax for when the Jenkins server should be offline weekday mornings"
  default = "30 13 * * 1-5"
}

variable "online_cron_weekday_afternoon" {
  description = "The cron syntax for when the Jenkins server should be online weekday afternoons"
  default = "0 22 * * 1-5"
}

variable "offline_cron_weekday_afternoon" {
  description = "The cron syntax for when the Jenkins server should be offline weekday afternoons"
  default = "30 3 * * 2-6"
}

variable "online_cron_weekend" {
  description = "The cron syntax for when the Jenkins server should be online during the weekend"
  default = "30 11 * * 0,6"
}

variable "offline_cron_weekend" {
  description = "The cron syntax for when the Jenkins server should be offline during the weekend"
  default = "30 3 * * 0,1"
}

variable "instance_port" {
  description = "The port on the EC2 instances to receive requests from the load balancer"
  default = 8080
}