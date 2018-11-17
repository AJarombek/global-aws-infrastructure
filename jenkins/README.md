### Overview

The infrastructure defined in this directory relates to the Jenkins server running in the resources VPC.

### Files

| Filename          | Description                                                                       |
|-------------------|-----------------------------------------------------------------------------------|
| ami               | Contains code to generate an AMI for the Jenkins server using Packer and Ansible  |
| main.tf           | Main Terraform module code for creating a Jenkins server                          |
| var.tf            | Variables for main.tf                                                             |
| jenkins-setup.sh  | A script that runs as soon as the EC2 instance for the Jenkins server boots up    |