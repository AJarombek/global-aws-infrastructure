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
        self.s3 = boto3.client('s3')

    def test_s3_backup_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for the Terraform backend exists
        """
        s3_bucket = self.s3.list_objects(Bucket='andrew-jarombek-terraform-state')
        self.assertTrue(s3_bucket.get('Name') == 'andrew-jarombek-terraform-state')
