"""
Functions which represent Unit tests for the saints-xctf-com vpc infrastructure
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest
import boto3
from test.utils.vpc import VPC
from test.utils.securityGroup import SecurityGroup


class TestSaintsxctfComApp(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ec2 = boto3.resource('ec2')

    def test_saintsxctf_com_vpc_exists(self) -> None:
        """
        Determine if the saints-xctf-com-vpc exists
        """
        self.assertTrue(len(VPC.get_vpcs('saints-xctf-com-vpc')) == 1)

    def test_saintsxctf_com_vpc_configured(self) -> None:
        """
        Determine if the saints-xctf-com-vpc is configured and available as expected.
        """
        self.assertTrue(VPC.vpc_configured('saints-xctf-com-vpc'))

    def test_saintsxctf_com_internet_gateway_exists(self) -> None:
        """
        Determine if the saints-xctf-com-vpc-internet-gateway exists
        """
        self.assertTrue(len(VPC.get_internet_gateways('saints-xctf-com-vpc-internet-gateway')) == 1)

    def test_saintsxctf_com_network_acl_exists(self) -> None:
        """
        Determine if the saints-xctf-com-acl exists
        """
        self.assertTrue(len(VPC.get_network_acls('saints-xctf-com-acl')) == 1)

    def test_saintsxctf_com_dns_resolver_exists(self) -> None:
        """
        Determine if the saints-xctf-com-dhcp-options exists
        """
        self.assertTrue(len(VPC.get_dns_resolvers('saints-xctf-com-dhcp-options')) == 1)

    def test_saintsxctf_com_sg_valid(self) -> None:
        """
        Ensure that the security group attached to the saints-xctf-com-vpc is as expected
        """
        sg = SecurityGroup.get_security_groups('saints-xctf-com-vpc-security')[0]
    
        self.assertTrue(all([
            sg.get('GroupName') == 'saints-xctf-com-vpc-security',
            self.validate_saintsxctf_com_sg_rules(sg.get('IpPermissions'), sg.get('IpPermissionsEgress'))
        ]))

    def test_saintsxctf_com_lisag_public_subnet_exists(self) -> None:
        """
        Determine if the saints-xctf-com-lisag-public-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('saints-xctf-com-lisag-public-subnet')) == 1)

    def test_saintsxctf_com_lisag_public_subnet_configured(self) -> None:
        """
        Determine if the saints-xctf-com-lisag-public-subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('saints-xctf-com-vpc')[0]
        subnet = VPC.get_subnets('saints-xctf-com-lisag-public-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1b', '10.0.1.0/24'))

    def test_saintsxctf_com_lisag_public_subnet_rt_configured(self) -> None:
        """
        Determine if the saints-xctf-com-lisag-public-subnet routing table is configured and available as expected.
        """
        vpc = VPC.get_vpcs('saints-xctf-com-vpc')[0]
        subnet = VPC.get_subnets('saints-xctf-com-lisag-public-subnet')[0]
        route_table = VPC.get_route_table('saints-xctf-com-vpc-public-subnet-rt')[0]
        internet_gateway = VPC.get_internet_gateways('saints-xctf-com-vpc-internet-gateway')[0]
    
        self.assertTrue(VPC.route_table_configured(
            route_table,
            vpc.get('VpcId'),
            subnet.get('SubnetId'),
            internet_gateway.get('InternetGatewayId')
        ))

    def test_saintsxctf_com_megank_public_subnet_exists(self) -> None:
        """
        Determine if the saints-xctf-com-megank-public-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('saints-xctf-com-megank-public-subnet')) == 1)

    def test_saintsxctf_com_megank_public_subnet_configured(self) -> None:
        """
        Determine if the saints-xctf-com-megank-public-subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('saints-xctf-com-vpc')[0]
        subnet = VPC.get_subnets('saints-xctf-com-megank-public-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1d', '10.0.2.0/24'))

    def test_saintsxctf_com_megank_public_subnet_rt_configured(self) -> None:
        """
        Determine if the saints-xctf-com-megank-public-subnet routing table is configured and available as expected.
        """
        vpc = VPC.get_vpcs('saints-xctf-com-vpc')[0]
        subnet = VPC.get_subnets('saints-xctf-com-megank-public-subnet')[0]
        route_table = VPC.get_route_table('saints-xctf-com-vpc-public-subnet-rt')[0]
        internet_gateway = VPC.get_internet_gateways('saints-xctf-com-vpc-internet-gateway')[0]
    
        self.assertTrue(VPC.route_table_configured(
            route_table,
            vpc.get('VpcId'),
            subnet.get('SubnetId'),
            internet_gateway.get('InternetGatewayId')
        ))

    def test_saintsxctf_com_cassiah_private_subnet_exists(self) -> None:
        """
        Determine if the saints-xctf-com-cassiah-private-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('saints-xctf-com-cassiah-private-subnet')) == 1)

    def test_saintsxctf_com_cassiah_private_subnet_configured(self) -> None:
        """
        Determine if the saint-sxctf-com-cassiah-private-subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('saints-xctf-com-vpc')[0]
        subnet = VPC.get_subnets('saints-xctf-com-cassiah-private-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1e', '10.0.3.0/24'))

    def test_saintsxctf_com_carolined_private_subnet_exists(self) -> None:
        """
        Determine if the saints-xctf-com-carolined-private-subnet exists
        """
        self.assertTrue(len(VPC.get_subnets('saints-xctf-com-carolined-private-subnet')) == 1)

    def test_saintsxctf_com_carolined_private_subnet_configured(self) -> None:
        """
        Determine if the saint-sxctf-com-carolined-private-subnet is configured and available as expected.
        """
        vpc = VPC.get_vpcs('saints-xctf-com-vpc')[0]
        subnet = VPC.get_subnets('saints-xctf-com-carolined-private-subnet')[0]
    
        self.assertTrue(VPC.subnet_configured(vpc, subnet, 'us-east-1c', '10.0.4.0/24'))

    """
    Helper methods for the saintsxctf-com VPC
    """
    
    def validate_saintsxctf_com_sg_rules(self, ingress: list, egress: list):
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
