"""
Functions which represent Unit tests for the saints-xctf-com vpc infrastructure
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3
from utils.vpc import VPC
from utils.securityGroup import SecurityGroup

ec2 = boto3.resource('ec2')


def saintsxctf_com_vpc_exists() -> bool:
    """
    Determine if the saints-xctf-com-vpc exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_vpcs('saints-xctf-com-vpc')) == 1


def saintsxctf_com_vpc_configured() -> bool:
    """
    Determine if the saints-xctf-com-vpc is configured and available as expected.
    :return: True if the VPC is configured correctly, False otherwise
    """
    return VPC.vpc_configured('saints-xctf-com-vpc')


def saintsxctf_com_internet_gateway_exists() -> bool:
    """
    Determine if the saints-xctf-com-vpc-internet-gateway exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_internet_gateways('saints-xctf-com-vpc-internet-gateway')) == 1


def saintsxctf_com_network_acl_exists() -> bool:
    """
    Determine if the saints-xctf-com-acl exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_network_acls('saints-xctf-com-acl')) == 1


def saintsxctf_com_dns_resolver_exists() -> bool:
    """
    Determine if the saints-xctf-com-dhcp-options exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_dns_resolvers('saints-xctf-com-dhcp-options')) == 1


def saintsxctf_com_sg_valid() -> bool:
    """
    Ensure that the security group attached to the saints-xctf-com-vpc is as expected
    :return: True if its as expected, False otherwise
    """
    sg = SecurityGroup.get_security_groups('saints-xctf-com-vpc-security')[0]

    return all([
        sg.get('GroupName') == 'saints-xctf-com-vpc-security',
        validate_saintsxctf_com_sg_rules(sg.get('IpPermissions'), sg.get('IpPermissionsEgress'))
    ])


def saintsxctf_com_lisag_public_subnet_exists() -> bool:
    """
    Determine if the saints-xctf-com-lisag-public-subnet exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_subnets('saints-xctf-com-lisag-public-subnet')) == 1


def saintsxctf_com_lisag_public_subnet_configured() -> bool:
    """
    Determine if the saints-xctf-com-lisag-public-subnet is configured and available as expected.
    :return: True if the Subnet is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('saints-xctf-com-vpc')[0]
    subnet = VPC.get_subnets('saints-xctf-com-lisag-public-subnet')[0]

    return VPC.subnet_configured(vpc, subnet, 'us-east-1b', '10.0.1.0/24')


def saintsxctf_com_lisag_public_subnet_rt_configured() -> bool:
    """
    Determine if the saints-xctf-com-lisag-public-subnet routing table is configured and available as expected.
    :return: True if the routing table is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('saints-xctf-com-vpc')[0]
    subnet = VPC.get_subnets('saints-xctf-com-lisag-public-subnet')[0]
    route_table = VPC.get_route_table('saints-xctf-com-vpc-public-subnet-rt')[0]
    internet_gateway = VPC.get_internet_gateways('saints-xctf-com-vpc-internet-gateway')[0]

    return VPC.route_table_configured(
        route_table,
        vpc.get('VpcId'),
        subnet.get('SubnetId'),
        internet_gateway.get('InternetGatewayId')
    )


def saintsxctf_com_megank_public_subnet_exists() -> bool:
    """
    Determine if the saints-xctf-com-megank-public-subnet exists
    :return: True if it exists, False otherwise
    """
    return len(VPC.get_subnets('saints-xctf-com-megank-public-subnet')) == 1


def saintsxctf_com_megank_public_subnet_configured() -> bool:
    """
    Determine if the saints-xctf-com-megank-public-subnet is configured and available as expected.
    :return: True if the Subnet is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('saints-xctf-com-vpc')[0]
    subnet = VPC.get_subnets('saints-xctf-com-megank-public-subnet')[0]

    return VPC.subnet_configured(vpc, subnet, 'us-east-1d', '10.0.2.0/24')


def saintsxctf_com_megank_public_subnet_rt_configured() -> bool:
    """
    Determine if the saints-xctf-com-megank-public-subnet routing table is configured and available as expected.
    :return: True if the routing table is configured correctly, False otherwise
    """
    vpc = VPC.get_vpcs('saints-xctf-com-vpc')[0]
    subnet = VPC.get_subnets('saints-xctf-com-megank-public-subnet')[0]
    route_table = VPC.get_route_table('saints-xctf-com-vpc-public-subnet-rt')[0]
    internet_gateway = VPC.get_internet_gateways('saints-xctf-com-vpc-internet-gateway')[0]

    return VPC.route_table_configured(
        route_table,
        vpc.get('VpcId'),
        subnet.get('SubnetId'),
        internet_gateway.get('InternetGatewayId')
    )


"""
Helper methods for the saintsxctf-com VPC
"""


def validate_saintsxctf_com_sg_rules(ingress: list, egress: list):
    """
    Ensure that the saints-xctf-com-vpc security group rules are as expected
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
