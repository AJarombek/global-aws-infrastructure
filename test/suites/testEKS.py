"""
Unit tests for the EKS cluster.
Author: Andrew Jarombek
Date: 7/2/2020
"""

import unittest
import boto3
from boto3_type_annotations.eks import Client as EKSClient


class TestEKS(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.eks: EKSClient = boto3.client('eks')

    def test_eks_cluster_exists(self) -> None:
        cluster = self.eks.describe_cluster(name='andrew-jarombek-eks-cluster')

        cluster_name = cluster.get('cluster').get('name')
        kubernetes_version = cluster.get('cluster').get('version')
        cluster_status = cluster.get('cluster').get('status')

        self.assertEqual('andrew-jarombek-eks-cluster', cluster_name)
        self.assertEqual('1.16', kubernetes_version)
        self.assertEqual('ACTIVE', cluster_status)
