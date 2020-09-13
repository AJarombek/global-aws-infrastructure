# global-aws-infrastructure

### Overview

This repository contains all the global infrastructure-as-code (IaC) for Andrew Jarombek.  All other IaC
repositories are referenced in separate directories and README.md files.

### CI/CD

There are multiple Jenkins job for this infrastructure.  They are all located in the 
[`global-aws`](http://jenkins.jarombek.io/job/global-aws/) folder:

- [`global-aws-infrastructure-test-prod`](http://jenkins.jarombek.io/job/global-aws/job/global-aws-infrastructure-test-prod/) 
Runs tests on the production environment AWS infrastructure created with Terraform.
- [`global-aws-infrastructure-test-dev`](http://jenkins.jarombek.io/job/global-aws/job/global-aws-infrastructure-test-dev/) 
Runs tests on the development environment AWS infrastructure created with Terraform.
- [`global-kubernetes-infrastructure-test`](http://jenkins.jarombek.io/job/global-aws/job/global-kubernetes-infrastructure-test/) 
Runs tests on the Kubernetes (EKS) infrastructure created with Terraform.
- [`cost-detection`](http://jenkins.jarombek.io/job/global-aws/job/cost-detection/) Detects the rolling average cost for 
AWS infrastructure in the previous three days.

### Infrastructure Diagram

![AWS Model](aws-model.png)

*Last Updated: Feb 10th, 2019*

### Directories

| Directory Name       | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `acm`                | HTTPS certificates for the `jarombek.io` applications.                      |
| `api-gateway`        | Global API Gateway configuration.                                           |
| `apps`               | Infrastructure for individual applications.                                 |
| `backend`            | The Terraform backend, consisting of an S3 bucket.                          |
| `eks`                | Terraform and Kubernetes configuration for an EKS cluster.                  |
| `iam`                | Terraform scripts for creating IAM users, groups, roles, and policies.      |
| `jenkins`            | *DEPRECATED* - Packer AMI & Terraform scripts for creating a Jenkins server.|
| `jenkins-kubernetes` | Terraform scripts and Dockerfile for a Jenkins server hosted on EKS.        |
| `jenkins-efs`        | *DEPRECATED* - Terraform scripts for creating an EFS for the Jenkins server.|
| `root`               | Root Terraform scripts for creating the accounts VPCs.                      |
| `route53`            | Terraform scripts for creating DNS records for the account.                 |
| `s3`                 | Terraform scripts for global S3 assets.                                     |
| `secrets-manager`    | Terraform scripts for global secrets stored in Secrets Manager.             |
| `test`               | Python AWS infrastructure test suite.                                       |
| `test-k8s`           | Go Kubernetes infrastructure test suite.                                    |

### Version History

**[V.1.0.0](https://github.com/AJarombek/global-aws-infrastructure/tree/v1.0.0) - MVP Release**

> Release Date: May 13th, 2019

This update marks the official release of my global Infrastructure with a full Python unit test suite.

* Jenkins Server
* DNS Records
* VPCs and Subnets
* Terraform Backend
* Global S3 Bucket
* Python Unit Tests