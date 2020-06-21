#!/usr/bin/env bash

# Push a docker image to ECR.  This script is used for the Jenkins server image.
# Author: Andrew Jarombek
# Date: 6/8/2020

ACCOUNT_ID=$1
IMAGE_TAG=$2

aws ecr get-login-password --region us-east-1 \
    | docker login -u AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
sudo docker push ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/jenkins-jarombek-io:${IMAGE_TAG}