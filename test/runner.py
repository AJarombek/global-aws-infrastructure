"""
Runner which executes a test suite for global/sandbox AWS infrastructure
Author: Andrew Jarombek
Date: 5/27/2019
"""

import unittest
import sys

if __name__ == "__main__":

    # Create the test suite
    tests = unittest.TestLoader().discover("suites")

    if len(sys.argv) > 1:
        log_filename = sys.argv[1]
        with open(log_filename, "w+") as log_file:

            # Create a test runner an execute the test suite
            runner = unittest.TextTestRunner(log_file, verbosity=3)
            result: unittest.TestResult = runner.run(tests)
            exit(len(result.errors))
    else:
        runner = unittest.TextTestRunner(verbosity=3)
        result: unittest.TestResult = runner.run(tests)
        exit(len(result.errors))
