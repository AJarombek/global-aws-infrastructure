### Overview

Docker container for a Jenkins server.

### Commands

**Push the Jenkins Docker image to ECR**

```bash
./push-ecr.sh 1.0.0
```

**Build and start the Jenkins container locally**

```bash
./start-local.sh 1.0.0
```

### Files

| Filename                | Description                                                                                  |
|-------------------------|----------------------------------------------------------------------------------------------|
| `Dockerfile`            | Dockerfile for the Jenkins server.                                                           |
| `jenkins-template.yaml` | Jenkins Configuration as Code file.                                                          |
| `plugins.txt`           | List of plugins and corresponding versions to install.                                       |
| `prepare-image.sh`      | Prepare an image with appropriate credentials and secrets.                                   |
| `push-ecr.sh`           | Push an image to an ECR repository on AWS.                                                   |
| `push-image.py`         | Helper Python script to push an image to ECR.                                                |
| `push-image.sh`         | Helper Bash script to push an image to ECR.                                                  |
| `requirements.txt`      | Dependencies of the Python script.                                                           |
| `start-local.sh`        | Build and start the Jenkins Docker container locally.                                        |

### Resources

1) [Search Jenkins Plugins](https://plugins.jenkins.io/)
2) [Jenkins Matrix Based Security](https://wiki.jenkins.io/display/JENKINS/Matrix-based+security)