### Overview

Terraform/Docker configuration for creating Kubernetes infrastructure for a Jenkins server.

### Setup Steps

- Build the `init` job, approve the Job DSL scripts.
- Edit the `eks-kubeconfig` file secret to use the EKS cluster `kubeconfig` file.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `docker`          | Docker image creation for the Jenkins server.                               |
| `env`             | Environments for Jenkins server infrastructure.                             |
| `modules`         | Modules that make up the Kubernetes Jenkins server infrastructure.          |

### Resources

1) [Docker in Docker](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)
2) [ECS Docker Socket](https://stackoverflow.com/questions/42220959/can-an-ecs-container-have-access-to-the-docker-socket)
3) [Docker Outside of Docker](https://blog.container-solutions.com/running-docker-in-jenkins-in-docker)