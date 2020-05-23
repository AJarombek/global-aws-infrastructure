/**
 * Variables for Google Account credentials stored in AWS Secrets Manager.  This is used for sending emails.
 * Author: Andrew Jarombek
 * Date: 5/23/2020
 */

variable "google_account_secrets" {
  description = "Secrets for my Google Account to place in AWS Secret Manager.  Never use the default value beyond POC"
  default = {
    password = "password"
  }

  type = map
}