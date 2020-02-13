"""
Runner which executes a test suite for global/sandbox AWS infrastructure
Author: Andrew Jarombek
Date: 5/27/2019
"""

import unittest
import suites.backend as backend
import suites.iam as iam
import suites.jarombekComApp as jarombekComApp
import suites.jenkins as jenkins
import suites.jenkinsEFS as jenkinsEFS
import suites.jenkinsRoute53 as jenkinsRoute53
import suites.root as root
import suites.route53 as route53
import suites.s3 as s3
import suites.saintsxctfComApp as saintsxctfComApp

# Create the test suite
loader = unittest.TestLoader()
suite = unittest.TestSuite()

# Add test files to the test suite
suite.addTests(loader.loadTestsFromModule(backend))
suite.addTests(loader.loadTestsFromModule(iam))
suite.addTests(loader.loadTestsFromModule(jarombekComApp))
suite.addTests(loader.loadTestsFromModule(jenkins))
suite.addTests(loader.loadTestsFromModule(jenkinsEFS))
suite.addTests(loader.loadTestsFromModule(jenkinsRoute53))
suite.addTests(loader.loadTestsFromModule(root))
suite.addTests(loader.loadTestsFromModule(route53))
suite.addTests(loader.loadTestsFromModule(s3))
suite.addTests(loader.loadTestsFromModule(saintsxctfComApp))

# Create a test runner an execute the test suite
runner = unittest.TextTestRunner(verbosity=3)
result = runner.run(suite)
