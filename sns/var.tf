/**
 * Variables for AWS SNS (Simple Notification Service) resources.
 * Author: Andrew Jarombek
 * Date: 7/15/2021
 */

variable "phone_number" {
  description = "Phone number to send SMS alerts."
  type = string
  sensitive = true
}