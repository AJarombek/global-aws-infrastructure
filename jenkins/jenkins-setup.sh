#!/usr/bin/env bash

# Startup config for a Jenkins server
# Author: Andrew Jarombek
# Date: 11/11/2018

echo "Running jenkins-setup.sh"

# Adding lines to the beginning of a file: https://bit.ly/2KgsYsp
printf 'JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/ \nPATH=$JAVA_HOME:$PATH' | \
    cat - /etc/default/jenkins > /home/ubuntu/temp && \
    sudo mv /home/ubuntu/temp /etc/default/jenkins

cd /
sudo /etc/init.d/jenkins start

# Initial Admin Password for Jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword