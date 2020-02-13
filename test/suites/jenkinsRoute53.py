"""
Functions which represent Unit tests for the jenkins Route53 DNS configuration
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest
import boto3
from test.utils.route53 import Route53


class TestJenkinsRoute53(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.route53 = boto3.client('route53')

    def test_jenkins_jarombek_io_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for 'jenkins.jarombek.io.' in Route53
        """
        try:
            a_record = Route53.get_record('jenkins.jarombek.io.', 'jenkins.jarombek.io.', 'A')
        except IndexError:
            self.assertTrue(False)
            return

        self.assertTrue(a_record.get('Name') == 'jenkins.jarombek.io.' and a_record.get('Type') == 'A')
