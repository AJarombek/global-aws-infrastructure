### Overview

Terraform modules to create Kubernetes infrastructure for a Jenkins server.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `acm`             | Module for creating ACM certificates for the server domain.                 |
| `ecr`             | ECR repository for the Jenkins server's Docker image.                       |
| `kubernetes`      | Kubernetes infrastructure for the Jenkins server hosted on EKS.             |