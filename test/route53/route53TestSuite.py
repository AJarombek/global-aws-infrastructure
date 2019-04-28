"""
Test suite for the route53 DNS configuration.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from route53 import route53TestFuncs as Func

tests = [
    lambda: Test.test(Func.jarombek_io_zone_exists, "Check if the jarombek.io Hosted Zone Exists in Route53"),
    lambda: Test.test(Func.jarombek_io_zone_public, "Check if the jarombek.io Hosted Zone is Public"),
    lambda: Test.test(Func.jarombek_io_ns_record_exists, "The jarombek.io 'NS' record exists"),
    lambda: Test.test(Func.jarombek_io_a_record_exists, "The jarombek.io 'A' record exists"),
    lambda: Test.test(Func.www_jarombek_io_a_record_exists, "The www.jarombek.io 'A' record exists")
]


def route53_test_suite() -> bool:
    """
    Execute all the tests related to the route53 DNS configuration
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Route53 Test Suite")
