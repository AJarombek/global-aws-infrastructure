/**
 * Variables for a SaintsXCTF password stored in AWS Secrets Manager.  Used in application tests.
 * Author: Andrew Jarombek
 * Date: 9/13/2020
 */

variable "saints_xctf_password" {
  description = "SaintsXCTF password to place in AWS Secret Manager.  Never use the default value beyond POC."
  default = {
    password = "password"
  }

  type = map
}