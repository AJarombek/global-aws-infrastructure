"""
Functions which represent Unit tests for AWS Systems Manager Parameter Store.
Author: Andrew Jarombek
Date: 12/31/2021
"""

import unittest
from typing import Dict, List, Any

import boto3
from boto3_type_annotations.sts import Client as STSClient
from boto3_type_annotations.ssm import Client as SSMClient
from boto3_type_annotations.kms import Client as KMSClient


class TestLambda(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.sts: STSClient = boto3.client('sts')
        self.ssm: SSMClient = boto3.client('ssm')
        self.kms: KMSClient = boto3.client('kms')

    def test_parameter_store_kms_key_exists(self) -> None:
        """
        Test that a KMS key and its corresponding alias that is used in AWS Systems Manager Parameter Store exists.
        """
        account_id = self.sts.get_caller_identity().get('Account')

        aliases: List[Dict[str, Any]] = self.kms.list_aliases().get('Aliases')
        filtered_aliases = list(
            filter(lambda alias: alias.get('AliasName') == 'alias/parameter-store-kms-key', aliases)
        )
        self.assertEqual(1, len(filtered_aliases))

        alias = filtered_aliases[0]
        key_id = alias.get('TargetKeyId')

        response = self.kms.describe_key(KeyId=key_id)
        key: Dict[str, Any] = response.get('KeyMetadata')
        self.assertEqual(account_id, key.get('AWSAccountId'))
        self.assertEqual('KMS Key for Parameter Store', key.get('Description'))

    def test_aapl_parameter_exists(self) -> None:
        """
        Test that a parameter with codename AAPL exists in AWS Systems Manager Parameter Store.
        """
        response = self.ssm.get_parameter(Name='/external/AAPL', WithDecryption=False)
        parameter: Dict[str, Any] = response.get('Parameter')

        self.assertEqual('/external/AAPL', parameter.get('Name'))
        self.assertEqual('SecureString', parameter.get('Type'))
        self.assertEqual('text', parameter.get('DataType'))

    def test_ally_parameter_exists(self) -> None:
        """
        Test that a parameter with codename ALLY exists in AWS Systems Manager Parameter Store.
        """
        response = self.ssm.get_parameter(Name='/external/ALLY', WithDecryption=False)
        parameter: Dict[str, Any] = response.get('Parameter')

        self.assertEqual('/external/ALLY', parameter.get('Name'))
        self.assertEqual('SecureString', parameter.get('Type'))
        self.assertEqual('text', parameter.get('DataType'))

    def test_coin_parameter_exists(self) -> None:
        """
        Test that a parameter with codename COIN exists in AWS Systems Manager Parameter Store.
        """
        response = self.ssm.get_parameter(Name='/external/COIN', WithDecryption=False)
        parameter: Dict[str, Any] = response.get('Parameter')

        self.assertEqual('/external/COIN', parameter.get('Name'))
        self.assertEqual('SecureString', parameter.get('Type'))
        self.assertEqual('text', parameter.get('DataType'))

    def test_fide_parameter_exists(self) -> None:
        """
        Test that a parameter with codename FIDE exists in AWS Systems Manager Parameter Store.
        """
        response = self.ssm.get_parameter(Name='/external/FIDE', WithDecryption=False)
        parameter: Dict[str, Any] = response.get('Parameter')

        self.assertEqual('/external/FIDE', parameter.get('Name'))
        self.assertEqual('SecureString', parameter.get('Type'))
        self.assertEqual('text', parameter.get('DataType'))

    def test_gemi_parameter_exists(self) -> None:
        """
        Test that a parameter with codename GEMI exists in AWS Systems Manager Parameter Store.
        """
        response = self.ssm.get_parameter(Name='/external/GEMI', WithDecryption=False)
        parameter: Dict[str, Any] = response.get('Parameter')

        self.assertEqual('/external/GEMI', parameter.get('Name'))
        self.assertEqual('SecureString', parameter.get('Type'))
        self.assertEqual('text', parameter.get('DataType'))

    def test_tdam_parameter_exists(self) -> None:
        """
        Test that a parameter with codename TDAM exists in AWS Systems Manager Parameter Store.
        """
        response = self.ssm.get_parameter(Name='/external/TDAM', WithDecryption=False)
        parameter: Dict[str, Any] = response.get('Parameter')

        self.assertEqual('/external/TDAM', parameter.get('Name'))
        self.assertEqual('SecureString', parameter.get('Type'))
        self.assertEqual('text', parameter.get('DataType'))

    def test_vang_parameter_exists(self) -> None:
        """
        Test that a parameter with codename VANG exists in AWS Systems Manager Parameter Store.
        """
        response = self.ssm.get_parameter(Name='/external/VANG', WithDecryption=False)
        parameter: Dict[str, Any] = response.get('Parameter')

        self.assertEqual('/external/VANG', parameter.get('Name'))
        self.assertEqual('SecureString', parameter.get('Type'))
        self.assertEqual('text', parameter.get('DataType'))
