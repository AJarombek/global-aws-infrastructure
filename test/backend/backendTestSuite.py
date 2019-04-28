"""
Test suite for the S3 backend infrastructure for Terraform.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from backend import backendTestFuncs as Func

tests = [
    lambda: Test.test(Func, "")
]


def backend_test_suite() -> bool:
    """
    Execute all the tests related to the S3 backend infrastructure for Terraform
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Backend Test Suite")