"""
Functions which represent Unit tests for the S3 backend infrastructure for Terraform
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3

s3 = boto3.client('s3')


def s3_backup_bucket_exists():
    """
    Test if an S3 bucket for the Terraform backend exists
    :return: True if the bucket exists, False otherwise
    """
    s3_bucket = s3.list_objects(Bucket='andrew-jarombek-terraform-state')
    return s3_bucket.get('Name') == 'andrew-jarombek-terraform-state'
