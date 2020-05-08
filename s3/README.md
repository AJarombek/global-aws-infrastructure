### Overview

This directory contains all the infrastructure for my global S3 buckets.

### Files

| Filename            | Description                                                                             |
|---------------------|-----------------------------------------------------------------------------------------|
| `global`            | Contents of the global S3 buckets                                                       |
| `main.tf`           | The main Terraform module containing all the infrastructure for my global S3 buckets    |

### Past Issues

- If the following error occurs while creating the SSH key: `dyld: Library not loaded: @executable_path/../.Python`, 
    simply update the AWS CLI: 
    
```bash
brew upgrade awscli
```

### Resources

1) [Fix AWS CLI Python Issue](https://stackoverflow.com/a/51136525)