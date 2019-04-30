"""
Functions which represent Unit tests for the root infrastructure for my AWS account
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3
from utils.vpc import VPC
from utils.securityGroup import SecurityGroup

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


def resources_sg_valid() -> bool:
    """
    Ensure that the security group attached to the resources-vpc is as expected
    :return: True if its as expected, False otherwise
    """
    pass


def resources_public_subnet_exists() -> bool:
    """
    Determine if the resources-vpc-public-subnet exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_subnets('resources-vpc-public-subnet')) == 1


def resources_public_subnet_configured() -> bool:
    """
    Determine if the resources public Subnet is configured and available as expected.
    :return: True if the Subnet is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('resources-vpc')[0]
    subnet = VPC.get_subnets('resources-vpc-public-subnet')[0]

    return VPC.subnet_configured(vpc, subnet, 'us-east-1c', '10.0.1.0/24')


def resources_public_subnet_rt_configured() -> bool:
    """
    Determine if the resources public subnet routing table is configured and available as expected.
    :return: True if the routing table is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('resources-vpc')[0]
    subnet = VPC.get_subnets('resources-vpc-public-subnet')[0]
    route_table = VPC.get_route_table('resources-vpc-public-subnet-rt')[0]
    internet_gateway = VPC.get_internet_gateways('resources-vpc-internet-gateway')[0]

    return VPC.route_table_configured(
        route_table,
        vpc.get('VpcId'),
        subnet.get('SubnetId'),
        internet_gateway.get('InternetGatewayId')
    )


def resources_private_subnet_exists() -> bool:
    """
    Determine if the resources-vpc-private-subnet exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_subnets('resources-vpc-private-subnet')) == 1


def resources_private_subnet_configured() -> bool:
    """
    Determine if the resources private Subnet is configured and available as expected.
    :return: True if the Subnet is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('resources-vpc')[0]
    subnet = VPC.get_subnets('resources-vpc-private-subnet')[0]

    return VPC.subnet_configured(vpc, subnet, 'us-east-1c', '10.0.2.0/24')


"""
Helper methods for the Resources VPC
"""


def validate_resources_sg_rules(ingress: list, egress: list):
    """
    Ensure that the resources-vpc security group rules are as expected
    :param ingress: Ingress rules for the security group
    :param egress: Egress rules for the security group
    :return: True if the security group rules exist as expected, False otherwise
    """
    ingress_80 = SecurityGroup.validate_sg_rule_cidr(ingress[0], 'tcp', 80, 80, '0.0.0.0/0')
    ingress_22 = SecurityGroup.validate_sg_rule_cidr(ingress[1], 'tcp', 22, 22, '0.0.0.0/0')
    ingress_443 = SecurityGroup.validate_sg_rule_cidr(ingress[2], 'tcp', 443, 443, '0.0.0.0/0')
    ingress_neg1 = SecurityGroup.validate_sg_rule_cidr(ingress[3], 'icmp', -1, -1, '0.0.0.0/0')

    egress_80 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 80, 80, '0.0.0.0/0')
    egress_neg1 = SecurityGroup.validate_sg_rule_cidr(egress[1], '-1', 0, 0, '0.0.0.0/0')
    egress_443 = SecurityGroup.validate_sg_rule_cidr(egress[2], 'tcp', 443, 443, '0.0.0.0/0')

    return all([
        len(ingress) == 4,
        ingress_80,
        ingress_22,
        ingress_443,
        ingress_neg1,
        len(egress) == 3,
        egress_80,
        egress_neg1,
        egress_443
    ])


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


def sandbox_sg_valid() -> bool:
    """
    Ensure that the security group attached to the sandbox-vpc is as expected
    :return: True if its as expected, False otherwise
    """
    pass


