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
    def vpc_configured(name: str, cidr: str = '10.0.0.0/16') -> bool:
        """
        Determine if a VPC is configured and available as expected.
        :param name: Name of the VPC in AWS
        :param cidr: CIDR block of private IP addresses assigned to the VPC
        :return: True if the VPC is configured correctly, False otherwise
        """
        vpc = VPC.get_vpcs(name)[0]

        return all([
            vpc.get('State') == 'available',
            vpc.get('CidrBlockAssociationSet')[0].get('CidrBlock') == cidr,
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

    @staticmethod
    def get_route_table(name: str) -> list:
        """
        Get a list of Route Tables that match a given name
        :param name: Name of the Route Table in AWS
        :return: A list of Route Table objects (dictionaries)
        """
        rts = ec2.describe_route_tables(
            Filters=[{
                'Name': 'tag:Name',
                'Values': [name]
            }]
        )
        return rts.get('RouteTables')

    @staticmethod
    def route_table_configured(
        route_table: dict,
        vpc_id: str,
        subnet_id: str,
        igw_id: str,
        cidr: str = '10.0.0.0/16'
    ) -> bool:
        """
        Determine if a route table is configured as expected
        :param route_table: Dictionary containing information about a routing table
        :param vpc_id: Identifier for a VPC the routing table should exist in
        :param subnet_id: Identifier for a Subnet the routing table should be associated with
        :param igw_id: Identifier for an Internet Gateway used by the routing table to route traffic to the internet
        :param cidr: CIDR block of private IP addresses assigned to the VPC
        :return: True if the route table is configured as expected, False otherwise
        """
        return all([
            route_table.get('VpcId') == vpc_id,
            len([True for item in route_table.get('Associations') if item.get('SubnetId') == subnet_id]) == 1,
            route_table.get('Routes')[0].get('DestinationCidrBlock') == cidr,
            route_table.get('Routes')[0].get('GatewayId') == 'local',
            route_table.get('Routes')[0].get('State') == 'active',
            route_table.get('Routes')[1].get('DestinationCidrBlock') == '0.0.0.0/0',
            route_table.get('Routes')[1].get('GatewayId') == igw_id,
            route_table.get('Routes')[1].get('State') == 'active'
        ])
