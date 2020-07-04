"""
On a three day rolling average, detect if AWS costs are greater than expected.
Author: Andrew Jarombek
Date: 7/4/2020
"""

from datetime import datetime, timedelta
from typing import List
from functools import reduce

import boto3
from boto3_type_annotations.ce import Client as CEClient


def main():
    cost_explorer: CEClient = boto3.client('ce')

    end = datetime.now()
    start = end - timedelta(days=3)

    cost_statistics: dict = cost_explorer.get_cost_and_usage(
        TimePeriod={
            'Start': start.strftime('%Y-%m-%d'),
            'End': end.strftime('%Y-%m-%d')
        },
        Granularity='DAILY',
        Metrics=['AmortizedCost']
    )

    costs: List[float] = [
        float(cost.get('Total').get('AmortizedCost').get('Amount'))
        for cost in cost_statistics.get('ResultsByTime')
    ]

    avg_cost = reduce(lambda x, y: x + y, costs) / 3
    avg_cost = round(avg_cost, 2)
    print(avg_cost)


if __name__ == '__main__':
    exit(main())
