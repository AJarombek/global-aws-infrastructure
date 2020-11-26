"""
Functions which represent Unit tests for the route53 DNS configuration
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest

import boto3

from aws_test_functions.Route53 import Route53


class TestRoute53(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.route53 = boto3.client('route53')

    def test_jarombek_io_zone_exists(self) -> None:
        """
        Determine if the jarombek.io Route53 zone exists.
        :return: True if it exists, False otherwise
        """
        zones = self.route53.list_hosted_zones_by_name(DNSName='jarombek.io.', MaxItems='1').get('HostedZones')
        self.assertTrue(len(zones) == 1)

    def test_jarombek_io_zone_public(self) -> None:
        """
        Determine if the jarombek.io Route53 zone is public.
        """
        zones = self.route53.list_hosted_zones_by_name(DNSName='jarombek.io.', MaxItems='1').get('HostedZones')
        self.assertTrue(zones[0].get('Config').get('PrivateZone') is False)
    
    def test_jarombek_io_ns_record_exists(self) -> None:
        """
        Determine if the 'NS' record exists for 'jarombek.io.' in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.io.', 'jarombek.io.', 'NS')
        except IndexError:
            self.assertTrue(False)
            return
    
        self.assertTrue(a_record.get('Name') == 'jarombek.io.' and a_record.get('Type') == 'NS')

    @unittest.skip("'jarombek.io' A record currently unimplemented")
    def test_jarombek_io_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for 'jarombek.io.' in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.io.', 'jarombek.io.', 'A')
        except IndexError:
            self.assertTrue(False)
            return
    
        self.assertTrue(a_record.get('Name') == 'jarombek.io.' and a_record.get('Type') == 'A')

    @unittest.skip("'www.jarombek.io' A record currently unimplemented")
    def test_www_jarombek_io_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for 'www.jarombek.io.' in Route53
        """
        try:
            a_record = Route53.get_record('jarombek.io.', 'www.jarombek.io.', 'A')
        except IndexError:
            self.assertTrue(False)
            return
    
        self.assertTrue(a_record.get('Name') == 'www.jarombek.io.' and a_record.get('Type') == 'A')
