/**
 * Variables for a GitHub account access token in AWS Secrets Manager.  This is for used accessing the GitHub API for
 * my account.
 * Author: Andrew Jarombek
 * Date: 6/27/2020
 */

variable "github_access_token" {
  description = "Access token for my GitHub account to place in AWS Secret Manager.  Never use the default value beyond POC"
  default = {
    access_token = "access_token"
  }

  type      = map(any)
  sensitive = true
}