"""
Functions which represent Unit tests for the route53 DNS configuration
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3
from utils.route53 import Route53

route53 = boto3.client('route53')


def jarombek_io_zone_exists() -> bool:
    """
    Determine if the jarombek.io Route53 zone exists.
    :return: True if it exists, False otherwise
    """
    zones = route53.list_hosted_zones_by_name(DNSName='jarombek.io.', MaxItems='1').get('HostedZones')
    return len(zones) == 1


def jarombek_io_zone_public() -> bool:
    """
    Determine if the jarombek.io Route53 zone is public.
    :return: True if its public, False otherwise
    """
    zones = route53.list_hosted_zones_by_name(DNSName='jarombek.io.', MaxItems='1').get('HostedZones')
    return zones[0].get('Config').get('PrivateZone') is False


def jarombek_io_ns_record_exists() -> bool:
    """
    Determine if the 'NS' record exists for 'jarombek.io.' in Route53
    :return: True if it exists, False otherwise
    """
    a_record = Route53.get_record('jarombek.io.', 'jarombek.io.', 'NS')
    return a_record.get('Name') == 'jarombek.io.' and a_record.get('Type') == 'NS'


def jarombek_io_a_record_exists() -> bool:
    """
    Determine if the 'A' record exists for 'jarombek.io.' in Route53
    :return: True if it exists, False otherwise
    """
    a_record = Route53.get_record('jarombek.io.', 'jarombek.io.', 'A')
    return a_record.get('Name') == 'jarombek.io.' and a_record.get('Type') == 'A'


def www_jarombek_io_a_record_exists() -> bool:
    """
    Determine if the 'A' record exists for 'www.jarombek.io.' in Route53
    :return: True if it exists, False otherwise
    """
    a_record = get_record('jarombek.io.', 'www.jarombek.io.', 'A')
    return a_record.get('Name') == 'www.jarombek.io.' and a_record.get('Type') == 'A'
