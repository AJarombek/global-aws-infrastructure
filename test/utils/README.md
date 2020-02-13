### Overview

Utility functions for retrieving and validating resources from AWS.  Resources are retrieved with `boto3`, an AWS SDK 
for Python.

### Files

| Filename             | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| `ec2.py`             | Helper functions for EC2 instances and related resources (Load Balancers, AMIs, etc.).       |
| `route53.py`         | Helper functions for Route53 zones and records.                                              |
| `securityGroup.py`   | Helper functions for Security Groups and their corresponding rules.                          |
| `vpc.py`             | Helper functions for VPCs and related resources (Subnets, Internet Gateways, etc.).          |