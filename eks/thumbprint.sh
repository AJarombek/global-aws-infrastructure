#!/usr/bin/env bash

# Script which returns the OIDC provider thumbprint for a region in AWS.
# Run 'chmod +x thumbprint.sh' to ensure this script is executable.
# https://github.com/terraform-providers/terraform-provider-aws/issues/10104#issuecomment-632309246
# Author: Andrew Jarombek
# Date: 9/26/2020

THUMBPRINT=$(echo | openssl s_client -connect oidc.eks.$1.amazonaws.com:443 2>&- | openssl x509 -fingerprint -noout | sed 's/://g' | awk -F= '{print tolower($2)}')
THUMBPRINT_JSON="{\"thumbprint\": \"${THUMBPRINT}\"}"
echo $THUMBPRINT_JSON