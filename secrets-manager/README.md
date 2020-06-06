### Overview

Modules for global secrets stored in AWS Secrets Manager.  These secrets allow for automated processes 
(ex: Jenkins, Bazel) to run later on.  Therefore, these secrets must be manually created and pushed using 
Terraform locally.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `github`          | GitHub key stored in Secrets Manager.                                       |
| `google-account`  | Google account credentials stored in Secrets Manager.                       |