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
    private_key = get_github_key()
    account_id = get_account_id()

    with open("jenkins-template.yaml", "r+") as file:
        jenkins_config: str = file.read()

    jenkins_config = jenkins_config.replace("${SSH_PRIVATE_KEY}", private_key)

    with open("jenkins.yaml", "w") as file:
        file.write(jenkins_config)

    subprocess.call(["./prepare-image.sh", account_id])


def get_github_key():
    """
    Get my GitHub accounts private key from AWS Secrets Manager.
    :return: The private key.
    """
    secretsmanager: SecretsManagerClient = boto3.client('secretsmanager')
    secret = secretsmanager.get_secret_value(SecretId=f"github-secret")

    secret_string = secret.get('SecretString')
    secret_dict: dict = json.loads(secret_string)
    return secret_dict["private_key"]


def get_account_id():
    """
    Get the current users AWS account ID.
    :return: The account ID.
    """
    sts: STSClient = boto3.client('sts')
    return sts.get_caller_identity().get('Account')


if __name__ == '__main__':
    exit(main())
