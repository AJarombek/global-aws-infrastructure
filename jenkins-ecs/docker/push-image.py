"""
Build and push a configured Jenkins Docker image to Amazon ECR.
Author: Andrew Jarombek
Date: 6/6/2020
"""

import json

import boto3
from boto3_type_annotations.secretsmanager import Client


def main():
    secretsmanager: Client = boto3.client('secretsmanager')
    secret = secretsmanager.get_secret_value(SecretId=f"github-secret")

    secret_string = secret.get('SecretString')
    secret_dict: dict = json.loads(secret_string)
    private_key = secret_dict["private_key"]

    with open("jenkins-template.yaml", "r+") as fp:
        jenkins_config: str = fp.read()

    jenkins_config.replace()


if __name__ == '__main__':
    exit(main())
