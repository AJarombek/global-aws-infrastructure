#!/usr/bin/env bash

# Author: Andrew Jarombek
# Date: 11/4/2018

# Make sure Ubuntu has enough time to initialize (https://www.packer.io/intro/getting-started/provision.html)
sleep 30

apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get -y install ansible