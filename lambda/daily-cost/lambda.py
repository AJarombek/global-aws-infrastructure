"""
Lambda function used to determine the daily cost of AWS expenses.
Author: Andrew Jarombek
Date: 7/17/2021
"""

from datetime import datetime, timedelta

import boto3


def handler(event, context):
    cost_explorer = boto3.client('ce')
    sns = boto3.client('sns')
    sts = boto3.client('sts')

    end = datetime.now() - timedelta(days=1)
    start = datetime.now() - timedelta(days=2)

    cost_statistics: dict = cost_explorer.get_cost_and_usage(
        TimePeriod={
            'Start': start.strftime('%Y-%m-%d'),
            'End': end.strftime('%Y-%m-%d')
        },
        Granularity='DAILY',
        Metrics=['AmortizedCost']
    )

    cost_str = cost_statistics.get('ResultsByTime')[0].get('Total').get('AmortizedCost').get('Amount')
    cost = round(float(cost_str), 2)

    cost_description = f"AWS Costs Yesterday: {cost}"

    account_id = sts.get_caller_identity().get('Account')
    topic_arn = f'arn:aws:sns:us-east-1:{account_id}:alert-email-topic'

    sns.publish(TopicArn=topic_arn, Message=cost_description)
    return cost_description


if __name__ == '__main__':
    print(handler(None, None))
