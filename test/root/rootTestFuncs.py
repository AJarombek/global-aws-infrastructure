"""
Functions which represent Unit tests for the root infrastructure for my AWS account
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3

ec2 = boto3.client('ec2')

"""
Tests for the Resources VPC
"""


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
    """
    Determine if the resources-vpc-internet-gateway exists
    :return: True if it exists, False otherwise
    """
    return len(get_internet_gateways('resources-vpc-internet-gateway')) == 1


def resources_network_acl_exists() -> bool:
    """
    Determine if the resources-acl exists
    :return: True if it exists, False otherwise
    """
    return len(get_network_acls('resources-acl')) == 1


def resources_dns_resolver_exists() -> bool:
    """
    Determine if the resources-dhcp-options exists
    :return: True if it exists, False otherwise
    """
    return len(get_dns_resolver('resources-dhcp-options')) == 1


"""
Tests for the Sandbox VPC
"""


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
    """
    Determine if the sandbox-vpc-internet-gateway exists
    :return: True if it exists, False otherwise
    """
    return len(get_internet_gateways('sandbox-vpc-internet-gateway')) == 1


def sandbox_network_acl_exists() -> bool:
    """
    Determine if the sandbox-acl exists
    :return: True if it exists, False otherwise
    """
    return len(get_network_acls('sandbox-acl')) == 1


def sandbox_dns_resolver_exists() -> bool:
    """
    Determine if the sandbox-dhcp-options exists
    :return: True if it exists, False otherwise
    """
    return len(get_dns_resolver('sandbox-dhcp-options')) == 1


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
    """
    Get a list of Internet Gateways that match a given name
    :param name: Name of the Internet Gateway in AWS
    :return: A list of Internet Gateway objects (dictionaries)
    """
    igw = ec2.describe_internet_gateways(
        Filters=[{
            'Name': 'tag:Name',
            'Values': [name]
        }]
    )
    return igw.get('InternetGateways')


def get_network_acls(name: str) -> list:
    """
    Get a list of Network ACLs that match a given name
    :param name: Name of the Network ACL in AWS
    :return: A list of Network ACL objects (dictionaries)
    """
    acls = ec2.describe_network_acls(
        Filters=[{
            'Name': 'tag:Name',
            'Values': [name]
        }]
    )
    return acls.get('NetworkAcls')


def get_dns_resolver(name: str) -> list:
    """
    Get a list of DHCP Option sets that match a given name
    :param name: Name of the DHCP Option set in AWS
    :return: A list of DHCP Option set objects (dictionaries)
    """
    dhcp = ec2.describe_dhcp_options(
        Filters=[{
            'Name': 'tag:Name',
            'Values': [name]
        }]
    )
    return dhcp.get('DhcpOptions')


print(resources_dns_resolver_exists())