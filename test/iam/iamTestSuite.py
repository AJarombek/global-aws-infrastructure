"""
Test suite for the IAM policies in my AWS account.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

import masterTestFuncs as Test
from iam import iamTestFuncs as Func

tests = [
    lambda: Test.test(Func.admin_group_exists, "IAM Admin Group Exists"),
    lambda: Test.test(Func.andy_user_exists, "IAM Andy User Exists"),
    lambda: Test.test(Func.andy_admin_group_membership, "IAM Andy User is a Member of Admin Group"),
    lambda: Test.test(Func.jenkins_role_exists, "IAM Jenkins Role Exists"),
    lambda: Test.test(Func.admin_policy_attached, "IAM Jenkins Role Has Admin Policy Attached"),
    lambda: Test.test(Func.elastic_ip_policy_attached, "IAM Jenkins Role Has Elastic IP Policy Attached")
]


def iam_test_suite() -> bool:
    """
    Execute all the tests related to the IAM policies
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "IAM Test Suite")