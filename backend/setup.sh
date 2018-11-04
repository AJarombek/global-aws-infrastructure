#!/usr/bin/env bash

# Author: Andrew Jarombek
# Date: 11/3/2018

cd backend
terraform init
terraform plan

# To start out I need to use access keys - this isn't the most secure approach
export AWS_ACCESS_KEY_ID=XXX
export AWS_SECRET_ACCESS_KEY=XXX

terraform apply