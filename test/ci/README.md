### Overview

This directory contains a Jenkins pipeline job that is triggered when commits are pushed to GitHub for this repository.  
This job invokes another job which runs Unit tests defined in the `../src` repository (relatively).

### Files

| Filename                  | Description                                                                                     |
|---------------------------|-------------------------------------------------------------------------------------------------|
| `jenkinsfile.groovy`      | Jenkinsfile which is executed when the `global-aws-infrastructure-trigger` pipeline job is run. |
| `job_dsl.groovy`          | *Job DSL Plugin* script which creates the `global-aws-infrastructure-trigger` Jenkins job.      |