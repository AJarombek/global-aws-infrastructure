"""
Helper functions for Security Groups
Author: Andrew Jarombek
Date: 4/28/2019
"""

import boto3

ec2 = boto3.client('ec2')


class SecurityGroup:

    @staticmethod
    def validate_sg_rule_cidr(rule: dict, protocol: str, from_port: int, to_port: int, cidr: str) -> bool:
        """
        Determine if a security group rule which opens connections
        from (ingress) or to (egress) a CIDR block exists as expected.
        :param rule: A dictionary containing security group rule information
        :param protocol: Which protocol the rule enables connections for
        :param from_port: Which source port the rule enables connections for
        :param to_port: Which destination port the rule enables connections for
        :param cidr: The ingress or egress CIDR block
        :return: True if the security group rule exists as expected, False otherwise
        """
        if from_port == 0:
            from_port_valid = 'FromPort' not in rule.keys()
        else:
            from_port_valid = rule.get('FromPort') == from_port

        if to_port == 0:
            to_port_valid = 'ToPort' not in rule.keys()
        else:
            to_port_valid = rule.get('ToPort') == to_port

        return all([
            rule.get('IpProtocol') == protocol,
            from_port_valid,
            to_port_valid,
            rule.get('IpRanges')[0].get('CidrIp') == cidr
        ])

    @staticmethod
    def validate_sg_rule_source(rule: dict, protocol: str, from_port: int, to_port: int, source_sg: str) -> bool:
        """
        Determine if a security group rule which opens connections
        from a different source security group exists as expected.
        :param rule: A dictionary containing security group rule information
        :param protocol: Which protocol the rule enables connections for
        :param from_port: Which source port the rule enables connections for
        :param to_port: Which destination port the rule enables connections for
        :param source_sg: The destination security group identifier
        :return: True if the security group rule exists as expected, False otherwise
        """
        return all([
            rule.get('IpProtocol') == protocol,
            rule.get('FromPort') == from_port,
            rule.get('ToPort') == to_port,
            rule.get('UserIdGroupPairs')[0].get('GroupId') == source_sg
        ])