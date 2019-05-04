"""
Functions which represent Unit tests for the jarombek-com vpc infrastructure
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3
from utils.vpc import VPC
from utils.securityGroup import SecurityGroup

ec2 = boto3.resource('ec2')