"""
Test suite for the saints-xctf-com vpc infrastructure.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from apps.saintsxctfcom import saintsxctfTestFuncs as Func

tests = [
    lambda: Test.test(Func, "")
]


def saints_xctf_test_suite() -> bool:
    """
    Execute all the tests related to the saints-xctf-com vpc infrastructure
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "SaintsXCTF VPC Test Suite")