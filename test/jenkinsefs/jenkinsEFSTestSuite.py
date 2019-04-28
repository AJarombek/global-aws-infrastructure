"""
Test suite for the jenkins EFS infrastructure.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from jenkinsefs import jenkinsEFSTestFuncs as Func

tests = [
    lambda: Test.test(Func, "")
]


def jenkins_efs_test_suite() -> bool:
    """
    Execute all the tests related to the jenkins EFS infrastructure
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Jenkins EFS Test Suite")