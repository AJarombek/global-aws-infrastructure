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
        self.eks: EKSClient = boto3.client("eks")
        self.iam: IAMClient = boto3.client("iam")
        self.sts: STSClient = boto3.client("sts")
        self.ec2: EC2Client = boto3.client("ec2")

    """
    Test the EKS Cluster
    """

    @unittest.skip("AWS EKS disabled")
    def test_eks_cluster_exists(self) -> None:
        """
        Determine if the EKS cluster exists as expected.
        """
        cluster = self.eks.describe_cluster(name="andrew-jarombek-eks-v2")

        cluster_name = cluster.get("cluster").get("name")
        kubernetes_version = cluster.get("cluster").get("version")
        platform_version = cluster.get("cluster").get("platformVersion")
        cluster_status = cluster.get("cluster").get("status")

        self.assertEqual("andrew-jarombek-eks-v2", cluster_name)
        self.assertEqual("1.29", kubernetes_version)
        self.assertEqual("eks.6", platform_version)
        self.assertEqual("ACTIVE", cluster_status)

    @unittest.skip("AWS EKS disabled")
    def test_eks_cluster_vpc_subnet(self) -> None:
        """
        Test that the EKS cluster is in the expected cluster and public subnets.
        """
        cluster = self.eks.describe_cluster(name="andrew-jarombek-eks-v2").get(
            "cluster"
        )
        cluster_vpc: str = cluster.get("resourcesVpcConfig").get("vpcId")
        cluster_subnets: list = cluster.get("resourcesVpcConfig").get("subnetIds")

        kubernetes_vpc = VPC.get_vpcs("application-vpc")
        self.assertEqual(1, len(kubernetes_vpc))

        self.assertEqual(kubernetes_vpc[0].get("VpcId"), cluster_vpc)

        kubernetes_dotty_subnet = VPC.get_subnets("kubernetes-dotty-public-subnet")
        kubernetes_grandmas_blanket_subnet = VPC.get_subnets(
            "kubernetes-grandmas-blanket-public-subnet"
        )
        self.assertEqual(1, len(kubernetes_dotty_subnet))
        self.assertEqual(1, len(kubernetes_grandmas_blanket_subnet))

        self.assertListEqual(
            [
                kubernetes_dotty_subnet[0].get("SubnetId"),
                kubernetes_grandmas_blanket_subnet[0].get("SubnetId"),
            ],
            cluster_subnets,
        )

    @unittest.skip("AWS EKS disabled")
    def test_cluster_open_id_connect_provider(self):
        """
        Test that an Open ID Connect Provider is used by the cluster.
        """
        cluster = self.eks.describe_cluster(name="andrew-jarombek-eks-v2").get(
            "cluster"
        )
        cluster_oidc_issuer: str = cluster.get("identity").get("oidc").get("issuer")
        cluster_oidc_issuer = cluster_oidc_issuer.replace("https://", "")

        account_id = self.sts.get_caller_identity().get("Account")
        open_id_connect_provider = self.iam.get_open_id_connect_provider(
            OpenIDConnectProviderArn=f"arn:aws:iam::{account_id}:oidc-provider/{cluster_oidc_issuer}"
        )

        self.assertEqual(cluster_oidc_issuer, open_id_connect_provider.get("Url"))
        self.assertListEqual(
            ["sts.amazonaws.com"], open_id_connect_provider.get("ClientIDList")
        )

    @unittest.skip("AWS EKS disabled")
    def test_eks_worker_node_managed_by_eks(self) -> None:
        """
        Test that the worker node has the proper tags to be managed by the EKS cluster.
        """
        response = self.ec2.describe_instances(
            Filters=[{"Name": "tag:Name", "Values": ["eks-prod"]}]
        )
        worker_instances = response.get("Reservations")[0].get("Instances")
        self.assertEqual(1, len(worker_instances))

    @unittest.skip("AWS EKS disabled")
    def test_external_dns_policy(self) -> None:
        """
        Test that the external-dns IAM policy exists in the /kubernetes/ path.
        """
        kubernetes_policies = self.iam.list_policies(PathPrefix="/kubernetes/").get(
            "Policies"
        )
        external_dns_policies = [
            policy
            for policy in kubernetes_policies
            if policy.get("PolicyName") == "external-dns"
        ]
        self.assertEqual(1, len(external_dns_policies))
