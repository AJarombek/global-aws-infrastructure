"""
Test suite for the jenkins EFS infrastructure.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from jenkinsefs import jenkinsEFSTestFuncs as Func

tests = [
    lambda: Test.test(Func.jenkins_efs_exists, "Determine if the EFS for Jenkins Exists"),
    lambda: Test.test(Func.jenkins_efs_mounted, "Determine if the EFS for Jenkins has a Mount Target"),
    lambda: Test.test(Func.jenkins_efs_sg_valid, "Determine if the Security Group for EFS is Valid")
]


def jenkins_efs_test_suite() -> bool:
    """
    Execute all the tests related to the jenkins EFS infrastructure
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Jenkins EFS Test Suite")