def sandbox_fearless_public_subnet_exists() -> bool:
    """
    Determine if the sandbox-vpc-fearless-public-subnet exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_subnets('sandbox-vpc-fearless-public-subnet')) == 1


def sandbox_fearless_public_subnet_configured() -> bool:
    """
    Determine if the sandbox 'fearless' public Subnet is configured and available as expected.
    :return: True if the Subnet is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('sandbox-vpc')[0]
    subnet = VPC.get_subnets('sandbox-vpc-fearless-public-subnet')[0]

    return VPC.subnet_configured(vpc, subnet, 'us-east-1a', '10.0.1.0/24')


def sandbox_fearless_public_subnet_rt_configured() -> bool:
    """
    Determine if the sandbox 'fearless' public subnet routing table is configured and available as expected.
    :return: True if the routing table is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('sandbox-vpc')[0]
    subnet = VPC.get_subnets('sandbox-vpc-fearless-public-subnet')[0]
    route_table = VPC.get_route_table('sandbox-vpc-public-subnet-rt')[0]
    internet_gateway = VPC.get_internet_gateways('sandbox-vpc-internet-gateway')[0]

    return VPC.route_table_configured(
        route_table,
        vpc.get('VpcId'),
        subnet.get('SubnetId'),
        internet_gateway.get('InternetGatewayId')
    )


def sandbox_speaknow_public_subnet_exists() -> bool:
    """
    Determine if the sandbox-vpc-speaknow-public-subnet exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_subnets('sandbox-vpc-speaknow-public-subnet')) == 1


def sandbox_speaknow_public_subnet_configured() -> bool:
    """
    Determine if the sandbox 'speaknow' public Subnet is configured and available as expected.
    :return: True if the Subnet is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('sandbox-vpc')[0]
    subnet = VPC.get_subnets('sandbox-vpc-speaknow-public-subnet')[0]

    return VPC.subnet_configured(vpc, subnet, 'us-east-1b', '10.0.2.0/24')


def sandbox_speaknow_public_subnet_rt_configured() -> bool:
    """
    Determine if the sandbox 'speaknow' public subnet routing table is configured and available as expected.
    :return: True if the routing table is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('sandbox-vpc')[0]
    subnet = VPC.get_subnets('sandbox-vpc-speaknow-public-subnet')[0]
    route_table = VPC.get_route_table('sandbox-vpc-public-subnet-rt')[0]
    internet_gateway = VPC.get_internet_gateways('sandbox-vpc-internet-gateway')[0]

    return VPC.route_table_configured(
        route_table,
        vpc.get('VpcId'),
        subnet.get('SubnetId'),
        internet_gateway.get('InternetGatewayId')
    )


"""
Helper methods for the Sandbox VPC
"""


def validate_sandbox_sg_rules(ingress: list, egress: list):
    """
    Ensure that the sandbox-vpc security group rules are as expected
    :param ingress: Ingress rules for the security group
    :param egress: Egress rules for the security group
    :return: True if the security group rules exist as expected, False otherwise
    """
    ingress_80 = SecurityGroup.validate_sg_rule_cidr(ingress[0], 'tcp', 80, 80, '0.0.0.0/0')
    ingress_22 = SecurityGroup.validate_sg_rule_cidr(ingress[1], 'tcp', 22, 22, '0.0.0.0/0')
    ingress_443 = SecurityGroup.validate_sg_rule_cidr(ingress[2], 'tcp', 443, 443, '0.0.0.0/0')
    ingress_neg1 = SecurityGroup.validate_sg_rule_cidr(ingress[3], 'icmp', -1, -1, '0.0.0.0/0')

    egress_80 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 80, 80, '0.0.0.0/0')
    egress_neg1 = SecurityGroup.validate_sg_rule_cidr(egress[1], '-1', 0, 0, '0.0.0.0/0')
    egress_443 = SecurityGroup.validate_sg_rule_cidr(egress[2], 'tcp', 443, 443, '0.0.0.0/0')

    return all([
        len(ingress) == 4,
        ingress_80,
        ingress_22,
        ingress_443,
        ingress_neg1,
        len(egress) == 3,
        egress_80,
        egress_neg1,
        egress_443
    ])


print(resources_public_subnet_rt_configured())