"""
Functions which represent Unit tests for the jenkins Route53 DNS configuration
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest
import os

import boto3
from boto3_type_annotations.route53 import Client as Route53Client
from boto3_type_annotations.acm import Client as ACMClient
from boto3_type_annotations.ecr import Client as ECRClient

from aws_test_functions.Route53 import Route53
from aws_test_functions.SecurityGroup import SecurityGroup

ENV = os.environ.get('TEST_ENV', 'prod')
PROD_ENV = ENV == "prod"


class TestJenkinsKubernetes(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.route53: Route53Client = boto3.client('route53')
        self.acm: ACMClient = boto3.client('acm')
        self.ecr: ECRClient = boto3.client('ecr')
        self.prod_env = PROD_ENV

    def test_acm_wildcard_cert_issued(self) -> None:
        """
        Test that the '*.jenkins.jarombek.io' wildcard ACM certificate exists
        """
        acm_certificates = self.acm.list_certificates(CertificateStatuses=['ISSUED'])
        for cert in acm_certificates.get('CertificateSummaryList'):
            if cert.get('DomainName') == '*.jenkins.jarombek.io':
                self.assertTrue(True)
                return

        self.assertTrue(False)

    @unittest.skip("DEV certificate not actively maintained.")
    def test_acm_dev_wildcard_cert_issued(self) -> None:
        """
        Test that the '*.dev.jenkins.jarombek.io' wildcard ACM certificate exists
        """
        acm_certificates = self.acm.list_certificates(CertificateStatuses=['ISSUED'])
        for cert in acm_certificates.get('CertificateSummaryList'):
            if cert.get('DomainName') == '*.dev.jenkins.jarombek.io':
                self.assertTrue(True)
                return

        self.assertTrue(False)

    def test_ecr_repository_exists(self) -> None:
        """
        Test that the 'jenkins-jarombek-io' ECR repository exists.
        """
        repos = self.ecr.describe_repositories(repositoryNames=['jenkins-jarombek-io']).get('repositories')
        self.assertEqual(1, len(repos))
        self.assertEqual('jenkins-jarombek-io', repos[0].get('repositoryName'))
        self.assertEqual('MUTABLE', repos[0].get('imageTagMutability'))

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

    @unittest.skipIf(not PROD_ENV, 'Jenkins server not setup in development.')
    def test_jenkins_load_balancer_security_group(self) -> None:
        sg = SecurityGroup.get_security_groups(name=f'jenkins-{ENV}-lb-security-group')[0]

        self.assertTrue(all([
            sg.get('GroupName') == f'jenkins-{ENV}-lb-security-group',
            TestJenkinsKubernetes.validate_jenkins_load_balancer_sg_rules(
                sg.get('IpPermissions'), sg.get('IpPermissionsEgress')
            )
        ]))

    @staticmethod
    def validate_jenkins_load_balancer_sg_rules(ingress: list, egress: list):
        """
        Ensure that the jenkins-{env}-lb-security-group security group rules are as expected
        :param ingress: Ingress rules for the security group
        :param egress: Egress rules for the security group
        :return: True if the security group rules exist as expected, False otherwise
        """
        ingress_80 = SecurityGroup.validate_sg_rule_cidr(ingress[0], 'tcp', 80, 80, '0.0.0.0/0')
        ingress_443 = SecurityGroup.validate_sg_rule_cidr(ingress[1], 'tcp', 443, 443, '0.0.0.0/0')
        egress_neg1 = SecurityGroup.validate_sg_rule_cidr(egress[0], '-1', 0, 0, '0.0.0.0/0')

        return all([
            len(ingress) == 2,
            ingress_80,
            ingress_443,
            len(egress) == 1,
            egress_neg1
        ])
