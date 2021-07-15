/**
 * Variables for a DockerHub key stored in AWS Secrets Manager.  This is used for pushing and pulling docker images.
 * Author: Andrew Jarombek
 * Date: 6/25/2020
 */

variable "dockerhub_secret" {
  description = "Secrets for my DockerHub account to place in AWS Secret Manager.  Never use the default value beyond POC"
  default = {
    private_key = "private_key"
  }

  type = map
  sensitive = true
}