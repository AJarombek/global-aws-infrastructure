"""
Functions which represent Unit tests for the jenkins Route53 DNS configuration
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3
from utils.route53 import get_record

route53 = boto3.client('route53')


def jenkins_jarombek_io_a_record_exists() -> bool:
    """
    Determine if the 'A' record exists for 'jenkins.jarombek.io.' in Route53
    :return: True if it exists, False otherwise
    """
    a_record = get_record('jenkins.jarombek.io.', 'jenkins.jarombek.io.', 'A')
    return a_record.get('Name') == 'jenkins.jarombek.io.' and a_record.get('Type') == 'A'
