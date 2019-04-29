"""
Helper functions for VPCs, Subnets, and related resources
Author: Andrew Jarombek
Date: 4/28/2019
"""

import boto3

ec2 = boto3.client('ec2')


class VPC:

    @staticmethod
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

    @staticmethod
    def vpc_configured(name: str) -> bool:
        """
        Determine if a VPC is configured and available as expected.
        :param name: Name of the VPC in AWS
        :return: True if the VPC is configured correctly, False otherwise
        """
        vpc = VPC.get_vpcs(name)[0]

        return all([
            vpc.get('State') == 'available',
            vpc.get('CidrBlockAssociationSet')[0].get('CidrBlock') == '10.0.0.0/16',
            vpc.get('CidrBlockAssociationSet')[0].get('CidrBlockState').get('State') == 'associated',
            vpc.get('IsDefault') is False
        ])

    @staticmethod
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

    @staticmethod
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

    @staticmethod
    def get_dns_resolvers(name: str) -> list:
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

    @staticmethod
    def get_subnets(name: str) -> list:
        """
        Get a list of Subnets that match a given name
        :param name: Name of the Subnet in AWS
        :return: A list of Subnet objects (dictionaries)
        """
        subnets = ec2.describe_subnets(
            Filters=[{
                'Name': 'tag:Name',
                'Values': [name]
            }]
        )
        return subnets.get('Subnets')

    @staticmethod
    def subnet_configured(vpc: dict, subnet: dict, az: str, cidr: str) -> bool:
        """
        Determine if a Subnet is configured as expected in the proper Subnet.
        :param vpc: Dictionary containing VPC information
        :param subnet: Dictionary containing Subnet information
        :param az: Availability Zone for the Subnet
        :param cidr: CIDR block for the Subnet IP addresses
        :return: True if the Subnet is configured as expected, False otherwise
        """
        return all([
            subnet.get('VpcId') == vpc.get('VpcId'),
            subnet.get('AvailabilityZone') == az,
            subnet.get('CidrBlock') == cidr,
            subnet.get('State') == 'available'
        ])