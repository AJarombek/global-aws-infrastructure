### Overview

Infrastructure for creating an ECS cluster for a Jenkins server.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `docker`          | Docker image creation for the Jenkins cluster.                              |
| `env`             | Environments for Jenkins server infrastructure.                             |
| `modules`         | Modules that make up the ECS Jenkins server infrastructure.                 |

### Resources

1. [Docker in Docker](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)
2. [ECS Docker Socket](https://stackoverflow.com/questions/42220959/can-an-ecs-container-have-access-to-the-docker-socket)