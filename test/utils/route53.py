"""
Helper functions to use for retrieving Route53 information.
Author: Andrew Jarombek
Date: 4/28/2019
"""

import boto3

route53 = boto3.client('route53')


class Route53:

    @staticmethod
    def get_record(zone_name: str, record_name: str, record_type: str) -> dict:
        """
        Helper method which gets Route53 record information.
        :param zone_name: the DNS name of a Hosted Zone the record exists in
        :param record_name: the name of the Route53 record to retrieve information about
        :param record_type: the type of the Route53 record to retrieve information about
        :return: A dictionary containing information about the Route53 record
        :exception: Throws an IndexError if the Hosted Zone does not exist
        """
        hosted_zone_id = Route53.get_hosted_zone_id(zone_name)
        record_sets = route53.list_resource_record_sets(
            HostedZoneId=hosted_zone_id,
            StartRecordName=record_name,
            StartRecordType=record_type,
            MaxItems='1'
        )
        return record_sets.get('ResourceRecordSets')[0]

    @staticmethod
    def get_hosted_zone_id(name: str) -> str:
        """
        Helper function to get a Hosted Zone ID based off its name
        :param name: The DNS name of the Hosted Zone
        :return: A string representing the Hosted Zone ID
        :exception: Throws an IndexError if the Hosted Zone does not exist
        """
        hosted_zone = route53.list_hosted_zones_by_name(DNSName=name, MaxItems='1').get('HostedZones')[0]
        return hosted_zone.get('Id')
