"""
Functions which represent Unit tests for IAM policies in my AWS account
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest

import boto3


class TestIAM(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.iam = boto3.client('iam')

    def test_admin_group_exists(self) -> None:
        """
        Test that the 'admin-group' IAM Group exists
        """
        group_dict = self.iam.get_group(GroupName='admin-group')
        group = group_dict.get('Group')
        self.assertTrue(group.get('Path') == '/admin/' and group.get('GroupName') == 'admin-group')
    
    def test_andy_user_exists(self) -> None:
        """
        Test that the 'andy-user' IAM User exists
        """
        user_dict = self.iam.get_user(UserName='andy-user')
        user = user_dict.get('User')
        self.assertTrue(user.get('Path') == '/admin/' and user.get('UserName') == 'andy-user')
    
    def test_andy_admin_group_membership(self) -> None:
        """
        Test that the IAM User 'andy-user' is a member of the IAM Group 'admin-group'
        """
        group_dict = self.iam.get_group(GroupName='admin-group')
        group = group_dict.get('Group')
    
        try:
            member = group_dict.get('Users')[0]
        except TypeError:
            self.assertTrue(False)
            return

        self.assertTrue(group.get('Path') == '/admin/' and group.get('GroupName') == 'admin-group')
        self.assertTrue(member.get('Path') == '/admin/' and member.get('UserName') == 'andy-user')
    
    def test_jenkins_role_exists(self) -> None:
        """
        Test that the jenkins-role IAM Role exists
        """
        role_dict = self.iam.get_role(RoleName='jenkins-role')
        role = role_dict.get('Role')
        self.assertTrue(role.get('Path') == '/admin/' and role.get('RoleName') == 'jenkins-role')
    
    def test_admin_policy_attached(self) -> None:
        """
        Test that the admin-policy is attached to the jenkins-role
        """
        policy_response = self.iam.list_attached_role_policies(RoleName='jenkins-role')
        policies = policy_response.get('AttachedPolicies')
        admin_policy = policies[1]
        self.assertTrue(len(policies) == 2 and admin_policy.get('PolicyName') == 'admin-policy')
    
    def test_elastic_ip_policy_attached(self) -> None:
        """
        Test that the elastic-ip-policy is attached to the jenkins-role
        """
        policy_response = self.iam.list_attached_role_policies(RoleName='jenkins-role')
        policies = policy_response.get('AttachedPolicies')
        elastic_ip_policy = policies[0]
        self.assertTrue(len(policies) == 2 and elastic_ip_policy.get('PolicyName') == 'elastic-ip-policy')
