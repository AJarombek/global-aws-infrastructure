"""
Functions which represent Unit tests for the S3 backend infrastructure for Terraform
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest

import boto3


class TestBackend(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3 = boto3.client("s3")

    def test_s3_backup_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for the Terraform backend exists
        """
        s3_bucket = self.s3.list_objects(Bucket="andrew-jarombek-terraform-state")
        self.assertTrue(s3_bucket.get("Name") == "andrew-jarombek-terraform-state")

    def test_s3_bucket_public_access(self) -> None:
        """
        Test whether the public access configuration for a andrew-jarombek-terraform-state S3 bucket is correct
        """
        public_access_block = self.s3.get_public_access_block(
            Bucket="andrew-jarombek-terraform-state"
        )
        config = public_access_block.get("PublicAccessBlockConfiguration")
        self.assertTrue(config.get("BlockPublicAcls"))
        self.assertTrue(config.get("IgnorePublicAcls"))
        self.assertTrue(config.get("BlockPublicPolicy"))
        self.assertTrue(config.get("RestrictPublicBuckets"))
