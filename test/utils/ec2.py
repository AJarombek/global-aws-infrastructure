"""
Helper functions for EC2 instances, and related resources
Author: Andrew Jarombek
Date: 4/30/2019
"""

import boto3
import botocore.exceptions as awserror

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
    def describe_instances_by_name(name: str) -> list:
        """
        Retrieve descriptions about EC2 instances with a given name.
        :param name: Name of the EC2 instance.
        :return: A list of instance metadata.
        """
        ec2_client = boto3.client('ec2')
        response = ec2_client.describe_instances(Filters=[
            {
                'Name': 'tag:Name',
                'Values': [name]
            }
        ])
        return response.get('Reservations')[0].get('Instances')

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

        try:
            instance_profile_arn = instances[0].iam_instance_profile.get('Arn')
        except IndexError:
            return False

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
        try:
            instance = EC2.get_ec2(asg_name)[0]
            security_group = instance.security_groups[0]
        except IndexError:
            return False

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

    @staticmethod
    def autoscaling_group_valid(asg_name: str = '', launch_config_name: str = '', min_size: int = 0,
                                max_size: int = 0, desired_size: int = 0, instance_count: int = 0) -> bool:
        """
        Ensure that the AutoScaling Group for a web server is valid
        :param asg_name: Name of the AutoScaling group for instances on AWS
        :param launch_config_name: Name of the Launch Configuration on AWS
        :param min_size: Minimum number of instances in the auto scaling group
        :param max_size: Maximum number of instances in the auto scaling group
        :param desired_size: Desired number of instances in the auto scaling group
        :param instance_count: Expected actual number of instances in the auto scaling group
        :return: True if its valid, False otherwise
        """

        asgs = autoscaling.describe_auto_scaling_groups(
            AutoScalingGroupNames=[asg_name],
            MaxRecords=1
        )

        try:
            asg = asgs.get('AutoScalingGroups')[0]
        except IndexError:
            return False

        return all([
            asg.get('LaunchConfigurationName') == launch_config_name,
            asg.get('MinSize') == min_size,
            asg.get('MaxSize') == max_size,
            asg.get('DesiredCapacity') == desired_size,
            len(asg.get('Instances')) == instance_count,
            asg.get('Instances')[0].get('LifecycleState') == 'InService',
            asg.get('Instances')[0].get('HealthStatus') == 'Healthy'
        ])

    @staticmethod
    def autoscaling_schedule_valid(asg_name: str = '', schedule_name: str = '', recurrence: str = '',
                                   max_size: int = 0, min_size: int = 0, desired_size: int = 0) -> bool:
        """
        Make sure an autoscaling schedule exists as expected
        :param asg_name: The name of the autoscaling group the schedule is a member of
        :param schedule_name: The name of the autoscaling schedule
        :param recurrence: When this schedule recurs
        :param max_size: maximum number of instances in the asg
        :param min_size: minimum number of instances in the asg
        :param desired_size: desired number of instances in the asg
        :return: True if the schedule exists as expected, False otherwise
        """
        try:
            response = autoscaling.describe_scheduled_actions(
                AutoScalingGroupName=asg_name,
                ScheduledActionNames=[schedule_name],
                MaxRecords=1
            )
        except awserror.ClientError:
            return False

        schedule = response.get('ScheduledUpdateGroupActions')[0]

        return all([
            schedule.get('Recurrence') == recurrence,
            schedule.get('MinSize') == min_size,
            schedule.get('MaxSize') == max_size,
            schedule.get('Recurrence') == desired_size
        ])

    @staticmethod
    def load_balancer_target_groups_valid(asg_name: str = '', load_balancer_target_group_names: list = None) -> bool:
        """
        Validate the target groups of the load balancer
        :param asg_name: The name of the autoscaling group which uses the load balancer
        :param load_balancer_target_group_names: List of target group names to look for on the load balancer
        :return: True if the target groups are valid, False otherwise
        """
        try:
            response = autoscaling.describe_load_balancer_target_groups(AutoScalingGroupName=asg_name)
        except awserror.ClientError:
            return False

        load_balancers = response.get('LoadBalancerTargetGroups')

        if load_balancer_target_group_names is None or len(load_balancer_target_group_names) == 0:
            return len(load_balancers) == 0
        else:
            for index, target_group in enumerate(load_balancer_target_group_names):
                if not load_balancers[index].get('State') == 'InService' or \
                        f'targetgroup/{target_group}' not in load_balancers[index].get('LoadBalancerTargetGroupARN'):
                    return False

        return True
