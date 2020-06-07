/**
 * Variables for a GitHub key stored in AWS Secrets Manager.  This is used for cloning and pushing commits to
 * repositories.
 * Author: Andrew Jarombek
 * Date: 6/6/2020
 */

variable "github_secret" {
  description = "Secrets for my Google Account to place in AWS Secret Manager.  Never use the default value beyond POC"
  default = {
    private_key = "private_key"
  }

  type = map
}