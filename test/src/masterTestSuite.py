"""
Testing suite which calls all the more specific test suites
Author: Andrew Jarombek
Date: 4/27/2019
"""

from src import masterTestFuncs as Test
from src.apps.jarombekcom import jarombekTestSuite as JarombekCom
from src.apps.saintsxctfcom import saintsxctfTestSuite as SaintsXCTFCom
from src.backend import backendTestSuite as Backend
from src.iam import iamTestSuite as IAM
from src.jenkins import jenkinsTestSuite as Jenkins
from src.jenkinsefs import jenkinsEFSTestSuite as JenkinsEFS
from src.jenkinsRoute53 import jenkinsRoute53TestSuite as JenkinsRoute53
from src.root import rootTestSuite as Root
from src.route53 import route53TestSuite as Route53
from src.s3 import s3TestSuite as S3

# List of all the test suites
tests = [
    JarombekCom.jarombek_test_suite,
    SaintsXCTFCom.saints_xctf_test_suite,
    Backend.backend_test_suite,
    IAM.iam_test_suite,
    Jenkins.jenkins_test_suite,
    JenkinsEFS.jenkins_efs_test_suite,
    JenkinsRoute53.jenkins_route53_test_suite,
    Root.root_test_suite,
    Route53.route53_test_suite,
    S3.s3_test_suite
]

# Create and execute a master test suite
Test.testsuite(tests, "Master Test Suite")
