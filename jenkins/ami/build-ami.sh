#!/usr/bin/env bash

# Execute this file to build the Jenkins AMI
# Author: Andrew Jarombek
# Date: 11/17/2018

# Save the file system ID to an environment variable
EFS_ID="$(aws efs describe-file-systems \
    --region us-east-1 \
    --creation-token jenkins-fs \
    --query FileSystems[0].FileSystemId)"

if [ ${EFS_ID} = "null" ]
then
    echo "No EFS exists with creation-token 'jenkins-fs'"
    exit 1
else
    echo "Baking AMI with EFS: ${EFS_ID}"
fi

# Validate that the Packer image is valid
echo "Validating AMI Template"
packer validate jenkins-image.json

# Create a new machine image
echo "Building AMI"
packer build jenkins-image.json