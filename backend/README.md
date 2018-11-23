### Overview

This directory contains the initial Terraform & Bash scripts for creating the Terraform S3 backend.

### Files

| Filename            | Description                                                                                                      |
|---------------------|------------------------------------------------------------------------------------------------------------------|
| `main.tf`           | The initial Terraform script for configuring the S3 backend for all other Terraform scripts                      |
| `setup.sh`          | The bash commands needed to create the S3 backend locally                                                        |
| `terraform.tfstate` | The terraform state for the backend.  All other terraform state files will be saved to the backend automatically |