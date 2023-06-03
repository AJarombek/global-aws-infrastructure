"""
Build and push a configured Jenkins Docker image to Amazon ECR.
Author: Andrew Jarombek
Date: 6/6/2020
"""

import json
import subprocess
import sys
from typing import Tuple

import boto3
from boto3_type_annotations.secretsmanager import Client as SecretsManagerClient
from boto3_type_annotations.sts import Client as STSClient
from boto3_type_annotations.eks import Client as EKSClient


def main():
    """
    Build a Jenkins image with secrets from AWS.
    """
    if len(sys.argv) > 1:
        image_tag = sys.argv[1]
    else:
        image_tag = 'latest'

    if len(sys.argv) > 2:
        push = sys.argv[2] == 'push'
    else:
        push = False

    secretsmanager: SecretsManagerClient = boto3.client('secretsmanager')

    private_key = get_github_key(secretsmanager)
    account_id = get_account_id()
    jenkins_password = get_jenkins_password(secretsmanager)
    google_account_password = get_google_account_password(secretsmanager)
    docker_hub_username, docker_hub_password = get_docker_hub_credentials(secretsmanager)
    github_access_token = get_github_access_token(secretsmanager)
    saintsxctf_rds_dev_username, saintsxctf_rds_dev_password = get_saintsxctf_rds_credentials('dev', secretsmanager)
    saintsxctf_rds_prod_username, saintsxctf_rds_prod_password = get_saintsxctf_rds_credentials('prod', secretsmanager)
    saintsxctf_password = get_saintsxctf_password(secretsmanager)
    aws_access_key_id, aws_secret_access_key = get_aws_access_secrets(secretsmanager)
    kubernetes_url = get_kubernetes_url()

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
    jenkins_config = jenkins_config.replace("${DOCKER_HUB_USERNAME}", docker_hub_username)
    jenkins_config = jenkins_config.replace("${DOCKER_HUB_PASSWORD}", docker_hub_password)
    jenkins_config = jenkins_config.replace("${GITHUB_ACCESS_TOKEN}", github_access_token)
    jenkins_config = jenkins_config.replace("${SAINTSXCTF_RDS_DEV_USERNAME}", saintsxctf_rds_dev_username)
    jenkins_config = jenkins_config.replace("${SAINTSXCTF_RDS_DEV_PASSWORD}", saintsxctf_rds_dev_password)
    jenkins_config = jenkins_config.replace("${SAINTSXCTF_RDS_PROD_USERNAME}", saintsxctf_rds_prod_username)
    jenkins_config = jenkins_config.replace("${SAINTSXCTF_RDS_PROD_PASSWORD}", saintsxctf_rds_prod_password)
    jenkins_config = jenkins_config.replace("${SAINTSXCTF_PASSWORD}", saintsxctf_password)
    jenkins_config = jenkins_config.replace("${AWS_ACCESS_KEY_ID}", aws_access_key_id)
    jenkins_config = jenkins_config.replace("${AWS_SECRET_ACCESS_KEY}", aws_secret_access_key)
    jenkins_config = jenkins_config.replace("${KUBERNETES_URL}", kubernetes_url)

    with open("jenkins.yaml", "w") as file:
        file.write(jenkins_config)

    prep_status_code = subprocess.call(["./prepare-image.sh", account_id, image_tag])

    if prep_status_code > 0:
        print("Failed to prepare image.")
        return 1

    if push:
        push_status_code = subprocess.call(["./push-image.sh", account_id, image_tag])

        if push_status_code > 0:
            print("Failed to push image.")
            return 1

    return 0


def get_aws_access_secrets(secretsmanager: SecretsManagerClient) -> Tuple[str, str]:
    """
    Get secrets for AWS CLI and SDK access from AWS Secrets Manager.
    :param secretsmanager: Boto3 Secrets Manager client used to get secrets.
    :return: The AWS secrets.
    """
    secret = secretsmanager.get_secret_value(SecretId=f"aws-access-secrets")

    secret_string = secret.get('SecretString')
    secret_dict: dict = json.loads(secret_string)
    return secret_dict["aws_access_key_id"], secret_dict["aws_secret_access_key"]


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


def get_github_access_token(secretsmanager: SecretsManagerClient) -> str:
    """
    Get an access token for my GitHub account from AWS Secrets Manager.
    :param secretsmanager: Boto3 Secrets Manager client used to get secrets.
    :return: The access token.
    """
    secret = secretsmanager.get_secret_value(SecretId=f"github-access-token")

    secret_string = secret.get('SecretString')
    secret_dict: dict = json.loads(secret_string)
    return secret_dict["access_token"]


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


def get_docker_hub_credentials(secretsmanager: SecretsManagerClient) -> Tuple[str, str]:
    """
    Get the username and password for DockerHub from AWS Secrets Manager.
    :param secretsmanager: Boto3 Secrets Manager client used to get secrets.
    :return: A tuple containing the username and password.
    """
    secret = secretsmanager.get_secret_value(SecretId="dockerhub-secret")

    secret_string = secret.get('SecretString')
    secret_dict: dict = json.loads(secret_string)
    return secret_dict["username"], secret_dict["password"]


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


def get_saintsxctf_rds_credentials(env: str, secretsmanager: SecretsManagerClient) -> Tuple[str, str]:
    """
    Get the username and password for an RDS database for SaintsXCTF.
    :param env: Environment of the database to get credentials for.  Options: dev, prod.
    :param secretsmanager: Boto3 Secrets Manager client used to get secrets.
    :return: A tuple containing the username and password.
    """
    secret = secretsmanager.get_secret_value(SecretId=f"saints-xctf-rds-{env}-secret")

    secret_string = secret.get('SecretString')
    secret_dict: dict = json.loads(secret_string)
    return secret_dict["username"], secret_dict["password"]


def get_saintsxctf_password(secretsmanager: SecretsManagerClient) -> str:
    """
    Get the password for the SaintsXCTF user 'andy'.
    :param secretsmanager: Boto3 Secrets Manager client used to get secrets.
    :return: The user's password.
    """
    secret = secretsmanager.get_secret_value(SecretId="saints-xctf-andy-password")

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


def get_kubernetes_url() -> str:
    """
    Get the URL of my AWS cloud's EKS cluster.
    :return: The Kubernetes URL.
    """
    eks: EKSClient = boto3.client('eks')
    cluster_info: dict = eks.describe_cluster(name='andrew-jarombek-eks-v2')
    return cluster_info.get('cluster').get('endpoint')


if __name__ == '__main__':
    exit(main())
