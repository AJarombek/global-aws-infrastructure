"""
Functions which represent Unit tests for the root infrastructure for my AWS account
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3

ec2 = boto3.client('ec2')


def resources_vpc_exists() -> bool:
    """
    Determine if the resources-vpc exists
    :return: True if it exists, False otherwise
    """
    return len(get_vpcs('resources-vpc')) == 1


def resources_vpc_configured() -> bool:
    """
    Determine if the resources VPC is configured and available as expected.
    :return: True if the VPC is configured correctly, False otherwise
    """
    return vpc_configured('resources-vpc')


def resources_internet_gateway_exists() -> bool:
    return len(get_internet_gateways('resources-vpc-internet-gateway')) == 1


def sandbox_vpc_exists() -> bool:
    """
    Determine if the sandbox-vpc exists
    :return: True if it exists, False otherwise
    """
    return len(get_vpcs('sandbox-vpc')) == 1


def sandbox_vpc_configured() -> bool:
    """
    Determine if the sandbox VPC is configured and available as expected.
    :return: True if the VPC is configured correctly, False otherwise
    """
    return vpc_configured('sandbox-vpc')


def sandbox_internet_gateway_exists() -> bool:
    return len(get_internet_gateways('sandbox-vpc-internet-gateway')) == 1


"""
Helper functions for VPCs, Subnets, and related resources
"""


def get_vpcs(name: str) -> list:
    """
    Get a list of VPCs that match a given name
    :param name: Name of the VPC in AWS
    :return: A list of VPC objects (dictionaries)
    """
    vpcs = ec2.describe_vpcs(
        Filters=[{
            'Name': 'tag:Name',
            'Values': [name]
        }]
    )
    return vpcs.get('Vpcs')


def vpc_configured(name: str) -> bool:
    """
    Determine if a VPC is configured and available as expected.
    :param name: Name of the VPC in AWS
    :return: True if the VPC is configured correctly, False otherwise
    """
    vpc = get_vpcs(name)[0]

    return all([
        vpc.get('State') == 'available',
        vpc.get('CidrBlockAssociationSet')[0].get('CidrBlock') == '10.0.0.0/16',
        vpc.get('CidrBlockAssociationSet')[0].get('CidrBlockState').get('State') == 'associated',
        vpc.get('IsDefault') is False
    ])


def get_internet_gateways(name: str) -> list:
    igw = ec2.describe_internet_gateways(
        Filters=[{
            'Name': 'tag:Name',
            'Values': [name]
        }]
    )
    return igw.get('InternetGateways')


print(resources_internet_gateway_exists())