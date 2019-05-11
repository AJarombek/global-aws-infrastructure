### Overview

This is the testing suite for my global AWS cloud infrastructure.  Tests are run in Python using Amazon's boto3 module.  
Each infrastructure grouping has its own test suite.  Each test suite contains many individual tests.  Test suites can 
be run independently or all at once.

To run all test suites at once, execute the following command from this directory:

```
python3 masterTestSuite.py
```

To run a single test suite, navigate to the suite's directory and execute the file following the regular expression  
`^[a-z]+TestSuite.py$`.

### Files

| Filename             | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| `apps/`              | Multiple test suites for different applications in my cloud.                                 |
| `backend/`           | Test suite for the Terraform backend S3 bucket.                                              |
| `iam/`               | Test suite for IAM roles and policies.                                                       |
| `jenkins/`           | Test suite for the Jenkins server `jenkins.jarombek.io`.                                     |
| `jenkinsefs/`        | Test suite for the Jenkins server elastic file storage (EFS).                                |
| `jenkinsRoute53/`    | Test suite for the Jenkins server's DNS records.                                             |
| `root/`              | Test suite for my cloud's root resources (VPCs and Subnets).                                 |
| `route53/`           | Test suite for my main DNS records.                                                          |
| `s3/`                | Test suite for an S3 bucket used for sharable files.                                         |
| `utils/`             | Utility functions used to retrieve & validate data from boto3.                               |
| `masterTestFuncs.py` | Functions used to help create a test suite environment.                                      |
| `masterTestSuite.py` | Invokes all the test suites.                                                                 |