#!/usr/bin/env bash

# Create a docker image.  This script is used for the Jenkins server image.
# Author: Andrew Jarombek
# Date: 6/6/2020

ACCOUNT_ID=$1
IMAGE_TAG=$2

sudo docker image build -t jenkins-jarombek-io:latest --network=host .
sudo docker image tag jenkins-jarombek-io:latest \
    ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/jenkins-jarombek-io:${IMAGE_TAG}