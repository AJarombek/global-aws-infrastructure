### Overview

Python tests for the AWS infrastructure.  Each file corresponds to a folder of Terraform infrastructure in this 
repository.

### Files

| Filename                | Description                                              |
|-------------------------|----------------------------------------------------------|
| `testApplicationVPC.py` | Test suite for the Application VPC.                      |
| `testBackend.py`        | Test suite for the Terraform S3 Backend.                 |
| `testBudgets.py`        | Test suite for AWS cost management budgets.              |
| `testCloudTrail.py`     | Test suite for AWS CloudTrail configuration.             |
| `testConfig.py`         | Test suite for AWS Config infrastructure.                |
| `testECS.py`            | Test suite for the ECS cluster.                          |
| `testEKS.py`            | Test suite for the EKS cluster.                          |
| `testFileVault.py`      | Test suite for a file vault S3 bucket.                   |
| `testJarombekComApp.py` | Test suite for the Amazon HTTPS certificates.            |
| `testLambda.py`         | Test suite for AWS Lambda functions.                     |
| `testLambdaLayers.py`   | Test suite for reusable AWS Lambda layers.               |
| `testRoute53.py`        | Test suite for Route53 records used globally.            |
| `testS3.py`             | Test suite for a global S3 bucket.                       |
| `testSecretsManager.py` | Test suite for credentials stored in Secrets Manager.    |
| `testSNS.py`            | Test suite for SNS topics and subscriptions.             |