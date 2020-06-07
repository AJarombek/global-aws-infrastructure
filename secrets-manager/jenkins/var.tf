/**
 * Variables for a Jenkins server password stored in AWS Secrets Manager.  Used on jenkins.jarombek.io.
 * Author: Andrew Jarombek
 * Date: 6/6/2020
 */

variable "jenkins_secret" {
  description = "Jenkins server password to place in AWS Secret Manager.  Never use the default value beyond POC."
  default = {
    password = "andy"
  }

  type = map
}