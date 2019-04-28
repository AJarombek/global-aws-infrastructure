"""
Test suite for the IAM policies in my AWS account.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from iam import iamTestFuncs as Func

tests = [
    lambda: Test.test(Func, "")
]


def iam_test_suite() -> bool:
    """
    Execute all the tests related to the IAM policies
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "IAM Test Suite")