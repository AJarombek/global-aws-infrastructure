"""
Functions which represent Unit tests for the route53 DNS configuration
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest
from typing import List

import boto3
from boto3_type_annotations.route53 import Client as Route53Client
from boto3_type_annotations.cloudwatch import Client as CloudwatchClient

from aws_test_functions.Route53 import Route53


class TestRoute53(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.route53: Route53Client = boto3.client('route53')
        self.cloudwatch: CloudwatchClient = boto3.client('cloudwatch')

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

    def test_jarombek_com_health_check_exists(self) -> None:
        """
        Determine if a Route53 Health Check exists for jarombek.com
        """
        health_checks: List[dict] = self.route53.list_health_checks().get('HealthChecks')
        jarombek_com_health_checks = [
            health_check for health_check in health_checks
            if health_check.get('HealthCheckConfig').get('FullyQualifiedDomainName') == 'jarombek.com'
        ]

        self.assertEqual(1, len(jarombek_com_health_checks))

        health_check_config = jarombek_com_health_checks[0].get('HealthCheckConfig')
        self.assertEqual(443, health_check_config.get('Port'))
        self.assertEqual('HTTPS', health_check_config.get('Type'))
        self.assertEqual('/', health_check_config.get('ResourcePath'))
        self.assertEqual(30, health_check_config.get('RequestInterval'))
        self.assertEqual(3, health_check_config.get('FailureThreshold'))

    def test_saintsxctf_com_health_check_exists(self) -> None:
        """
        Determine if a Route53 Health Check exists for saintsxctf.com
        """
        health_checks: List[dict] = self.route53.list_health_checks().get('HealthChecks')
        saintsxctf_com_health_checks = [
            health_check for health_check in health_checks
            if health_check.get('HealthCheckConfig').get('FullyQualifiedDomainName') == 'saintsxctf.com'
        ]

        self.assertEqual(1, len(saintsxctf_com_health_checks))

        health_check_config = saintsxctf_com_health_checks[0].get('HealthCheckConfig')
        self.assertEqual(443, health_check_config.get('Port'))
        self.assertEqual('HTTPS', health_check_config.get('Type'))
        self.assertEqual('/', health_check_config.get('ResourcePath'))
        self.assertEqual(30, health_check_config.get('RequestInterval'))
        self.assertEqual(3, health_check_config.get('FailureThreshold'))

    def test_jarombek_com_health_check_alarm_exists(self) -> None:
        """
        Determine if the Route53 Health Check for jarombek.com has a Cloudwatch alarm.
        """
        alarms: List[dict] = self.cloudwatch\
            .describe_alarms(AlarmNames=['jarombek-com-health-check-alarm'])\
            .get('MetricAlarms')

        self.assertEqual(1, len(alarms))

        alarm = alarms[0]
        self.assertEqual('Determine if jarombek.com is down.', alarm.get('AlarmDescription'))
        self.assertEqual('OK', alarm.get('StateValue'))
        self.assertEqual('AWS/Route53', alarm.get('Namespace'))
        self.assertEqual('HealthCheckStatus', alarm.get('MetricName'))
        self.assertEqual('Minimum', alarm.get('Statistic'))
        self.assertEqual('LessThanOrEqualToThreshold', alarm.get('ComparisonOperator'))
        self.assertEqual(60, alarm.get('Period'))
        self.assertEqual(2, alarm.get('EvaluationPeriods'))
        self.assertEqual(0, alarm.get('Threshold'))

    def test_saintsxctf_com_health_check_alarm_exists(self) -> None:
        """
        Determine if the Route53 Health Check for saintsxctf.com has a Cloudwatch alarm.
        """
        alarms: List[dict] = self.cloudwatch \
            .describe_alarms(AlarmNames=['saints-xctf-com-health-check-alarm']) \
            .get('MetricAlarms')

        self.assertEqual(1, len(alarms))

        alarm = alarms[0]
        self.assertEqual('Determine if saintsxctf.com is down.', alarm.get('AlarmDescription'))
        self.assertEqual('OK', alarm.get('StateValue'))
        self.assertEqual('AWS/Route53', alarm.get('Namespace'))
        self.assertEqual('HealthCheckStatus', alarm.get('MetricName'))
        self.assertEqual('Minimum', alarm.get('Statistic'))
        self.assertEqual('LessThanOrEqualToThreshold', alarm.get('ComparisonOperator'))
        self.assertEqual(60, alarm.get('Period'))
        self.assertEqual(2, alarm.get('EvaluationPeriods'))
        self.assertEqual(0, alarm.get('Threshold'))
