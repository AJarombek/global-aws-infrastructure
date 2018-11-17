#!/usr/bin/env bash

# Setup Packer for machine image creation automation & Work with EFS
# Author: Andrew Jarombek
# Date: 11/4/2018

brew install packer

# Validate that the Packer image is valid
packer validate image.json

# Create a new machine image
packer build image.json

# AWS CLI for EFS
aws efs describe-file-systems help

aws efs describe-file-systems \
    --region us-east-1 \
    --creation-token jenkins-fs

# Query the file system ID
aws efs describe-file-systems \
    --region us-east-1 \
    --creation-token jenkins-fs \
    --query FileSystems[0].FileSystemId

# Execute build-ami.sh
bash build-ami.sh

# Test Instance
ssh -i "testing.pem" ubuntu@ec2-34-228-162-214.compute-1.amazonaws.com