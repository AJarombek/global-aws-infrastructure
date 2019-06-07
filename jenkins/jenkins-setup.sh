#!/usr/bin/env bash

# Startup config for a Jenkins server
# Author: Andrew Jarombek
# Date: 11/11/2018

echo "START jenkins-setup.sh"

# Associate an Elastic IP with this virtual machine
# The URL http://169.254.169.254 contains metadata about instances
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
aws --region ${REGION} ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${ALLOCATION_ID}

echo "Mount Location: ${MOUNT_LOCATION}"
echo "Mount Target: ${MOUNT_TARGET}"

# Make a directory to mount EFS
sudo mkdir -p ${MOUNT_LOCATION}

# Mount EFS
sudo mount \
    -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
    ${MOUNT_TARGET}:/ ${MOUNT_LOCATION}

# Make Jenkins the owner of the EFS directory
sudo chown jenkins:jenkins ${MOUNT_LOCATION}

# If EFS does not have jenkins mounted, reinstall Jenkins.
if [ ! -e /var/lib/jenkins/jobs ]
then
    echo "Initial EFS Deployment... Reinstalling Jenkins"
    sudo apt-get --assume-yes install --reinstall jenkins
fi

sudo echo "${MOUNT_TARGET}:/ ${MOUNT_LOCATION} nfsdefaults,vers=4.1 0 0" >> /etc/fstab

# Adding lines to the beginning of a file: https://bit.ly/2KgsYsp
printf 'JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/ \nPATH=$JAVA_HOME:$PATH' | \
    cat - /etc/default/jenkins > /home/ubuntu/temp && \
    sudo mv /home/ubuntu/temp /etc/default/jenkins

# https://stackoverflow.com/a/46249486 & https://stackoverflow.com/a/525612
sudo sed -i -e 's/https/http/g' /var/lib/jenkins/hudson.model.UpdateCenter.xml

cd /
sudo /etc/init.d/jenkins start

# Initial Admin Password for Jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Install Python 3.7 dependencies
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python3.7 get-pip.py
pip3 --version
pip3 install boto3

echo "END jenkins-setup.sh"