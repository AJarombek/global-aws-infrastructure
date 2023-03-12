### Overview

Python tests for the AWS infrastructure.  Each file corresponds to a folder of Terraform infrastructure in this 
repository.

### Files

| Filename                   | Description                                                                          |
|----------------------------|--------------------------------------------------------------------------------------|
| `testApplicationVPC.py`    | Test suite for the Application VPC.                                                  |
| `testBackend.py`           | Test suite for the Terraform S3 Backend.                                             |
| `testBudgets.py`           | Test suite for AWS cost management budgets.                                          |
| `testCloudTrail.py`        | Test suite for AWS CloudTrail configuration.                                         |
| `testConfig.py`            | Test suite for AWS Config infrastructure.                                            |
| `testEKS.py`               | Test suite for the EKS cluster.                                                      |
| `testFileVault.py`         | Test suite for a file vault S3 bucket.                                               |
| `testIAM.py`               | Test suite for IAM roles and policies used globally.                                 |
| `testJarombekComApp.py`    | Test suite for the Amazon HTTPS certificates.                                        |
| `testJenkins.py`           | *DEPRECATED* Test suite for the Jenkins EC2 infrastructure.                          |
| `testJenkinsEFS.py`        | *DEPRECATED* Test suite for the EFS persistent storage for the Jenkins EC2 instance. |
| `testJenkinsKubernetes.py` | Test suite for the Jenkins infrastructure on Kubernetes.                             |
| `testLambda.py`            | Test suite for AWS Lambda functions.                                                 |
| `testLambdaLayers.py`      | Test suite for reusable AWS Lambda layers.                                           |
| `testRoot.py`              | Test suite for the Root infrastructure for my AWS cloud.                             |
| `testRoute53.py`           | Test suite for Route53 records used globally.                                        |
| `testS3.py`                | Test suite for a global S3 bucket.                                                   |
| `testSecretsManager.py`    | Test suite for credentials stored in Secrets Manager.                                |
| `testSNS.py`               | Test suite for SNS topics and subscriptions.                                         |
| `testVPCPeering.py`        | Test suite for VPC peering connections.                                              |