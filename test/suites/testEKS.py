"""
Unit tests for the EKS cluster.
Author: Andrew Jarombek
Date: 7/2/2020
"""

import unittest
import boto3
from boto3_type_annotations.eks import Client as EKSClient
from boto3_type_annotations.iam import Client as IAMClient
from boto3_type_annotations.sts import Client as STSClient
from boto3_type_annotations.ec2 import Client as EC2Client

from utils.ec2 import EC2
from utils.vpc import VPC
from utils.securityGroup import SecurityGroup


class TestEKS(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.eks: EKSClient = boto3.client('eks')
        self.iam: IAMClient = boto3.client('iam')
        self.sts: STSClient = boto3.client('sts')
        self.ec2: EC2Client = boto3.client('ec2')

    """
    Test the EKS Cluster
    """

    def test_eks_cluster_exists(self) -> None:
        """
        Determine if the EKS cluster exists as expected.
        """
        cluster = self.eks.describe_cluster(name='andrew-jarombek-eks-cluster')

        cluster_name = cluster.get('cluster').get('name')
        kubernetes_version = cluster.get('cluster').get('version')
        platform_version = cluster.get('cluster').get('platformVersion')
        cluster_status = cluster.get('cluster').get('status')

        self.assertEqual('andrew-jarombek-eks-cluster', cluster_name)
        self.assertEqual('1.16', kubernetes_version)
        self.assertEqual('eks.1', platform_version)
        self.assertEqual('ACTIVE', cluster_status)

    def test_eks_cluster_vpc_subnet(self) -> None:
        """
        Test that the EKS cluster is in the expected cluster and public subnets.
        """
        cluster = self.eks.describe_cluster(name='andrew-jarombek-eks-cluster').get('cluster')
        cluster_vpc: str = cluster.get('resourcesVpcConfig').get('vpcId')
        cluster_subnets: list = cluster.get('resourcesVpcConfig').get('subnetIds')

        kubernetes_vpc = VPC.get_vpcs('kubernetes-vpc')
        self.assertEqual(1, len(kubernetes_vpc))

        self.assertEqual(kubernetes_vpc[0].get('VpcId'), cluster_vpc)

        kubernetes_dotty_subnet = VPC.get_subnets('kubernetes-dotty-public-subnet')
        kubernetes_grandmas_blanket_subnet = VPC.get_subnets('kubernetes-grandmas-blanket-public-subnet')
        self.assertEqual(1, len(kubernetes_dotty_subnet))
        self.assertEqual(1, len(kubernetes_grandmas_blanket_subnet))

        self.assertListEqual(
            [kubernetes_dotty_subnet[0].get('SubnetId'), kubernetes_grandmas_blanket_subnet[0].get('SubnetId')],
            cluster_subnets
        )

    def test_cluster_open_id_connect_provider(self):
        """
        Test that an Open ID Connect Provider is used by the cluster.
        """
        cluster = self.eks.describe_cluster(name='andrew-jarombek-eks-cluster').get('cluster')
        cluster_oidc_issuer: str = cluster.get('identity').get('oidc').get('issuer')
        cluster_oidc_issuer = cluster_oidc_issuer.replace('https://', '')

        account_id = self.sts.get_caller_identity().get('Account')
        us_east_1_thumbprint = '598adecb9a3e6cc70aa53d64bd5ee4704300382a'

        open_id_connect_provider = self.iam.get_open_id_connect_provider(
            OpenIDConnectProviderArn=f'arn:aws:iam::{account_id}:oidc-provider/{cluster_oidc_issuer}'
        )

        self.assertEqual(cluster_oidc_issuer, open_id_connect_provider.get('Url'))
        self.assertListEqual(['sts.amazonaws.com'], open_id_connect_provider.get('ClientIDList'))
        self.assertListEqual([us_east_1_thumbprint], open_id_connect_provider.get('ThumbprintList'))

    def test_alb_ingress_controller_role_exists(self) -> None:
        """
        Test that the aws-alb-ingress-controller IAM Role exists
        """
        role_dict = self.iam.get_role(RoleName='aws-alb-ingress-controller')
        role = role_dict.get('Role')
        self.assertTrue(role.get('Path') == '/kubernetes/' and role.get('RoleName') == 'aws-alb-ingress-controller')

    def test_alb_ingress_controller_policy_attached(self) -> None:
        """
        Test that the aws-alb-ingress-controller IAM policy is attached to the aws-alb-ingress-controller IAM role.
        """
        policy_response = self.iam.list_attached_role_policies(RoleName='aws-alb-ingress-controller')
        policies = policy_response.get('AttachedPolicies')
        admin_policy = policies[0]
        self.assertTrue(len(policies) == 1 and admin_policy.get('PolicyName') == 'aws-alb-ingress-controller')

    def test_eks_worker_node_running(self) -> None:
        """
        Ensure that the EKS worker node EC2 instance is in a running state.
        """
        worker_ec2 = EC2.get_ec2(name='andrew-jarombek-eks-cluster-0-eks_asg')
        self.assertEqual(1, len(worker_ec2))

    def test_eks_worker_node_managed_by_eks(self) -> None:
        """
        Test that the worker node has the proper tags to be managed by the EKS cluster.
        """
        response = self.ec2.describe_instances(Filters=[
            {
                'Name': 'tag:Name',
                'Values': ['andrew-jarombek-eks-cluster-0-eks_asg']
            },
            {
                'Name': 'tag:k8s.io/cluster/andrew-jarombek-eks-cluster',
                'Values': ['owned']
            },
            {
                'Name': 'tag:kubernetes.io/cluster/andrew-jarombek-eks-cluster',
                'Values': ['owned']
            }
        ])
        worker_instances = response.get('Reservations')[0].get('Instances')
        self.assertEqual(1, len(worker_instances))

    def test_external_dns_policy(self) -> None:
        """
        Test that the external-dns IAM policy exists in the /kubernetes/ path.
        """
        kubernetes_policies = self.iam.list_policies(PathPrefix='/kubernetes/').get('Policies')
        external_dns_policies = [policy for policy in kubernetes_policies if policy.get('PolicyName') == 'external-dns']
        self.assertEqual(1, len(external_dns_policies))

    def test_worker_pods_policy(self) -> None:
        """
        Test that the worker-pods IAM policy exists in the /kubernetes/ path.
        """
        kubernetes_policies = self.iam.list_policies(PathPrefix='/kubernetes/').get('Policies')
        worker_pods_policies = [policy for policy in kubernetes_policies if policy.get('PolicyName') == 'worker-pods']
        self.assertEqual(1, len(worker_pods_policies))

    """
    Test the Kubernetes VPC
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
            self.validate_kubernetes_sg_rules(sg.get('IpPermissions'), sg.get('IpPermissionsEgress'))
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

    def test_kubernetes_dotty_public_subnet_rt_configured(self) -> None:
        """
        Determine if the kubernetes dotty public subnet routing table is configured and available as expected.
        """
        vpc = VPC.get_vpcs('kubernetes-vpc')[0]
        subnet = VPC.get_subnets('kubernetes-dotty-public-subnet')[0]
        route_table = VPC.get_route_table('kubernetes-vpc-public-subnet-rt')[0]
        internet_gateway = VPC.get_internet_gateways('kubernetes-vpc-internet-gateway')[0]

        self.assertTrue(VPC.route_table_configured(
            route_table,
            vpc.get('VpcId'),
            subnet.get('SubnetId'),
            internet_gateway.get('InternetGatewayId')
        ))

    def test_kubernetes_grandmas_blanket_public_subnet_rt_configured(self) -> None:
        """
        Determine if the kubernetes grandmas blanket public subnet routing table is configured and available as expected.
        """
        vpc = VPC.get_vpcs('kubernetes-vpc')[0]
        subnet = VPC.get_subnets('kubernetes-grandmas-blanket-public-subnet')[0]
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
