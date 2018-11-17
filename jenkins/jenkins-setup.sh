#!/usr/bin/env bash

# Startup config for a Jenkins server
# Author: Andrew Jarombek
# Date: 11/11/2018

echo "START jenkins-setup.sh"

# Adding lines to the beginning of a file: https://bit.ly/2KgsYsp
printf 'JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/ \nPATH=$JAVA_HOME:$PATH' | \
    cat - /etc/default/jenkins > /home/ubuntu/temp && \
    sudo mv /home/ubuntu/temp /etc/default/jenkins

# https://stackoverflow.com/a/46249486 & https://stackoverflow.com/a/525612
sudo sed -i -e 's/https/http/g' /var/lib/jenkins/hudson.model.UpdateCenter.xml

curl google.com

cd /
sudo /etc/init.d/jenkins start

# Initial Admin Password for Jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "END jenkins-setup.sh"