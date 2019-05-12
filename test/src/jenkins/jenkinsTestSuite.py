"""
Test suite for the Jenkins server infrastructure.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 4/27/2019
"""

from src import masterTestFuncs as Test
from src.jenkins import jenkinsTestFuncs as Func

tests = [
    lambda: Test.test(Func.ami_exists, "Confirm one or more AMIs Exist for the Jenkins Server"),
    lambda: Test.test(Func.jenkins_server_running, "Confirm that the Jenkins Server is Running"),
    lambda: Test.test(Func.jenkins_server_not_overscaled, "Ensure there are an Expected Number of Instances"),
    lambda: Test.test(Func.jenkins_instance_profile_exists, "Ensure the Jenkins Server has an Instance Profile"),
    lambda: Test.test(Func.jenkins_launch_config_valid, "Validate the Jenkins Server Launch Configuration"),
    lambda: Test.test(Func.jenkins_launch_config_sg_valid, "Validate the Launch Configurations Security Group"),
    lambda: Test.test(Func.jenkins_autoscaling_group_valid, "Validate the Jenkins Server AutoScaling Group"),
    lambda: Test.test(Func.jenkins_autoscaling_schedules_set, "Ensure the AutoScaling Group has Schedules"),
    lambda: Test.test(Func.jenkins_load_balancer_valid, "Validate the Jenkins Server Load Balancer is Running"),
    lambda: Test.test(Func.jenkins_load_balancer_sg_valid, "Validate the Load Balancer Security Group")
]


def jenkins_test_suite() -> bool:
    """
    Execute all the tests related to the jenkins server infrastructure
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Jenkins Test Suite")