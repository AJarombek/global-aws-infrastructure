# global-aws-infrastructure

![Maintained Label](https://img.shields.io/badge/Maintained-Yes-brightgreen?style=for-the-badge)

### Overview

This repository contains all the global infrastructure-as-code (IaC) for Andrew Jarombek.  All other IaC
repositories are referenced in separate directories and README.md files.

### Integration

There are multiple Jenkins jobs for this infrastructure.  They are all located in the 
[`global-aws`](http://jenkins.jarombek.io/job/global-aws/) folder:

[![Jenkins](https://img.shields.io/badge/Jenkins-%20global--aws--infrastructure--test--prod-blue?style=for-the-badge)](http://jenkins.jarombek.io/job/global-aws/job/global-aws-infrastructure-test-prod/)
> Runs tests on the production environment AWS infrastructure created with Terraform.

[![Jenkins](https://img.shields.io/badge/Jenkins-%20global--aws--infrastructure--test--dev-blue?style=for-the-badge)](http://jenkins.jarombek.io/job/global-aws/job/global-aws-infrastructure-test-dev/)
> Runs tests on the development environment AWS infrastructure created with Terraform.

[![Jenkins](https://img.shields.io/badge/Jenkins-%20global--kubernetes--infrastructure--test-blue?style=for-the-badge)](http://jenkins.jarombek.io/job/global-aws/job/global-kubernetes-infrastructure-test/)
> Runs tests on the Kubernetes (EKS) infrastructure created with Terraform.

[![Jenkins](https://img.shields.io/badge/Jenkins-%20cost--detection-blue?style=for-the-badge)](http://jenkins.jarombek.io/job/global-aws/job/cost-detection/)
> AWS infrastructure in the previous three days.

### Directories

| Directory Name       | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `acm`                | HTTPS certificates for the `jarombek.io` applications.                      |
| `api-gateway`        | Global API Gateway configuration.                                           |
| `apps`               | Infrastructure for individual applications.                                 |
| `backend`            | The Terraform backend, consisting of an S3 bucket.                          |
| `budgets`            | Terraform scripts for setting AWS account budgets.                          |
| `cloud-trail`        | Terraform scripts for AWS account auditing with CloudTrail.                 |
| `dockerfiles`        | Reusable dockerfiles used throughout my infrastructure.                     |
| `eks`                | Terraform and Kubernetes configuration for an EKS cluster.                  |
| `file-vault`         | Terraform scripts for an S3 bucket that serves as a vault for secure files. |
| `iam`                | Terraform scripts for creating IAM users, groups, roles, and policies.      |
| `jenkins`            | *DEPRECATED* - Packer AMI & Terraform scripts for creating a Jenkins server.|
| `jenkins-kubernetes` | Terraform scripts and Dockerfile for a Jenkins server hosted on EKS.        |
| `jenkins-efs`        | *DEPRECATED* - Terraform scripts for creating an EFS for the Jenkins server.|
| `lambda`             | Terraform scripts for AWS Lambda functions.                                 |
| `lambda-layers`      | AWS Lambda Layer source code and Terraform scripts.                         |
| `root`               | Root Terraform scripts for creating the accounts VPCs.                      |
| `route53`            | Terraform scripts for creating DNS records for the account.                 |
| `s3`                 | Terraform scripts for global S3 assets.                                     |
| `secrets-manager`    | Terraform scripts for global secrets stored in Secrets Manager.             |
| `sns`                | Terraform scripts for AWS SNS notifications.                                |
| `vpc-peering`        | Terraform scripts for VPC peering connections between my VPCs.              |
| `test`               | Python AWS infrastructure test suite.                                       |
| `test-k8s`           | Go Kubernetes infrastructure test suite.                                    |

### Versions

**[v2.0.2](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.0.2) - VPC and Subnet Changes**

> Release Date: November 24th, 2021

Removed the (no longer used) `jarombek-com-vpc` VPC and added private subnets to the `application-vpc` VPC.

**[v2.0.1](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.0.1) - Lambda Functions & SNS Release**

> Release Date: July 18th, 2021

Added lambda functions and altered SNS topics and subscriptions.

**[v2.0.0](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.0.0) - Second Release**

> Release Date: February 12th, 2021

Tagging the repository with all the changes made after 2+ years of experience working with AWS.  The changes since 
version 1 include but are not limited to:

* EKS Cluster
* Kubernetes Jenkins Server
* Secrets in Secrets Manager
* Lambda Layers
* Reusable Dockerfiles
* Route53 Health Checks
* Budget Alarms
* SNS Topics

**[v1.0.0](https://github.com/AJarombek/global-aws-infrastructure/tree/v1.0.0) - MVP Release**

> Release Date: May 13th, 2019

This update marks the official release of my global Infrastructure with a full Python unit test suite.

* Jenkins Server
* DNS Records
* VPCs and Subnets
* Terraform Backend
* Global S3 Bucket
* Python Unit Tests