"""
Helper functions for EC2 instances, and related resources
Author: Andrew Jarombek
Date: 4/30/2019
"""

import boto3

ec2 = boto3.client('ec2')
iam = boto3.client('iam')
autoscaling = boto3.client('autoscaling')


class EC2:

    @staticmethod
    def get_ec2(name: str) -> list:
        """
        Get a list of running EC2 instances with a given name
        :param name: The name of EC2 instances to retrieve
        :return: A list of EC2 instances
        """
        ec2_resource = boto3.resource('ec2')
        filters = [
            {
                'Name': 'tag:Name',
                'Values': [name]
            },
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]

        return list(ec2_resource.instances.filter(Filters=filters).all())

    @staticmethod
    def instance_profile_valid(instance_profile_name: str = '', asg_name: str = '', iam_role_name: str = '') -> bool:
        """
        Prove that an instance profile exists as expected
        :param instance_profile_name: Name of the Instance Profile on AWS
        :param asg_name: Name of the AutoScaling group for instances on AWS
        :param iam_role_name: Name of the IAM role associated with the instance profile
        :return: True if the instance profile exists as expected, False otherwise
        """

        # First get the instance profile resource name from the ec2 instance
        instances = EC2.get_ec2(asg_name)
        instance_profile_arn = instances[0].iam_instance_profile.get('Arn')

        # Second get the instance profile from IAM
        instance_profile = iam.get_instance_profile(InstanceProfileName=instance_profile_name)
        instance_profile = instance_profile.get('InstanceProfile')

        # Third get the RDS access IAM Role resource name from IAM
        role = iam.get_role(RoleName=iam_role_name)
        role_arn = role.get('Role').get('Arn')

        return all([
            instance_profile_arn == instance_profile.get('Arn'),
            role_arn == instance_profile.get('Roles')[0].get('Arn')
        ])

    @staticmethod
    def launch_config_valid(launch_config_name: str = '', asg_name: str = '', expected_instance_type: str = '',
                            expected_key_name: str = '', expected_sg_count: int = 0,
                            expected_instance_profile: str = '') -> bool:
        """
        Ensure that a Launch Configuration is valid
        :param launch_config_name: Name of the Launch Configuration on AWS
        :param asg_name: Name of the AutoScaling group for instances on AWS
        :param expected_instance_type: Expected Instance type for the Launch Configuration instances
        :param expected_key_name: Expected SSH Key name to connect to the instances
        :param expected_sg_count: Expected number of security groups for the instances
        :param expected_instance_profile: Expected instance profile attached to the instances
        :return: True if its valid, False otherwise
        """
        instance = EC2.get_ec2(asg_name)[0]
        security_group = instance.security_groups[0]

        lcs = autoscaling.describe_launch_configurations(
            LaunchConfigurationNames=[launch_config_name],
            MaxRecords=1
        )

        launch_config = lcs.get('LaunchConfigurations')[0]

        return all([
            launch_config.get('InstanceType') == expected_instance_type,
            launch_config.get('KeyName') == expected_key_name,
            len(launch_config.get('SecurityGroups')) == expected_sg_count,
            launch_config.get('SecurityGroups')[0] == security_group.get('GroupId'),
            launch_config.get('IamInstanceProfile') == expected_instance_profile
        ])
