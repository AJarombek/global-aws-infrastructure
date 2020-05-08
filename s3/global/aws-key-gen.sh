#!/usr/bin/env bash

# Generate a key to connect to an ec2 instance.  This script must
# execute BEFORE the instance(s) are created with IaC.
#
# NOTE: When executed with Terraform, make sure the script has super user privileges.
# Run the command `sudo -s` beforehand.
#
# Author: Andrew Jarombek
# Date: 2/17/2019

# The key to generate is determined by a command line argument.  First validate the argument...
[[ -z "$1" ]] && ( echo "Argument 1 (Required): 'Key Name' not specified." && exit 1 )

# ... then collect it
KEY_NAME=$1

IFS=

# First delete any exiting key pair with the provided name
aws ec2 delete-key-pair --key-name ${KEY_NAME}

# Next create a new keypair.  Query the results back from AWS to get the private key
Key="$(aws ec2 create-key-pair --key-name ${KEY_NAME} --query "KeyMaterial" --output text)"

# In case needed, display the private key
echo ${Key}

# Place the private key in a file called {KEY_NAME}.pem
echo ${Key} > ~/${KEY_NAME}.pem

# Its required to change the private key permissions
chmod 400 ~/${KEY_NAME}.pem

# Add the key to the SSH agent
ssh-add ~/${KEY_NAME}.pem