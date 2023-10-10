"""
Functions which represent Unit tests for AWS Lambda functions.
Author: Andrew Jarombek
Date: 7/18/2021
"""

import unittest

import boto3
from boto3_type_annotations.lambda_ import Client as LambdaClient
from boto3_type_annotations.events import Client as EventClient

from aws_test_functions.Lambda import Lambda
from aws_test_functions.CloudWatchLogs import CloudWatchLogs


class TestLambda(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.lambda_: LambdaClient = boto3.client("lambda")
        self.events: EventClient = boto3.client("events")

    def test_daily_cost_lambda_function_exists(self) -> None:
        """
        Test that a daily cost AWS Lambda function exists.
        """
        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name="AWSDailyCost",
            handler="lambda.handler",
            runtime="python3.8",
            memory_size=128,
            env_vars=None,
        )

    def test_daily_cost_lambda_function_has_iam_role(self) -> None:
        """
        Test that a daily cost AWS Lambda function has the proper IAM role.
        """
        self.assertTrue(
            Lambda.lambda_function_has_iam_role(
                function_name="AWSDailyCost", role_name="daily-cost-lambda-role"
            )
        )

    def test_daily_cost_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the daily cost AWS Lambda function.
        """
        CloudWatchLogs.cloudwatch_log_group_exists(
            test_case=self, log_group_name="/aws/lambda/AWSDailyCost", retention_days=7
        )

    def test_daily_cost_lambda_cloudwatch_event_rule_exists(self) -> None:
        """
        Test that a CloudWatch event exists for the daily cost AWS Lambda function.
        """
        cloudwatch_event_dict: dict = self.events.describe_rule(
            Name="daily-cost-lambda-rule"
        )

        self.assertTrue(
            all(
                [
                    cloudwatch_event_dict.get("Name") == "daily-cost-lambda-rule",
                    cloudwatch_event_dict.get("ScheduleExpression")
                    == "cron(0 7 * * ? *)",
                ]
            )
        )
