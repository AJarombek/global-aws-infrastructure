#!/usr/bin/env bash

# Build and push a Docker image to ECR.
# Author: Andrew Jarombek
# Date: 6/10/2020

IMAGE_TAG=$1

python3.8 -m venv env
source ./env/bin/activate
python3.8 -m pip install -r requirements.txt

python3.8 push-image.py ${IMAGE_TAG} push

deactivate