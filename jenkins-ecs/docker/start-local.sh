#!/usr/bin/env bash

# Build and start the Jenkins server locally with Docker.
# Author: Andrew Jarombek
# Date: 6/10/2020

IMAGE_TAG=$1

python3.8 -m venv env
source ./env/bin/activate
python3.8 -m pip install -r requirements.txt

python3.8 push-image.py ${IMAGE_TAG}

deactivate

docker container stop jenkins-jarombek-io
docker container rm jenkins-jarombek-io

docker container run --name jenkins-jarombek-io -p 8080:8080 -p 50000:50000 \
    -v /var/run/docker.sock:/var/run/docker.sock jenkins-jarombek-io:latest