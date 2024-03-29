### Overview

This is the testing suite for my global AWS cloud infrastructure.  Tests are run in Python using Amazon's boto3 module.  
Each infrastructure grouping has its own test suite.  Each test suite contains many individual tests.  Test suites can 
be run independently or all at once.

To run all test suites at once, execute the following commands from this directory:

```bash
pipenv run test
```

To update the lockfile with Pipfile dependencies, execute the following command:

```bash
pipenv install
```

To format the code, execute the following commands:

```bash
pipenv shell
black .

# To check the formatting without modifying the code
black --check .
```

Or if you want the test results to be placed in a log, execute the following command:

```bash
python3 runner.py test_results.log
```

### Files

| Filename            | Description                                                              |
|---------------------|--------------------------------------------------------------------------|
| `suites`            | Multiple test suites for different resources in my cloud.                |
| `Pipfile`           | Dependencies and Python virtual environment configuration for the tests. |
| `runner.py`         | Invokes all the test suites.                                             |