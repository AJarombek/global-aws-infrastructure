### Overview

Dockerfiles for images used throughout my infrastructure, applications, and CI/CD.

### Commands

**Build the Dockerfiles locally**

```bash
# pipenv-flask Dockerfile
docker container stop pipenv-flask
docker container rm pipenv-flask
docker image build -t pipenv-flask:latest -f pipenv-flask.dockerfile .
docker container run -d --name pipenv-flask pipenv-flask:latest

# mysql-aws Dockerfile
docker container stop mysql-aws
docker container rm mysql-aws
docker image build -t mysql-aws:latest -f mysql-aws.dockerfile .
docker container run -d --name mysql-aws mysql-aws:latest

# Connect to the container and check the software installed
docker container exec -it mysql-aws bash
mysql --version
aws --version
```

### Files

| Filename                              | Description                                                                  |
|---------------------------------------|------------------------------------------------------------------------------|
| `mysql:5.7.sh`                        | Bash commands for working with the official MySQL 5.7 Docker image.          |
| `mysql-aws.dockerfile`                | Dockerfile for an image that contains the AWS CLI and MySQL client.          |
| `pipenv-flask.dockerfile`             | Dockerfile for an image that installs `pipenv` and exposes a port for flask. |