### Overview

Test code for DNS records pointing to the global Jenkins server.  The Jenkins Route53 test suite can be run individually 
or inside the master test suite.

### Files

| Filename                      | Description                                                                                  |
|-------------------------------|----------------------------------------------------------------------------------------------|
| `jenkinsRoute53TestFuncs.py`  | Functions to test a single aspect of the DNS records for the Jenkins server.                 |
| `jenkinsRoute53TestSuite.py`  | Test suite for the Jenkins server DNS records.                                               |