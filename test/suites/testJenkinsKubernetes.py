"""
Functions which represent Unit tests for the jenkins Route53 DNS configuration
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest
import boto3
from boto3_type_annotations.route53 import Client as Route53Client
from boto3_type_annotations.acm import Client as ACMClient
from boto3_type_annotations.ecr import Client as ECRClient

from utils.route53 import Route53


class TestJenkinsKubernetes(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.route53: Route53Client = boto3.client('route53')
        self.acm: ACMClient = boto3.client('acm')
        self.ecr: ECRClient = boto3.client('ecr')

    def test_jenkins_jarombek_io_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for 'jenkins.jarombek.io.' in Route53
        """
        try:
            a_record = Route53.get_record(zone_name='jarombek.io.', record_name='jenkins.jarombek.io.', record_type='A')
        except IndexError:
            self.assertTrue(False)
            return

        self.assertTrue(a_record.get('Name') == 'jenkins.jarombek.io.' and a_record.get('Type') == 'A')
