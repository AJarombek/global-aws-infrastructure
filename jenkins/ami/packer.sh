#!/usr/bin/env bash

# Setup Packer for machine image creation automation
# Author: Andrew Jarombek
# Date: 11/4/2018

brew install packer

# Validate that the Packer image is valid
packer validate image.json

# Create a new machine image
packer build image.json