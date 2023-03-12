"""
Unit tests for my AWS Config infrastructure.
Author: Andrew Jarombek
Date: 3/11/2023
"""

import unittest
from typing import Dict, Any

import boto3
from boto3_type_annotations.config import Client as ConfigClient
from boto3_type_annotations.s3 import Client as S3Client
from boto3_type_annotations.iam import Client as IAMClient


class TestConfig(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.config: ConfigClient = boto3.client('config')
        self.s3: S3Client = boto3.client('s3')
        self.iam: IAMClient = boto3.client('iam')
        self.terraform_tag = "global-aws-infrastructure/config"

    def test_config_configuration_recorder_exists(self) -> None:
        """
        Determine if the AWS Config configuration recorder exists as expected.
        """
        configuration_recorders_info: dict = self.config.describe_configuration_recorders(
            ConfigurationRecorderNames=["jarombek"]
        )
        configuration_recorders = configuration_recorders_info.get('ConfigurationRecorders')
        self.assertEqual(1, len(configuration_recorders))

        configuration_recorder = configuration_recorders[0]
        self.assertEqual("jarombek", configuration_recorder.get('name'))

        recording_group: Dict[str, Any] = configuration_recorder.get('recordingGroup')
        self.assertFalse(recording_group.get('allSupported'))
        self.assertFalse(recording_group.get('includeGlobalResourceTypes'))

        self.assertListEqual(
            [
                'AWS::ApiGateway::RestApi',
                'AWS::ApiGateway::Stage',
                'AWS::ApiGatewayV2::Api',
                'AWS::ApiGatewayV2::Stage',
                'AWS::AutoScaling::AutoScalingGroup',
                'AWS::AutoScaling::LaunchConfiguration',
                'AWS::DynamoDB::Table',
                'AWS::EC2::Instance',
                'AWS::EC2::InternetGateway',
                'AWS::EC2::NetworkAcl',
                'AWS::EC2::NetworkInterface',
                'AWS::EC2::RouteTable',
                'AWS::EC2::SecurityGroup',
                'AWS::EC2::Subnet',
                'AWS::EC2::VPC',
                'AWS::EC2::VPCEndpoint',
                'AWS::ECR::PublicRepository',
                'AWS::ECR::Repository',
                'AWS::ElasticLoadBalancing::LoadBalancer',
                'AWS::ElasticLoadBalancingV2::Listener',
                'AWS::IAM::Policy',
                'AWS::IAM::Role',
                'AWS::KMS::Key',
                'AWS::Lambda::Function',
                'AWS::RDS::DBInstance',
                'AWS::Route53::HostedZone',
                'AWS::S3::AccountPublicAccessBlock',
                'AWS::S3::Bucket',
                'AWS::SNS::Topic',
                'AWS::SQS::Queue',
                'AWS::SecretsManager::Secret'
            ],
            sorted(recording_group.get('resourceTypes'))
        )

    def test_config_configuration_recorder_enabled(self) -> None:
        """
        Determine if the AWS Config configuration recorder is enabled.
        """
        configuration_recorders_info: dict = self.config.describe_configuration_recorder_status(
            ConfigurationRecorderNames=["jarombek"]
        )
        configuration_recorders = configuration_recorders_info.get('ConfigurationRecordersStatus')
        self.assertEqual(1, len(configuration_recorders))

        configuration_recorder = configuration_recorders[0]
        self.assertEqual("jarombek", configuration_recorder.get('name'))
        self.assertTrue(configuration_recorder.get('recording'))
        self.assertEqual("SUCCESS", configuration_recorder.get('lastStatus'))

    def test_config_delivery_channel_exists(self) -> None:
        """
        Determine if the AWS Config delivery channel exists as expected.
        """
        delivery_channels_info: dict = self.config.describe_delivery_channels(
            DeliveryChannelNames=["aws-config-jarombek"]
        )
        delivery_channels = delivery_channels_info.get("DeliveryChannels")
        self.assertEqual(1, len(delivery_channels))

        delivery_channel = delivery_channels[0]
        self.assertEqual("aws-config-jarombek", delivery_channel.get('name'))
        self.assertEqual("aws-config-jarombek", delivery_channel.get('s3BucketName'))

    def test_aws_config_jarombek_role_exists(self) -> None:
        """
        Test that the aws-config-jarombek IAM Role exists
        """
        role_dict = self.iam.get_role(RoleName='aws-config-jarombek')
        role = role_dict.get('Role')
        self.assertEqual('aws-config-jarombek', role.get('RoleName'))
        self.assertEqual('/', role.get('Path'))

    def test_aws_config_role_policy_attached(self) -> None:
        """
        Test that the AWS_ConfigRole policy is attached to the aws-config-jarombek role
        """
        policy_response = self.iam.list_attached_role_policies(RoleName='aws-config-jarombek')
        policies = sorted(policy_response.get('AttachedPolicies'), key=lambda x: x.get('PolicyName'))

        self.assertEqual(1, len(policies))
        self.assertEqual('AWS_ConfigRole', policies[0].get('PolicyName'))

    def test_s3_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for aws-config-jarombek exists
        """
        s3_bucket = self.s3.list_objects(Bucket='aws-config-jarombek')
        return s3_bucket.get('Name') == 'aws-config-jarombek'

    def test_s3_bucket_properly_tagged(self) -> None:
        """
        Test if the S3 bucket aws-config-jarombek has proper tags
        """
        s3_bucket = self.s3.get_bucket_tagging(Bucket='aws-config-jarombek')
        tags = s3_bucket.get('TagSet')

        self.assertEqual(1, len(tags))
        tag = tags[0]

        self.assertEqual("Terraform", tag.get("Key"))
        self.assertEqual(self.terraform_tag, tag.get("Value"))

    def test_aws_config_jarombek_role_properly_tagged(self) -> None:
        """
        Test that the aws-config-jarombek IAM role has proper tags
        """
        role_dict = self.iam.get_role(RoleName='aws-config-jarombek')
        tags = role_dict.get('Role').get('Tags')

        self.assertEqual(1, len(tags))
        tag = tags[0]

        self.assertEqual("Terraform", tag.get("Key"))
        self.assertEqual(self.terraform_tag, tag.get("Value"))
