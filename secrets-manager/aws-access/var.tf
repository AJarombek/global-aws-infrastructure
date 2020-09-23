/**
 * Variables for AWS access secrets stored in AWS Secrets Manager.  This is used for interacting with the
 * AWS CLI and SDKs.
 * Author: Andrew Jarombek
 * Date: 9/22/2020
 */

variable "aws_access_secret" {
  description = "Secrets for AWS access to place in AWS Secret Manager.  Never use the default value beyond POC"
  default = {
    aws_access_key_id = "aws_access_key_id"
    aws_secret_access_key = "aws_secret_access_key"
  }

  type = map
}