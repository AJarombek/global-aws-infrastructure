"""
Functions which represent Unit tests for the Jenkins server infrastructure
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3
from utils.ec2 import EC2

ec2 = boto3.client('ec2')
sts = boto3.client('sts')
iam = boto3.client('iam')
autoscaling = boto3.client('autoscaling')


def ami_exists() -> bool:
    """
    Check if there are one or many AMIs for the Jenkins server.
    :return: True if there are multiple (or one) AMI, False otherwise
    """
    owner = sts.get_caller_identity().get('Account')
    amis = ec2.describe_images(
        Owners=[owner],
        Filters=[{
            'Name': 'name',
            'Values': ['global-jenkins-server*']
        }]
    )
    return len(amis.get('Images')) > 0


def jenkins_server_running() -> bool:
    """
    Validate that the EC2 instance(s) holding the Jenkins server are running
    :return: True if the EC2 instance is running, False otherwise
    """
    instances = EC2.get_ec2('global-jenkins-server-asg')
    return len(instances) > 0


def jenkins_server_not_overscaled() -> bool:
    """
    Ensure that there aren't too many EC2 instances running for the Jenkins server
    :return: True if the EC2 instance is scaled appropriately, False otherwise
    """
    instances = EC2.get_ec2('global-jenkins-server-asg')
    return len(instances) < 2


def jenkins_instance_profile_exists() -> bool:
    """
    Prove that the instance profile exists for the Jenkins server
    :return: True if the instance profile exists, False otherwise
    """
    return EC2.instance_profile_valid(
        instance_profile_name='global-jenkis-server-instance-profile',
        asg_name='global-jenkins-server-asg',
        iam_role_name='jenkins-role'
    )


def jenkins_launch_config_valid() -> bool:
    """
    Ensure that the Launch Configuration for the Jenkins server is valid
    :return: True if its valid, False otherwise
    """
    return EC2.launch_config_valid(
        launch_config_name='global-jenkins-server-lc',
        asg_name='global-jenkins-server-asg',
        expected_instance_type='t2.micro',
        expected_key_name='jenkins-key',
        expected_sg_count=1,
        expected_instance_profile='global-jenkis-server-instance-profile'
    )

print(jenkins_server_running())