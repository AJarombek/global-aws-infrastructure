"""
Unit tests for the ECS cluster.
Author: Andrew Jarombek
Date: 1/13/2024
"""

import unittest

import boto3
from boto3_type_annotations.ecs import Client as ECSClient
from boto3_type_annotations.sts import Client as STSClient


class TestECS(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ecs: ECSClient = boto3.client("ecs")
        self.sts: STSClient = boto3.client("sts")

    def test_eks_cluster_exists(self) -> None:
        """
        Determine if the EKS cluster exists as expected.
        """
        cluster_name = "andrew-jarombek-ecs-cluster"
        account_id = self.sts.get_caller_identity().get("Account")
        clusters = self.ecs.describe_clusters(clusters=[cluster_name])

        self.assertEqual(1, len(clusters.get("clusters")))

        cluster = clusters.get("clusters")[0]

        self.assertEqual(
            f"arn:aws:ecs:us-east-1:{account_id}:cluster/{cluster_name}",
            cluster.get("clusterArn"),
        )
        self.assertEqual(cluster_name, cluster.get("clusterName"))
