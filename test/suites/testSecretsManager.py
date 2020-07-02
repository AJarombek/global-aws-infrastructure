"""
Functions which represent unit tests for Secrets Manager.
Author: Andrew Jarombek
Date: 7/1/2020
"""

import unittest
import boto3
from boto3_type_annotations.secretsmanager import Client as SecretsManagerClient

from utils.secretsManager import SecretsManager


class TestSecretsManager(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.secrets_manager: SecretsManagerClient = boto3.client('secretsmanager')

    def test_dockerhub_secret_exists(self):
        """
        Test that the DockerHub credentials exist as expected in Secrets Manager.
        """
        self.assertTrue(SecretsManager.validate_secret(
            secret_id='dockerhub-secret',
            description='DockerHub key for cloning and pushing to repositories'
        ))

    def test_github_secret_exists(self):
        """
        Test that the GitHub credentials exist as expected in Secrets Manager.
        """
        self.assertTrue(SecretsManager.validate_secret(
            secret_id='github-secret',
            description='GitHub key for cloning and pushing to repositories'
        ))

    def test_github_access_token_secret_exists(self):
        """
        Test that the GitHub credentials exist as expected in Secrets Manager.
        """
        self.assertTrue(SecretsManager.validate_secret(
            secret_id='github-access-token',
            description='GitHub access token for using the GitHub API'
        ))

    def test_google_account_secret_exists(self):
        """
        Test that the GitHub credentials exist as expected in Secrets Manager.
        """
        self.assertTrue(SecretsManager.validate_secret(
            secret_id='google-account-secret',
            description='Google Account Credentials'
        ))

    def test_jenkins_secret_exists(self):
        """
        Test that the GitHub credentials exist as expected in Secrets Manager.
        """
        self.assertTrue(SecretsManager.validate_secret(
            secret_id='jenkins-secret',
            description='Jenkins Credentials'
        ))
