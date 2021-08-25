"""
Unit tests for a file vault S3 bucket.
Author: Andrew Jarombek
Date: 8/16/2021
"""

import unittest
import json
from typing import Dict, Any

import boto3
from boto3_type_annotations.s3 import Client as S3Client
from boto3_type_annotations.sts import Client as STSClient


class TestFileVault(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3: S3Client = boto3.client('s3')
        self.sts: STSClient = boto3.client('sts')

    def test_file_vault_s3_bucket_exists(self) -> None:
        """
        Test if a andrew-jarombek-file-vault S3 bucket exists.
        """
        s3_bucket = self.s3.list_objects(Bucket='andrew-jarombek-file-vault')
        self.assertTrue(s3_bucket.get('Name') == 'andrew-jarombek-file-vault')

    def test_saints_xctf_canaries_s3_bucket_has_policy(self) -> None:
        """
        Test if the andrew-jarombek-file-vault S3 bucket has the expected policy attached to it.
        """
        account_id = self.sts.get_caller_identity().get('Account')

        bucket_policy_response = self.s3.get_bucket_policy(Bucket='andrew-jarombek-file-vault')
        bucket_policy: Dict[str, Any] = json.loads(bucket_policy_response.get('Policy'))

        self.assertEqual(bucket_policy.get('Version'), '2012-10-17')
        self.assertEqual(bucket_policy.get('Id'), 'AndrewJarombekFileVaultPolicy')

        statement: Dict[str, Any] = bucket_policy.get('Statement')[0]
        self.assertEqual(statement.get('Sid'), 'Permissions')
        self.assertEqual(statement.get('Effect'), 'Allow')
        self.assertEqual(statement.get('Principal').get('AWS'), f'arn:aws:iam::{account_id}:root')
        self.assertEqual(statement.get('Action'), 's3:*')
        self.assertEqual(statement.get('Resource'), f"arn:aws:s3:::andrew-jarombek-file-vault/*")

    def test_s3_bucket_contains_expected_objects(self) -> None:
        """
        Test if the andrew-jarombek-file-vault S3 bucket contains the proper objects.
        """
        contents = self.s3.list_objects(Bucket='andrew-jarombek-file-vault').get('Contents')
        self.assertTrue(all([
            len(contents) == 1,
            contents[0].get('Key') == 'github-recovery-codes.txt'
        ]))
