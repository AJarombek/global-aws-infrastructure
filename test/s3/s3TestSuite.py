"""
Test suite for the global.jarombek.io S3 bucket.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from s3 import s3TestFuncs as Func

tests = [
    lambda: Test.test(Func, "")
]


def s3_test_suite() -> bool:
    """
    Execute all the tests related to the global.jarombek.io S3 bucket
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "S3 Test Suite")