### Overview

This directory contains infrastructure and source code for AWS Lambda functions.

### Commands

**Create Lambda Zip Files**

```bash
cd daily-cost
zip -r9 AWSDailyCost.zip .
mv AWSDailyCost.zip ../AWSDailyCost.zip
cd -
```

### Files

| Filename            | Description                                                                       |
|---------------------|-----------------------------------------------------------------------------------|
| `daily-cost`        | Python source code for the `daily-cost` AWS Lambda function.                      |
| `main.tf`           | Main Terraform module for creating AWS Lambda infrastructure.                     |