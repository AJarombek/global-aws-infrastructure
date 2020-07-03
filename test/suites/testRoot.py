"""
Functions which represent Unit tests for the root infrastructure for my AWS account
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest
import boto3
from utils.vpc import VPC
from utils.securityGroup import SecurityGroup


class TestRoot(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ec2 = boto3.client('ec2')

    """
    Tests for the Kubernetes VPC
    """

    def test_kubernetes_vpc_exists(self) -> None:
        """
        Determine if the kubernetes-vpc exists
        """
        self.assertTrue(len(VPC.get_vpcs('kubernetes-vpc')) == 1)

    def test_kubernetes_vpc_configured(self) -> None:
        """
        Determine if the kubernetes VPC is configured and available as expected.\
        """
        self.assertTrue(VPC.vpc_configured('kubernetes-vpc'))

    def test_kubernetes_internet_gateway_exists(self) -> None:
        """
        Determine if the kubernetes-vpc-internet-gateway exists
        """
        self.assertTrue(len(VPC.get_internet_gateways('kubernetes-vpc-internet-gateway')) == 1)

    def test_kubernetes_network_acl_exists(self) -> None:
        """
        Determine if the kubernetes-acl exists
        """
        self.assertTrue(len(VPC.get_network_acls('kubernetes-acl')) == 1)

    def test_kubernetes_dns_resolver_exists(self) -> None:
        """
        Determine if the kubernetes-dhcp-options exists
        """
        self.assertTrue(len(VPC.get_dns_resolvers('kubernetes-dhcp-options')) == 1)

    def test_kubernetes_sg_valid(self) -> None:
        """
        Ensure that the security group attached to the kubernetes-vpc is as expected
        """
        sg = SecurityGroup.get_security_groups('kubernetes-vpc-security')[0]
    
        self.assertTrue(all([
            sg.get('GroupName') == 'kubernetes-vpc-security',
            self.validate_sandbox_sg_rules(sg.get('IpPermissions'), sg.get('IpPermissionsEgress'))
        ]))
    
    def test_kubernetes_dotty_public_subnet_exists(self) -> None:
        """
        Determine if the kubernetes-dotty-public-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('kubernetes-dotty-public-subnet')) == 1)

    def test_kubernetes_grandmas_blanket_public_subnet_exists(self) -> None:
        """
        Determine if the kubernetes-grandmas-blanket-public-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('kubernetes-grandmas-blanket-public-subnet')) == 1)

    def test_kubernetes_dotty_public_subnet_configured(self) -> None:
        """
        Determine if the kubernetes dotty public Subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('kubernetes-vpc')[0]
        subnet = VPC.get_subnets('kubernetes-dotty-public-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1a', '10.0.1.0/24'))

    def test_kubernetes_grandmas_blanket_public_subnet_configured(self) -> None:
        """
        Determine if the kubernetes grandmas blanket public Subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('kubernetes-vpc')[0]
        subnet = VPC.get_subnets('kubernetes-grandmas-blanket-public-subnet')[0]

        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1b', '10.0.2.0/24'))

    def test_kubernetes_public_subnet_rt_configured(self) -> None:
        """
        Determine if the kubernetes public subnet routing table is configured and available as expected.
        :return: True if the routing table is configured correctly, False otherwise
        """
        vpc = VPC.get_vpcs('kubernetes-vpc')[0]
        subnet = VPC.get_subnets('kubernetes-vpc-public-subnet')[0]
        route_table = VPC.get_route_table('kubernetes-vpc-public-subnet-rt')[0]
        internet_gateway = VPC.get_internet_gateways('kubernetes-vpc-internet-gateway')[0]
    
        self.assertTrue(VPC.route_table_configured(
            route_table,
            vpc.get('VpcId'),
            subnet.get('SubnetId'),
            internet_gateway.get('InternetGatewayId')
        ))
    
    def test_kubernetes_teddy_private_subnet_exists(self) -> None:
        """
        Determine if the kubernetes-teddy-private-subnet exists
        :return: True if it exists, False otherwise
        """
        self.assertTrue(len(VPC.get_subnets('kubernetes-teddy-private-subnet')) == 1)

    def test_kubernetes_lily_private_subnet_exists(self) -> None:
        """
        Determine if the kubernetes-lily-private-subnet exists
        :return: True if it exists, False otherwise
        """
        self.assertTrue(len(VPC.get_subnets('kubernetes-lily-private-subnet')) == 1)

    def test_kubernetes_teddy_private_subnet_configured(self) -> None:
        """
        Determine if the kubernetes teddy private Subnet is configured and available as expected.
        :return: True if the Subnet is configured correctly, False otherwise
        """
        vpc = VPC.get_vpcs('kubernetes-vpc')[0]
        subnet = VPC.get_subnets('kubernetes-teddy-private-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1c', '10.0.4.0/24'))

    def test_kubernetes_lily_private_subnet_configured(self) -> None:
        """
        Determine if the kubernetes lily private subnet is configured and available as expected.
        :return: True if the Subnet is configured correctly, False otherwise
        """
        vpc = VPC.get_vpcs('kubernetes-vpc')[0]
        subnet = VPC.get_subnets('kubernetes-lily-private-subnet')[0]

        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1b', '10.0.3.0/24'))
    
    """
    Helper methods for the Resources VPC
    """
    
    def validate_kubernetes_sg_rules(self, ingress: list, egress: list) -> bool:
        """
        Ensure that the kubernetes-vpc security group rules are as expected
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
    
    def test_sandbox_vpc_exists(self) -> None:
        """
        Determine if the sandbox-vpc exists
        """
        self.assertTrue(len(VPC.get_vpcs('sandbox-vpc')) == 1)

    def test_sandbox_vpc_configured(self) -> None:
        """
        Determine if the sandbox VPC is configured and available as expected.
        """
        self.assertTrue(VPC.vpc_configured('sandbox-vpc'))

    def test_sandbox_internet_gateway_exists(self) -> None:
        """
        Determine if the sandbox-vpc-internet-gateway exists
        """
        self.assertTrue(len(VPC.get_internet_gateways('sandbox-vpc-internet-gateway')) == 1)

    def test_sandbox_network_acl_exists(self) -> None:
        """
        Determine if the sandbox-acl exists
        """
        self.assertTrue(len(VPC.get_network_acls('sandbox-acl')) == 1)
    
    def test_sandbox_dns_resolver_exists(self) -> None:
        """
        Determine if the sandbox-dhcp-options exists
        """
        self.assertTrue(len(VPC.get_dns_resolvers('sandbox-dhcp-options')) == 1)

    def test_sandbox_sg_valid(self) -> None:
        """
        Ensure that the security group attached to the sandbox-vpc is as expected
        """
        sg = SecurityGroup.get_security_groups('sandbox-vpc-security')[0]
    
        self.assertTrue(all([
            sg.get('GroupName') == 'sandbox-vpc-security',
            self.validate_sandbox_sg_rules(sg.get('IpPermissions'), sg.get('IpPermissionsEgress'))
        ]))
    
    def test_sandbox_fearless_public_subnet_exists(self) -> None:
        """
        Determine if the sandbox-vpc-fearless-public-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('sandbox-vpc-fearless-public-subnet')) == 1)

    def test_sandbox_fearless_public_subnet_configured(self) -> None:
        """
        Determine if the sandbox 'fearless' public Subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('sandbox-vpc')[0]
        subnet = VPC.get_subnets('sandbox-vpc-fearless-public-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1a', '10.0.1.0/24'))
    
    def test_sandbox_fearless_public_subnet_rt_configured(self) -> None:
        """
        Determine if the sandbox 'fearless' public subnet routing table is configured and available as expected.
        """
        vpc = VPC.get_vpcs('sandbox-vpc')[0]
        subnet = VPC.get_subnets('sandbox-vpc-fearless-public-subnet')[0]
        route_table = VPC.get_route_table('sandbox-vpc-public-subnet-rt')[0]
        internet_gateway = VPC.get_internet_gateways('sandbox-vpc-internet-gateway')[0]
    
        self.assertTrue(VPC.route_table_configured(
            route_table,
            vpc.get('VpcId'),
            subnet.get('SubnetId'),
            internet_gateway.get('InternetGatewayId')
        ))

    def test_sandbox_speaknow_public_subnet_exists(self) -> None:
        """
        Determine if the sandbox-vpc-speaknow-public-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('sandbox-vpc-speaknow-public-subnet')) == 1)
    
    def test_sandbox_speaknow_public_subnet_configured(self) -> None:
        """
        Determine if the sandbox 'speaknow' public Subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('sandbox-vpc')[0]
        subnet = VPC.get_subnets('sandbox-vpc-speaknow-public-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1b', '10.0.2.0/24'))

    def test_sandbox_speaknow_public_subnet_rt_configured(self) -> None:
        """
        Determine if the sandbox 'speaknow' public subnet routing table is configured and available as expected.
        """
        vpc = VPC.get_vpcs('sandbox-vpc')[0]
        subnet = VPC.get_subnets('sandbox-vpc-speaknow-public-subnet')[0]
        route_table = VPC.get_route_table('sandbox-vpc-public-subnet-rt')[0]
        internet_gateway = VPC.get_internet_gateways('sandbox-vpc-internet-gateway')[0]
    
        self.assertTrue(VPC.route_table_configured(
            route_table,
            vpc.get('VpcId'),
            subnet.get('SubnetId'),
            internet_gateway.get('InternetGatewayId')
        ))

    """
    Helper methods for the Sandbox VPC
    """
    
    def validate_sandbox_sg_rules(self, ingress: list, egress: list):
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
