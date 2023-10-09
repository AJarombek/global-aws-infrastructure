"""
Unit tests for my AWS accounts SNS topics and subscriptions.
Author: Andrew Jarombek
Date: 2/21/2021
"""

import unittest
import json
from typing import List, Dict, Any

import boto3
from boto3_type_annotations.sns import Client as SNSClient
from boto3_type_annotations.sts import Client as STSClient


class TestSNS(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.sns: SNSClient = boto3.client("sns")
        self.sts: STSClient = boto3.client("sts")

    def get_sns_topics(self, topic_name: str) -> List[Dict[str, Any]]:
        """
        Get a list of SNS topics that have a given name.
        :param topic_name: The name of the SNS topic.
        """
        account_id = self.sts.get_caller_identity().get("Account")
        topics = self.sns.list_topics()
        topic_list: List[dict] = topics.get("Topics")
        return [
            topic
            for topic in topic_list
            if topic.get("TopicArn")
            == f"arn:aws:sns:us-east-1:{account_id}:{topic_name}"
        ]

    def test_sns_sms_preferences(self) -> None:
        """
        Determine if SNS has the proper SMS preferences.
        """
        response = self.sns.get_sms_attributes(
            attributes=["MonthlySpendLimit", "DefaultSenderID", "DefaultSMSType"]
        )

        sms_attributes: Dict[str, str] = response.get("attributes")
        self.assertEqual("Promotional", sms_attributes.get("DefaultSMSType"))
        self.assertEqual("JarombekAWS", sms_attributes.get("DefaultSenderID"))
        self.assertEqual("1", sms_attributes.get("MonthlySpendLimit"))

    def test_sns_email_topic_exists(self) -> None:
        """
        Determine if an SNS topic exists which sends emails.
        """
        matching_topics = self.get_sns_topics("alert-email-topic")
        self.assertEqual(1, len(matching_topics))

    def test_sns_email_subscription_exists(self) -> None:
        """
        Determine if an SNS subscription exists which sends emails.
        """
        account_id = self.sts.get_caller_identity().get("Account")
        subscriptions = self.sns.list_subscriptions()
        matching_subscriptions = [
            subscription
            for subscription in subscriptions.get("Subscriptions")
            if subscription.get("Protocol") == "email"
            and subscription.get("Endpoint") == "andrew@jarombek.com"
            and subscription.get("TopicArn")
            == f"arn:aws:sns:us-east-1:{account_id}:alert-email-topic"
        ]

        self.assertEqual(1, len(matching_subscriptions))

    def test_sns_email_policy_exists(self) -> None:
        """
        Determine if an SNS topic for sending emails exists with a proper policy attached.
        """
        matching_topics = self.get_sns_topics("alert-email-topic")
        self.assertEqual(1, len(matching_topics))
        topic = matching_topics[0]
        topic_arn = topic.get("TopicArn")

        topic_attributes = self.sns.get_topic_attributes(TopicArn=topic_arn)
        topic_policy_str = topic_attributes.get("Attributes").get("Policy")
        topic_policy: Dict[str, Any] = json.loads(topic_policy_str)

        # 4 Mile Race in Central Park Sat AM, then up to NH to visit Joe.
        # You are in my thoughts.

        self.assertEqual(topic_policy.get("Version"), "2012-10-17")

        statement: Dict[str, Any] = topic_policy.get("Statement")[0]
        self.assertEqual(statement.get("Sid"), "PublishEventsToEmailTopic")
        self.assertEqual(statement.get("Effect"), "Allow")
        self.assertEqual(
            statement.get("Principal").get("Service"), "events.amazonaws.com"
        )
        self.assertEqual(statement.get("Action"), "sns:Publish")
        self.assertEqual(
            statement.get("Resource"),
            f"arn:aws:sns:us-east-1:{self.sts.get_caller_identity().get('Account')}:alert-email-topic",
        )

    def test_sns_sms_topic_exists(self) -> None:
        """
        Determine if an SNS topic exists which sends text messages.
        """
        matching_topics = self.get_sns_topics("alert-sms-topic")
        self.assertEqual(1, len(matching_topics))

    def test_sns_sms_subscription_exists(self) -> None:
        """
        Determine if an SNS subscription exists which sends text messages.
        """
        account_id = self.sts.get_caller_identity().get("Account")
        matching_topics = self.get_sns_topics("alert-sms-topic")
        topic_arn = matching_topics[0].get("TopicArn")

        subscriptions = self.sns.list_subscriptions_by_topic(TopicArn=topic_arn)
        matching_subscriptions = [
            subscription
            for subscription in subscriptions.get("Subscriptions")
            if subscription.get("Protocol") == "sms"
            and subscription.get("Endpoint") == "+2035508738"
            and subscription.get("TopicArn").startswith(
                f"arn:aws:sns:us-east-1:{account_id}:alert-sms-topic"
            )
        ]

        self.assertEqual(1, len(matching_subscriptions))

    def test_sns_sms_policy_exists(self) -> None:
        """
        Determine if an SNS topic for sending text messages exists with a proper policy attached.
        """
        matching_topics = self.get_sns_topics("alert-sms-topic")
        self.assertEqual(1, len(matching_topics))
        topic = matching_topics[0]
        topic_arn = topic.get("TopicArn")

        topic_attributes = self.sns.get_topic_attributes(TopicArn=topic_arn)
        topic_policy_str = topic_attributes.get("Attributes").get("Policy")
        topic_policy: Dict[str, Any] = json.loads(topic_policy_str)

        self.assertEqual(topic_policy.get("Version"), "2012-10-17")

        statement: Dict[str, Any] = topic_policy.get("Statement")[0]
        self.assertEqual(statement.get("Sid"), "PublishEventsToSMSTopic")
        self.assertEqual(statement.get("Effect"), "Allow")
        self.assertEqual(
            statement.get("Principal").get("Service"), "events.amazonaws.com"
        )
        self.assertEqual(statement.get("Action"), "sns:Publish")
        self.assertEqual(
            statement.get("Resource"),
            f"arn:aws:sns:us-east-1:{self.sts.get_caller_identity().get('Account')}:alert-sms-topic",
        )
