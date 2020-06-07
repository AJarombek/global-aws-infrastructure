"""
Build and push a configured Jenkins Docker image to Amazon ECR.
Author: Andrew Jarombek
Date: 6/6/2020
"""

import json
import subprocess

import boto3
from boto3_type_annotations.secretsmanager import Client as SecretsManagerClient
from boto3_type_annotations.sts import Client as STSClient


def main():
    """
    Build a Jenkins image with secrets from AWS.
    """
    secretsmanager: SecretsManagerClient = boto3.client('secretsmanager')

    private_key = get_github_key(secretsmanager)
    account_id = get_account_id()
    jenkins_password = get_jenkins_password(secretsmanager)
    google_account_password = get_google_account_password(secretsmanager)

    with open("jenkins-template.yaml", "r+") as file:
        jenkins_config: str = file.read()

    # Format the private_key into a single line string.
    formatted_private_key = "\""
    for line in private_key.split('\n'):
        formatted_private_key += f"{line}\\n"

    formatted_private_key += "\""

    jenkins_config = jenkins_config.replace("${SSH_PRIVATE_KEY}", formatted_private_key)
    jenkins_config = jenkins_config.replace("${JENKINS_PASSWORD}", jenkins_password)
    jenkins_config = jenkins_config.replace("${GOOGLE_ACCOUNT_PASSWORD}", google_account_password)

    with open("jenkins.yaml", "w") as file:
        file.write(jenkins_config)

    subprocess.call(["./prepare-image.sh", account_id])


def get_github_key(secretsmanager: SecretsManagerClient) -> str:
    """
    Get my GitHub accounts private key from AWS Secrets Manager.
    :param secretsmanager: Boto3 Secrets Manager client used to get secrets.
    :return: The private key.
    """
    secret = secretsmanager.get_secret_value(SecretId=f"github-secret")

    secret_string = secret.get('SecretString')
    secret_dict: dict = json.loads(secret_string)
    return secret_dict["private_key"]


def get_jenkins_password(secretsmanager: SecretsManagerClient) -> str:
    """
    Get the password for jenkins.jarombek.io from AWS Secrets Manager.
    :param secretsmanager: Boto3 Secrets Manager client used to get secrets.
    :return: The Jenkins password.
    """
    secret = secretsmanager.get_secret_value(SecretId="jenkins-secret")

    secret_string = secret.get('SecretString')
    secret_dict: dict = json.loads(secret_string)
    return secret_dict["password"]


def get_google_account_password(secretsmanager: SecretsManagerClient) -> str:
    """
    Get a Google account password from AWS Secrets Manager.
    :param secretsmanager: Boto3 Secrets Manager client used to get secrets.
    :return: The Google account password.
    """
    secret = secretsmanager.get_secret_value(SecretId="google-account-secret")

    secret_string = secret.get('SecretString')
    secret_dict: dict = json.loads(secret_string)
    return secret_dict["password"]


def get_account_id() -> str:
    """
    Get the current users AWS account ID.
    :return: The account ID.
    """
    sts: STSClient = boto3.client('sts')
    return sts.get_caller_identity().get('Account')


if __name__ == '__main__':
    exit(main())
