"""
Functions which represent Unit tests for the jenkins Route53 DNS configuration
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3

ec2 = boto3.resource('ec2')