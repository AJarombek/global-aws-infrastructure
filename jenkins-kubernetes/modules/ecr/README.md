### Overview

Module for creating an ECR repository which holds Docker images for a Jenkins server.

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Terraform configuration for an ECR repository.                                               |
| `repo-policy.json`  | ECR repository policy for the images.                                                        |
| `var.tf`            | Variables for the Terraform configuration.                                                   |

### References

1. [ECR Lifecycle Policies](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html)