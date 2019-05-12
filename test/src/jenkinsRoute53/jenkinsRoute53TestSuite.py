"""
Test suite for the jenkins Route53 DNS configuration.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

from src import masterTestFuncs as Test
from src.jenkinsRoute53 import jenkinsRoute53TestFuncs as Func

tests = [
    lambda: Test.test(Func.jenkins_jarombek_io_a_record_exists, "The jenkins.jarombek.io 'A' record exists")
]


def jenkins_route53_test_suite() -> bool:
    """
    Execute all the tests related to the jenkins Route53 DNS configuration
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Jenkins Route53 Test Suite")
