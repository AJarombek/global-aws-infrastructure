"""
Functions which represent Unit tests for the jenkins EFS infrastructure
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest

import boto3

from aws_test_functions.VPC import VPC
from aws_test_functions.SecurityGroup import SecurityGroup


class TestJenkinsEFS(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.efs = boto3.client("efs")

    @unittest.skip("Jenkins EFS is deprecated and may no longer exist.")
    def test_jenkins_efs_exists(self) -> None:
        """
        Determine if EFS for Jenkins exists
        """
        self.assertTrue(len(self.get_efs("jenkins-efs")) == 1)

    @unittest.skip("Jenkins EFS is deprecated and may no longer exist.")
    def test_jenkins_efs_mounted(self) -> None:
        """
        Determine if EFS is mounted in a specific subnet
        """
        efs_id = self.get_efs("jenkins-efs")[0].get("FileSystemId")
        efs_mount_target = self.efs.describe_mount_targets(FileSystemId=efs_id).get(
            "MountTargets"
        )[0]
        subnet_id = VPC.get_subnets("resources-vpc-public-subnet")[0].get("SubnetId")

        self.assertTrue(
            all(
                [
                    efs_id == efs_mount_target.get("FileSystemId"),
                    efs_mount_target.get("SubnetId") == subnet_id,
                ]
            )
        )

    @unittest.skip("Jenkins EFS is deprecated and may no longer exist.")
    def test_jenkins_efs_sg_valid(self) -> None:
        """
        Determine if the security group for EFS is as expected
        """
        sg = SecurityGroup.get_security_groups("jenkins-efs-security")[0]
        ingress = sg.get("IpPermissions")
        egress = sg.get("IpPermissionsEgress")

        ingress_2049 = SecurityGroup.validate_sg_rule_cidr(
            ingress[0], "tcp", 2049, 2049, "10.0.0.0/16"
        )
        egress_2049 = SecurityGroup.validate_sg_rule_cidr(
            egress[0], "tcp", 2049, 2049, "10.0.0.0/16"
        )

        self.assertTrue(
            all(
                [
                    sg.get("GroupName") == "jenkins-efs-security",
                    ingress_2049,
                    egress_2049,
                ]
            )
        )

    """
    Helper functions for Jenkins EFS
    """

    def get_efs(self, name: str) -> list:
        """
        Get a list of all Elastic Filesystems (EFS) that match a given name
        :param name: The name of the EFS on AWS
        :return: A list of EFS objects (dictionaries)
        """
        filesystem = self.efs.describe_file_systems()
        return [
            item for item in filesystem.get("FileSystems") if item.get("Name") == name
        ]
