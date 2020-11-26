"""
Functions which represent Unit tests for the jarombek-com vpc infrastructure
Author: Andrew Jarombek
Date: 5/4/2019
"""

import unittest

import boto3

from aws_test_functions.VPC import VPC
from aws_test_functions.SecurityGroup import SecurityGroup


class TestJarombekComApp(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ec2 = boto3.resource('ec2')

    def test_jarombek_com_vpc_exists(self) -> None:
        """
        Determine if the jarombek-com-vpc exists
        """
        self.assertTrue(len(VPC.get_vpcs('jarombek-com-vpc')) == 1)

    def test_jarombek_com_vpc_configured(self) -> None:
        """
        Determine if the jarombek-com-vpc is configured and available as expected.
        """
        self.assertTrue(VPC.vpc_configured('jarombek-com-vpc'))

    def test_jarombek_com_internet_gateway_exists(self) -> None:
        """
        Determine if the jarombek-com-vpc-internet-gateway exists
        """
        self.assertTrue(len(VPC.get_internet_gateways('jarombek-com-vpc-internet-gateway')) == 1)

    def test_jarombek_com_network_acl_exists(self) -> None:
        """
        Determine if the jarombek-com-acl exists
        """
        self.assertTrue(len(VPC.get_network_acls('jarombek-com-acl')) == 1)

    def test_jarombek_com_dns_resolver_exists(self) -> None:
        """
        Determine if the jarombek-com-dhcp-options exists
        """
        self.assertTrue(len(VPC.get_dns_resolvers('jarombek-com-dhcp-options')) == 1)

    def test_jarombek_com_sg_valid(self) -> None:
        """
        Ensure that the security group attached to the jarombek-com-vpc is as expected
        """
        sg = SecurityGroup.get_security_groups('jarombek-com-vpc-security')[0]
    
        self.assertTrue(all([
            sg.get('GroupName') == 'jarombek-com-vpc-security',
            self.validate_jarombek_com_sg_rules(sg.get('IpPermissions'), sg.get('IpPermissionsEgress'))
        ]))

    def test_jarombek_com_yeezus_public_subnet_exists(self) -> None:
        """
        Determine if the jarombek-com-yeezus-public-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('jarombek-com-yeezus-public-subnet')) == 1)

    def test_jarombek_com_yeezus_public_subnet_configured(self) -> None:
        """
        Determine if the jarombek-com-yeezus-public-subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('jarombek-com-vpc')[0]
        subnet = VPC.get_subnets('jarombek-com-yeezus-public-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1a', '10.0.1.0/24'))

    def test_jarombek_com_yeezus_public_subnet_rt_configured(self) -> None:
        """
        Determine if the jarombek-com-yeezus-public-subnet routing table is configured and available as expected.
        """
        vpc = VPC.get_vpcs('jarombek-com-vpc')[0]
        subnet = VPC.get_subnets('jarombek-com-yeezus-public-subnet')[0]
        route_table = VPC.get_route_table('jarombek-com-vpc-public-subnet-rt')[0]
        internet_gateway = VPC.get_internet_gateways('jarombek-com-vpc-internet-gateway')[0]
    
        self.assertTrue(VPC.route_table_configured(
            route_table,
            vpc.get('VpcId'),
            subnet.get('SubnetId'),
            internet_gateway.get('InternetGatewayId')
        ))

    def test_jarombek_com_yandhi_public_subnet_exists(self) -> None:
        """
        Determine if the jarombek-com-yandhi-public-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('jarombek-com-yandhi-public-subnet')) == 1)

    def test_jarombek_com_yandhi_public_subnet_configured(self) -> None:
        """
        Determine if the jarombek-com-yandhi-public-subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('jarombek-com-vpc')[0]
        subnet = VPC.get_subnets('jarombek-com-yandhi-public-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1b', '10.0.2.0/24'))

    def test_jarombek_com_yandhi_public_subnet_rt_configured(self) -> None:
        """
        Determine if the jarombek-com-yandhi-public-subnet routing table is configured and available as expected.
        """
        vpc = VPC.get_vpcs('jarombek-com-vpc')[0]
        subnet = VPC.get_subnets('jarombek-com-yandhi-public-subnet')[0]
        route_table = VPC.get_route_table('jarombek-com-vpc-public-subnet-rt')[0]
        internet_gateway = VPC.get_internet_gateways('jarombek-com-vpc-internet-gateway')[0]
    
        self.assertTrue(VPC.route_table_configured(
            route_table,
            vpc.get('VpcId'),
            subnet.get('SubnetId'),
            internet_gateway.get('InternetGatewayId')
        ))

    def test_jarombek_com_red_private_subnet_exists(self) -> None:
        """
        Determine if the jarombek-com-red-private-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('jarombek-com-red-private-subnet')) == 1)

    def test_jarombek_com_red_private_subnet_configured(self) -> None:
        """
        Determine if the jarombek-com-red-private-subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('jarombek-com-vpc')[0]
        subnet = VPC.get_subnets('jarombek-com-red-private-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1c', '10.0.3.0/24'))

    def test_jarombek_com_reputation_private_subnet_exists(self) -> None:
        """
        Determine if the jarombek-com-reputation-private-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('jarombek-com-reputation-private-subnet')) == 1)

    def test_jarombek_com_reputation_private_subnet_configured(self) -> None:
        """
        Determine if the jarombek-com-reputation-private-subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('jarombek-com-vpc')[0]
        subnet = VPC.get_subnets('jarombek-com-reputation-private-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1d', '10.0.4.0/24'))

    """
    Helper methods for the jarombek-com VPC
    """

    def validate_jarombek_com_sg_rules(self, ingress: list, egress: list) -> bool:
        """
        Ensure that the jarombek-com-vpc security group rules are as expected
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