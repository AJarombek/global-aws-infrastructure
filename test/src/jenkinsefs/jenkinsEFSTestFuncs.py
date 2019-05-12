"""
Functions which represent Unit tests for the jenkins EFS infrastructure
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3
from src.utils.vpc import VPC
from src.utils.securityGroup import SecurityGroup

efs = boto3.client('efs')


def jenkins_efs_exists() -> bool:
    """
    Determine if EFS for Jenkins exists
    :return: True if it exists, False otherwise
    """
    return len(get_efs('jenkins-efs')) == 1


def jenkins_efs_mounted() -> bool:
    """
    Determine if EFS is mounted in a specific subnet
    :return: True if its mounted, False otherwise
    """
    efs_id = get_efs('jenkins-efs')[0].get('FileSystemId')
    efs_mount_target = efs.describe_mount_targets(FileSystemId=efs_id).get('MountTargets')[0]
    subnet_id = VPC.get_subnets('resources-vpc-public-subnet')[0].get('SubnetId')

    return all([
        efs_id == efs_mount_target.get('FileSystemId'),
        efs_mount_target.get('SubnetId') == subnet_id
    ])


def jenkins_efs_sg_valid() -> bool:
    """
    Determine if the security group for EFS is as expected
    :return: True if its as expected, False otherwise
    """
    sg = SecurityGroup.get_security_groups('jenkins-efs-security')[0]
    ingress = sg.get('IpPermissions')
    egress = sg.get('IpPermissionsEgress')

    ingress_2049 = SecurityGroup.validate_sg_rule_cidr(ingress[0], 'tcp', 2049, 2049, '10.0.0.0/16')
    egress_2049 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 2049, 2049, '10.0.0.0/16')

    return all([
        sg.get('GroupName') == 'jenkins-efs-security',
        ingress_2049,
        egress_2049
    ])


"""
Helper functions for Jenkins EFS
"""


def get_efs(name: str) -> list:
    """
    Get a list of all Elastic Filesystems (EFS) that match a given name
    :param name: The name of the EFS on AWS
    :return: A list of EFS objects (dictionaries)
    """
    filesystem = efs.describe_file_systems()
    return [item for item in filesystem.get('FileSystems') if item.get('Name') == name]
