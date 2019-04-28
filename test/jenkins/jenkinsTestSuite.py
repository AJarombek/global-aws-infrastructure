"""
Test suite for the Jenkins server infrastructure.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from jenkins import jenkinsTestFuncs as Func

tests = [
    lambda: Test.test(Func, "")
]


def jenkins_test_suite() -> bool:
    """
    Execute all the tests related to the jenkins server infrastructure
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Jenkins Test Suite")