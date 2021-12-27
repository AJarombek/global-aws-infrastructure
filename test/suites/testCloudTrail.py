"""
Unit tests for my AWS accounts CloudTrail configuration.
Author: Andrew Jarombek
Date: 2/9/2021
"""

import unittest

import boto3
from boto3_type_annotations.cloudtrail import Client as CloudTrailClient
from boto3_type_annotations.s3 import Client as S3Client


class TestCloudTrail(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.cloud_trail: CloudTrailClient = boto3.client('cloudtrail')
        self.s3: S3Client = boto3.client('s3')

    @unittest.skip('CloudTrail not currently enabled.')
    def test_cloud_trail_exists(self) -> None:
        """
        Determine if the AWS CloudTrail trail exists as expected.
        """
        cloud_trail_info: dict = self.cloud_trail.get_trail(Name='andrew-jarombek-cloudtrail')
        trail = cloud_trail_info.get('Trail')
        self.assertEqual(trail.get('Name'), 'andrew-jarombek-cloudtrail')
        self.assertEqual(trail.get('S3BucketName'), 'andrew-jarombek-cloud-trail')

    @unittest.skip('CloudTrail not currently enabled.')
    def test_s3_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for andrew-jarombek-cloud-trail exists
        """
        s3_bucket = self.s3.list_objects(Bucket='andrew-jarombek-cloud-trail')
        return s3_bucket.get('Name') == 'andrew-jarombek-cloud-trail'

    @unittest.skip('CloudTrail not currently enabled.')
    def test_s3_bucket_public_access(self) -> None:
        """
        Test whether the public access configuration for a andrew-jarombek-cloud-trail S3 bucket is correct
        """
        public_access_block = self.s3.get_public_access_block(Bucket='andrew-jarombek-cloud-trail')
        config = public_access_block.get('PublicAccessBlockConfiguration')
        self.assertTrue(config.get('BlockPublicAcls'))
        self.assertTrue(config.get('IgnorePublicAcls'))
        self.assertTrue(config.get('BlockPublicPolicy'))
        self.assertTrue(config.get('RestrictPublicBuckets'))
