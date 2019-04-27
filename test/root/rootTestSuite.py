"""
Test suite for the root infrastructure of my AWS account.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from root import rootTestFuncs as Func

tests = [
    lambda: Test.test(Func, "")
]


def root_test_suite() -> bool:
    """
    Execute all the tests related to the root infrastructure of my AWS account
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Root Test Suite")