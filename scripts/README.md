### Commands

**Execute Cost Detection Script**

```bash
pipenv --rm
pipenv install
pipenv run python costDetection.py
```

**Get Cost Statistics from the AWS CLI**

```bash
# Get cost statistics for the past three days.
aws ce get-cost-and-usage --time-period Start=2020-07-01,End=2020-07-04 --granularity DAILY --metrics AmortizedCost
```