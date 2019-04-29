"""
Functions which represent Unit tests for the root infrastructure for my AWS account
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3
from utils.vpc import VPC

ec2 = boto3.client('ec2')

"""
Tests for the Resources VPC
"""


def resources_vpc_exists() -> bool:
    """
    Determine if the resources-vpc exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_vpcs('resources-vpc')) == 1


def resources_vpc_configured() -> bool:
    """
    Determine if the resources VPC is configured and available as expected.
    :return: True if the VPC is configured correctly, False otherwise
    """
    return VPC.vpc_configured('resources-vpc')


def resources_internet_gateway_exists() -> bool:
    """
    Determine if the resources-vpc-internet-gateway exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_internet_gateways('resources-vpc-internet-gateway')) == 1


def resources_network_acl_exists() -> bool:
    """
    Determine if the resources-acl exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_network_acls('resources-acl')) == 1


def resources_dns_resolver_exists() -> bool:
    """
    Determine if the resources-dhcp-options exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_dns_resolvers('resources-dhcp-options')) == 1


def resources_public_subnet_exists() -> bool:
    """
    Determine if the resources-vpc-public-subnet exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_subnets('resources-vpc-public-subnet')) == 1


def resources_public_subnet_configured() -> bool:
    vpc = VPC.get_vpcs('resources-vpc')[0]
    subnet = VPC.get_subnets('resources-vpc-public-subnet')[0]

    return VPC.subnet_configured(vpc, subnet, 'us-east-1c', '10.0.1.0/24')


def resources_private_subnet_exists() -> bool:
    """
    Determine if the resources-vpc-private-subnet exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_subnets('resources-vpc-private-subnet')) == 1


"""
Tests for the Sandbox VPC
"""


def sandbox_vpc_exists() -> bool:
    """
    Determine if the sandbox-vpc exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_vpcs('sandbox-vpc')) == 1


def sandbox_vpc_configured() -> bool:
    """
    Determine if the sandbox VPC is configured and available as expected.
    :return: True if the VPC is configured correctly, False otherwise
    """
    return VPC.vpc_configured('sandbox-vpc')


def sandbox_internet_gateway_exists() -> bool:
    """
    Determine if the sandbox-vpc-internet-gateway exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_internet_gateways('sandbox-vpc-internet-gateway')) == 1


def sandbox_network_acl_exists() -> bool:
    """
    Determine if the sandbox-acl exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_network_acls('sandbox-acl')) == 1


def sandbox_dns_resolver_exists() -> bool:
    """
    Determine if the sandbox-dhcp-options exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_dns_resolvers('sandbox-dhcp-options')) == 1


def sandbox_fearless_public_subnet_exists() -> bool:
    """
    Determine if the sandbox-vpc-fearless-public-subnet exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_subnets('sandbox-vpc-fearless-public-subnet')) == 1


def sandbox_speaknow_public_subnet_exists() -> bool:
    """
    Determine if the sandbox-vpc-speaknow-public-subnet exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_subnets('sandbox-vpc-speaknow-public-subnet')) == 1


print(resources_public_subnet_configured())