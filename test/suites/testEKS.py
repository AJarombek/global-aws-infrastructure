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

from aws_test_functions.EC2 import EC2
from aws_test_functions.VPC import VPC


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
        self.assertEqual('1.22', kubernetes_version)
        self.assertEqual('eks.10', platform_version)
        self.assertEqual('ACTIVE', cluster_status)

    def test_eks_cluster_vpc_subnet(self) -> None:
        """
        Test that the EKS cluster is in the expected cluster and public subnets.
        """
        cluster = self.eks.describe_cluster(name='andrew-jarombek-eks-cluster').get('cluster')
        cluster_vpc: str = cluster.get('resourcesVpcConfig').get('vpcId')
        cluster_subnets: list = cluster.get('resourcesVpcConfig').get('subnetIds')

        kubernetes_vpc = VPC.get_vpcs('application-vpc')
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
        us_east_1_thumbprint = '9e99a48a9960b14926bb7f3b02e22da2b0ab7280'

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
        self.assertEqual(2, len(worker_ec2))

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
