"""
Unit tests for my AWS accounts CloudTrail configuration.
Author: Andrew Jarombek
Date: 2/9/2021
"""

import unittest

import boto3
from boto3_type_annotations.cloudtrail import Client as CloudTrailClient


class TestCloudTrail(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.cloud_trail: CloudTrailClient = boto3.client('cloudtrail')

    def test_cloud_trail_exists(self) -> None:
        """
        Determine if the AWS CloudTrail trail exists as expected.
        """
        cloud_trail_info: dict = self.cloud_trail.get_trail(Name='andrew-jarombek-cloudtrail')
        trail = cloud_trail_info.get('Trail')
        self.assertEqual(trail.get('Name'), 'andrew-jarombek-cloudtrail')
        self.assertEqual(trail.get('S3BucketName'), 'andrew-jarombek-cloud-trail')
