### Overview

Modules for global secrets stored in AWS Secrets Manager.  These secrets allow for automated processes 
(ex: Jenkins, Bazel) to run later on.  Therefore, these secrets must be manually created and pushed using 
Terraform locally.

### Directories

| Directory Name        | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| `aws-access`          | AWS access secrets stored in Secrets Manager.                               |
| `dockerhub`           | DockerHub credentials stored in Secrets Manager.                            |
| `github`              | GitHub SSH key stored in Secrets Manager.                                   |
| `github-access-token` | GitHub account access token stored in Secrets Manager.                      |
| `google-account`      | Google account credentials stored in Secrets Manager.                       |
| `jenkins`             | Jenkins password stored in Secrets Manager.                                 |
| `saints-xctf-andy`    | SaintsXCTF password for the *andy* user.                                    |