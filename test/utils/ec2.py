"""
Helper functions for EC2 instances, and related resources
Author: Andrew Jarombek
Date: 4/30/2019
"""

import boto3

ec2 = boto3.client('ec2')


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
