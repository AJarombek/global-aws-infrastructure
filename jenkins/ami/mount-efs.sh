#!/usr/bin/env bash

# Script that mounts EFS onto the instance
# Author: Andrew Jarombek
# Date: 11/17/2018

echo "START mount-efs.sh"

MOUNT_LOCATION="/mnt/efs/JENKINS_HOME"
MOUNT_TARGET="{{ user `efs_id` }}.efs.us-east-1.amazonaws.com"

echo "Mount Location: ${MOUNT_LOCATION}"
echo "Mount Target: ${MOUNT_TARGET}"

# Make a directory to mount EFS
sudo mkdir -p ${MOUNT_LOCATION}

# Mount EFS
sudo mount \
    -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
    ${MOUNT_TARGET}:/ ${MOUNT_LOCATION}

# Make Jenkins the owner of the EFS directory
sudo chown jenkins:jenkins ${MOUNT_LOCATION}

# Change the location of JENKINS_HOME in the config file /etc/default/jenkins
# Command says 'globally substitute JENKINS_HOME=/var/lib/$NAME with JENKINS_HOME=${MOUNT_LOCATION}'
sudo sed -i -e "s#JENKINS_HOME=/var/lib/\$NAME#JENKINS_HOME=${MOUNT_LOCATION}#g" /etc/default/jenkins

echo "${MOUNT_TARGET}:/ ${MOUNT_LOCATION} nfsdefaults,vers=4.1 0 0" >> /etc/fstab

echo "END mount-efs.sh"