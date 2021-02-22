"""
Unit tests for my AWS accounts SNS topics and subscriptions.
Author: Andrew Jarombek
Date: 2/21/2021
"""

import unittest
from typing import List

import boto3
from boto3_type_annotations.sns import Client as SNSClient
from boto3_type_annotations.sts import Client as STSClient


class TestSNS(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.sns: SNSClient = boto3.client('sns')
        self.sts: STSClient = boto3.client('sts')

    def test_sns_email_topic_exists(self) -> None:
        """
        Determine if an SNS topic exists which sends emails.
        """
        account_id = self.sts.get_caller_identity().get('Account')
        topics = self.sns.list_topics()
        topic_list: List[dict] = topics.get('Topics')
        matching_topics = [
            topic for topic in topic_list
            if topic.get('TopicArn') == f'arn:aws:sns:us-east-1:{account_id}:alert-email-topic'
        ]

        self.assertEqual(1, len(matching_topics))

    def test_sns_email_subscription_exists(self) -> None:
        """
        Determine if an SNS subscription exists which sends emails.
        """
        account_id = self.sts.get_caller_identity().get('Account')
        subscriptions = self.sns.list_subscriptions()
        matching_subscriptions = [
            subscription for subscription
            in subscriptions.get('Subscriptions')
            if subscription.get('Protocol') == 'email'
            and subscription.get('Endpoint') == 'andrew@jarombek.com'
            and subscription.get('TopicArn') == f'arn:aws:sns:us-east-1:{account_id}:alert-email-topic'
        ]

        self.assertEqual(1, len(matching_subscriptions))
