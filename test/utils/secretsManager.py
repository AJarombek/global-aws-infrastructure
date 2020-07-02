"""
Helper functions for Secrets Manager
Author: Andrew Jarombek
Date: 7/1/2020
"""

import boto3
from boto3_type_annotations.secretsmanager import Client as SecretsManagerClient

secrets_manager: SecretsManagerClient = boto3.client('secretsmanager')


class SecretsManager:

    @staticmethod
    def validate_secret(secret_id: str, description: str) -> bool:
        """
        Validate the name and description of a secret that should exist in Secrets Manager.
        :param secret_id: The identifier (name) of the secret.
        :param description: The description attached to the secret.
        :return: True if the validation passes, False otherwise.
        """
        credentials = secrets_manager.describe_secret(SecretId=secret_id)
        return all([
            credentials.get('Name') == secret_id,
            credentials.get('Description') == description,
        ])
