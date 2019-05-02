"""
Functions which represent Unit tests for the Jenkins server infrastructure
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3
from utils.ec2 import EC2
from utils.securityGroup import SecurityGroup

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


def jenkins_launch_config_sg_valid():
    """
    Ensure that the security group attached to the launch configuration is as expected
    :return: True if its as expected, False otherwise
    """
    lcs = autoscaling.describe_launch_configurations(
        LaunchConfigurationNames=['global-jenkins-server-lc'],
        MaxRecords=1
    )

    launch_config = lcs.get('LaunchConfigurations')[0]
    sg_id = launch_config.get('SecurityGroups')[0]
    sg = ec2.describe_security_groups(GroupIds=[sg_id]).get('SecurityGroups')[0]

    ingress = sg.get('IpPermissions')
    egress = sg.get('IpPermissionsEgress')

    ingress_80 = SecurityGroup.validate_sg_rule_cidr(ingress[0], 'tcp', 80, 80, '0.0.0.0/0')
    ingress_22 = SecurityGroup.validate_sg_rule_cidr(ingress[1], 'tcp', 22, 22, '0.0.0.0/0')

    egress_80 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 80, 80, '0.0.0.0/0')
    egress_22 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 22, 22, '0.0.0.0/0')
    egress_443 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 443, 443, '0.0.0.0/0')
    egress_2049 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 2049, 2049, '0.0.0.0/0')

    return all([
        sg.get('GroupName') == 'global-jenkins-server-lc-security-group',
        len(ingress) == 2,
        ingress_80,
        ingress_22,
        len(egress) == 4,
        egress_80,
        egress_22,
        egress_443,
        egress_2049
    ])


def jenkins_autoscaling_group_valid() -> bool:
    """
    Ensure that the AutoScaling Group for the Jenkins server is valid
    :return: True if its valid, False otherwise
    """
    return EC2.autoscaling_group_valid(
        asg_name='global-jenkins-server-asg',
        launch_config_name='global-jenkins-server-lc',
        min_size=1,
        max_size=1,
        desired_size=1,
        instance_count=1
    )


def jenkins_autoscaling_schedules_set() -> bool:
    """
    Make sure the autoscaling schedules exist as expected for the Jenkins server
    (the ASG should be down in non-work hours)
    :return: True if there are the expected schedules, False otherwise
    """
    return all([
        EC2.autoscaling_schedule_valid(
            asg_name='global-jenkins-server-asg',
            schedule_name='jenkins-server-online-weekday-morning',
            recurrence='30 11 * * 1-5',
            max_size=1,
            min_size=1,
            desired_size=1
        ),
        EC2.autoscaling_schedule_valid(
            asg_name='global-jenkins-server-asg',
            schedule_name='jenkins-server-offline-weekday-morning',
            recurrence='30 13 * * 1-5',
            max_size=0,
            min_size=0,
            desired_size=0),
        EC2.autoscaling_schedule_valid(
            asg_name='global-jenkins-server-asg',
            schedule_name='jenkins-server-online-weekday-afternoon',
            recurrence='30 22 * * 1-5',
            max_size=1,
            min_size=1,
            desired_size=1
        ),
        EC2.autoscaling_schedule_valid(
            asg_name='global-jenkins-server-asg',
            schedule_name='jenkins-server-offline-weekday-afternoon',
            recurrence='30 3 * * 2-6',
            max_size=0,
            min_size=0,
            desired_size=0
        ),
        EC2.autoscaling_schedule_valid(
            asg_name='global-jenkins-server-asg',
            schedule_name='jenkins-server-online-weekend',
            recurrence='30 11 * * 0,6',
            max_size=1,
            min_size=1,
            desired_size=1
        ),
        EC2.autoscaling_schedule_valid(
            asg_name='global-jenkins-server-asg',
            schedule_name='jenkins-server-offline-weekend',
            recurrence='30 3 * * 0,1',
            max_size=0,
            min_size=0,
            desired_size=0
        )
    ])


def jenkins_load_balancer_running():
    """
    Prove that the application load balancer for the Jenkins server is running
    :return: True if its running, False otherwise
    """
    return validate_load_balancer(is_prod=False)


print(jenkins_server_running())