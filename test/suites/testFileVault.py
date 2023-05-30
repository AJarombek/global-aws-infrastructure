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

        self.bucket_name = 'andrew-jarombek-file-vault'

    def test_file_vault_s3_bucket_exists(self) -> None:
        """
        Test if a andrew-jarombek-file-vault S3 bucket exists.
        """
        s3_bucket = self.s3.list_objects(Bucket=self.bucket_name)
        self.assertTrue(s3_bucket.get('Name') == self.bucket_name)

    def test_file_vault_s3_bucket_public_access(self) -> None:
        """
        Test whether the public access configuration for a andrew-jarombek-file-vault S3 bucket is correct
        """
        public_access_block = self.s3.get_public_access_block(Bucket=self.bucket_name)
        config = public_access_block.get('PublicAccessBlockConfiguration')
        self.assertTrue(config.get('BlockPublicAcls'))
        self.assertTrue(config.get('IgnorePublicAcls'))
        self.assertTrue(config.get('BlockPublicPolicy'))
        self.assertTrue(config.get('RestrictPublicBuckets'))

    def test_file_vault_s3_bucket_has_policy(self) -> None:
        """
        Test if the andrew-jarombek-file-vault S3 bucket has the expected policy attached to it.
        """
        account_id = self.sts.get_caller_identity().get('Account')

        bucket_policy_response = self.s3.get_bucket_policy(Bucket=self.bucket_name)
        bucket_policy: Dict[str, Any] = json.loads(bucket_policy_response.get('Policy'))

        self.assertEqual(bucket_policy.get('Version'), '2012-10-17')
        self.assertEqual(bucket_policy.get('Id'), 'AndrewJarombekFileVaultPolicy')

        statement: Dict[str, Any] = bucket_policy.get('Statement')[0]
        self.assertEqual(statement.get('Sid'), 'Permissions')
        self.assertEqual(statement.get('Effect'), 'Allow')
        self.assertEqual(statement.get('Principal').get('AWS'), f'arn:aws:iam::{account_id}:root')
        self.assertEqual(statement.get('Action'), 's3:*')
        self.assertEqual(statement.get('Resource'), f"arn:aws:s3:::{self.bucket_name}/*")

    def test_s3_bucket_contains_expected_objects(self) -> None:
        """
        Test if the andrew-jarombek-file-vault S3 bucket contains the proper objects.
        """
        contents = self.s3.list_objects(Bucket=self.bucket_name).get('Contents')
        self.assertEqual(3, len(contents))
        self.assertEqual('github-recovery-codes.txt', contents[0].get('Key'))
        self.assertEqual('jetbrains-account-recovery-codes.txt', contents[1].get('Key'))
        self.assertEqual('kubeconfig_andrew-jarombek-eks-cluster', contents[2].get('Key'))
