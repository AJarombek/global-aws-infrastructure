"""
Unit tests for my AWS accounts Cost Management budget configuration.
Author: Andrew Jarombek
Date: 2/10/2021
"""

import unittest

import boto3
from boto3_type_annotations.budgets import Client as BudgetsClient
from boto3_type_annotations.sts import Client as STSClient


class TestCloudTrail(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.budgets: BudgetsClient = boto3.client('budgets')
        self.sts: STSClient = boto3.client('sts')

    def test_budget_exists(self) -> None:
        """
        Determine if an AWS Cost Management budget exists as expected.
        """
        account_id = self.sts.get_caller_identity().get('Account')
        budget: dict = self.budgets\
            .describe_budget(AccountId=account_id, BudgetName='Andrew Jarombek AWS Budget')\
            .get('Budget')

        self.assertEqual('Andrew Jarombek AWS Budget', budget.get('BudgetName'))
        self.assertEqual('325.0', budget.get('BudgetLimit').get('Amount'))
        self.assertEqual('USD', budget.get('BudgetLimit').get('Unit'))
        self.assertEqual('MONTHLY', budget.get('TimeUnit'))
        self.assertEqual('COST', budget.get('BudgetType'))
