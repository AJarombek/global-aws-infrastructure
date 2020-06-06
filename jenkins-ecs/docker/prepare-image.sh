#!/usr/bin/env bash

# Create a docker image and push it to ECR.  This script is used for the Jenkins server image.
# Author: Andrew Jarombek
# Date: 6/6/2020

ACCOUNT_ID=$1

docker image build -t jenkins-jarombek-io:latest .
docker image tag jenkins-jarombek-io:latest ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/jenkins-jarombek-io:1.0.0