"""
Functions which represent unit tests for VPC peering connections.
Author: Andrew Jarombek
Date: 9/15/2020
"""

import unittest
import boto3
from typing import List
from boto3_type_annotations.ec2 import Client as EC2Client


class TestVPCPeering(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ec2: EC2Client = boto3.client('ec2')

    def test_saints_xctf_kubernetes_connection(self):
        """
        Test that a VPC peering connection exists between the SaintsXCTF VPC and the Kubernetes VPC.
        """
        result = self.ec2.describe_vpc_peering_connections(
            Filters=[
                {
                    'Name': 'tag:VPC1',
                    'Values': ['saints-xctf-com-vpc']
                },
                {
                    'Name': 'tag:VPC2',
                    'Values': ['kubernetes-vpc']
                }
            ]
        )
        connections: List[dict] = result.get('VpcPeeringConnections')
        self.assertEqual(1, len(connections))
        self.assertEqual('active', connections[0].get('Status').get('Code'))
