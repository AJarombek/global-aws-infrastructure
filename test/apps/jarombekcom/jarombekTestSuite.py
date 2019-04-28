"""
Test suite for the jarombek-com vpc infrastructure.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from apps.jarombekcom import jarombekTestFuncs as Func

tests = [
    lambda: Test.test(Func, "")
]


def jarombek_test_suite() -> bool:
    """
    Execute all the tests related to the jarombek-com vpc infrastructure
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Jarombek VPC Test Suite")