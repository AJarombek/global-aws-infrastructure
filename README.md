# global-aws-infrastructure

### Overview

This repository contains all the global infrastructure-as-code (IaC) for Andrew Jarombek.  All other IaC
repositories are referenced in separate directories and README.md files.

Here is the current infrastructure for Andrew Jarombek:

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `apps`            | Infrastructure for individual applications.                                 |
| `apps-sandabox`   | Infrastructure for prototype applications in the Sandbox VPC.               |
| `backend`         | The Terraform backend, consisting of an S3 bucket.                          |
| `root`            | Root Terraform scripts for creating the accounts VPCs.                      |
| `iam`             | Terraform scripts for creating IAM users, groups, roles, and policies.      |
| `route53`         | Terraform scripts for creating DNS records for the account.                 |
| `jenkins`         | Packer AMI & Terraform scripts for creating a Jenkins server.               |
| `jenkins-efs`     | Terraform scripts for creating an EFS for the Jenkins server.               |