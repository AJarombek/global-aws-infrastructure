# global-aws-infrastructure

![Maintained Label](https://img.shields.io/badge/Maintained-Yes-brightgreen?style=for-the-badge)

### Overview

This repository contains all the global infrastructure-as-code (IaC) for Andrew Jarombek.  All other IaC
repositories are referenced in separate directories and README.md files.

### Commands

**Running GitHub Action Workflows Locally**

```bash
# Run a specific GitHub Actions workflow, detecting the event type automatically
act -W '.github/workflows/aws_tests.yml' --detect-event
```

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `.github`         | GitHub Actions for CI/CD pipelines.                                         |
| `acm`             | HTTPS certificates for the `jarombek.io` applications.                      |
| `api-gateway`     | Global API Gateway configuration.                                           |
| `apps`            | Infrastructure for individual applications.                                 |
| `backend`         | The Terraform backend, consisting of an S3 bucket.                          |
| `budgets`         | Terraform scripts for setting AWS account budgets.                          |
| `cloud-trail`     | Terraform scripts for AWS account auditing with CloudTrail.                 |
| `config`          | Terraform scripts for AWS Config.                                           |
| `dockerfiles`     | Reusable dockerfiles used throughout my infrastructure.                     |
| `eks-v2`          | Terraform and Kubernetes configuration for an EKS v2 cluster.               |
| `file-vault`      | Terraform scripts for an S3 bucket that serves as a vault for secure files. |
| `lambda`          | Terraform scripts for AWS Lambda functions.                                 |
| `lambda-layers`   | AWS Lambda Layer source code and Terraform scripts.                         |
| `parameter-store` | Terraform scripts for System Manager Parameter Store secrets.               |
| `route53`         | Terraform scripts for creating DNS records for the account.                 |
| `s3`              | Terraform scripts for global S3 assets.                                     |
| `secrets-manager` | Terraform scripts for global secrets stored in Secrets Manager.             |
| `sns`             | Terraform scripts for AWS SNS notifications.                                |
| `test`            | Python AWS infrastructure test suite.                                       |
| `test-k8s`        | Go Kubernetes infrastructure test suite.                                    |

### Versions

**[v2.1.6](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.1.6) - EKS 1.29 Upgrade**

> Release Date: April 6th, 2024

+ Upgrade the EKS cluster from version 1.24 (entered extended support) to version 1.29.
  + Kubernetes Versions on EKS [Support Timeline](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)

**[v2.1.5](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.1.5) - ACM & CloudFront Updates**

> Release Date: January 28th, 2024

+ Remove `www.global.jarombek.io` subdomain ACM certificate and CloudFront distribution.

**[v2.1.4](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.1.4) - ECS Cluster**

> Release Date: January 13th, 2024

+ Added an ECS Cluster and corresponding tests.

**[v2.1.3](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.1.3) - Remove Jenkins Infrastructure**

> Release Date: December 23rd, 2023

Remove Jenkins Infrastructure code, and move it to [andy-jarombek-research](https://github.com/AJarombek/andy-jarombek-research).

**[v2.1.2](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.1.2) - Kubernetes Tests Updated**

> Release Date: June 3rd, 2023

Kubernetes tests updated to use latest dependency versions and Go 1.20

**[v2.1.1](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.1.1) - Jenkins on EKS V2**

> Release Date: June 3rd, 2023

+ Jenkins functional on the new EKS cluster.
+ Jenkins Dockerfile Updated
+ Tests & GitHub Actions Passing

**[v2.1.0](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.1.0) - EKS V2 Cluster**

> Release Date: April 3rd, 2023

Created a new EKS cluster and deprecated the old EKS module.

**[v2.0.6](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.0.6) - Terraform 1.3 Upgrade**

> Release Date: March 28th, 2023

Infrastructure upgraded to use Terraform 1.3.9.  Removed deprecated and unused Terraform modules.

**[v2.0.5](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.0.5) - AWS Config Infrastructure**

> Release Date: March 12th, 2023

Infrastructure for using AWS Config, along with corresponding Python tests.

**[v2.0.4](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.0.4) - GitHub Actions**

> Release Date: February 19th, 2023

Integrate Terraform formatting, AWS tests, and Kubernetes tests with GitHub Actions CI/CD.

**[v2.0.3](https://github.com/AJarombek/global-aws-infrastructure/tree/v2.0.3) - S3 Bucket Updates & Parameter Store**

> Release Date: December 31st, 2021

This release updated the S3 buckets in my infrastructure, making those used as static websites private.  It also 
implemented AWS Systems Manager Parameter Store infrastructure.

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