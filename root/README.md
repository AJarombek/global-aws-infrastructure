### Overview

This directory contains Terraform files for the top level VPC infrastructure of my cloud.  The IaC for the VPCs are 
abstracted into their own module.

### Files

| Filename                 | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `main.tf`                | The main Terraform configuration file defining the VPCs                     |
| `var.tf`                 | Variables needed for my clouds VPCs                                         |