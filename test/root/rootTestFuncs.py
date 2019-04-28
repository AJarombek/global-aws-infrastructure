"""
Functions which represent Unit tests for the root infrastructure for my AWS account
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3

ec2 = boto3.resource('ec2')


def resources_vpc_exists() -> bool:
    vpc = ec2.describe_vpcs(
        Filters=[],
        MaxResults=1
    )


def sandbox_vpc_exists() -> bool:
    pass
