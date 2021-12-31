### Overview

Modules for secrets stored in AWS Systems Manager Parameter Store.  The `config` directory contains a Terraform module 
for setting up a AWS KMS key to encrypt secrets in Parameter Store.  The `secrets` directory contains modules for 
individual secrets.

### Directories

| Directory Name    | Description                                                                        |
|-------------------|------------------------------------------------------------------------------------|
| `config`          | Terraform module for an AWS KMS key used in AWS Systems Manager Parameter Store.   |
| `secrets`         | Terraform modules for secrets stored in AWS Systems Manager Parameter Store.       |