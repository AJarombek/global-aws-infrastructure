"""
Functions which represent Unit tests for IAM policies in my AWS account
Author: Andrew Jarombek
Date: 4/27/2019
"""

import boto3

iam = boto3.client('iam')


def admin_group_exists() -> bool:
    """
    Test that the 'admin-group' IAM Group exists
    :return: True if it exists, False otherwise
    """
    group_dict = iam.get_group(GroupName='admin-group')
    group = group_dict.get('Group')
    return group.get('Path') == '/admin/' and group.get('GroupName') == 'admin-group'


def andy_user_exists() -> bool:
    """
    Test that the 'andy-user' IAM User exists
    :return: True if it exists, False otherwise
    """
    user_dict = iam.get_user(UserName='andy-user')
    user = user_dict.get('User')
    print(user)
    return user.get('Path') == '/admin/' and user.get('UserName') == 'andy-user'


def andy_admin_group_membership() -> bool:
    """
    Test that the IAM User 'andy-user' is a member of the IAM Group 'admin-group'
    :return: True if 'andy-user' is a member, False otherwise
    """
    group_dict = iam.get_group(GroupName='admin-group')
    group = group_dict.get('Group')
    member = group.get('Users')[0]
    return member.get('Path') == '/admin/' and member.get('UserName') == 'andy-user'


def jenkins_role_exists() -> bool:
    """
    Test that the jenkins-role IAM Role exists
    :return: True if the IAM role exists, False otherwise
    """
    role_dict = iam.get_role(RoleName='jenkins-role')
    role = role_dict.get('Role')
    return role.get('Path') == '/admin/' and role.get('RoleName') == 'jenkins-role'


def admin_policy_attached() -> bool:
    """
    Test that the admin-policy is attached to the jenkins-role
    :return: True if the policy is attached to the role, False otherwise
    """
    policy_response = iam.list_attached_role_policies(RoleName='jenkins-role')
    policies = policy_response.get('AttachedPolicies')
    admin_policy = policies[1]
    return len(policies) == 2 and admin_policy.get('PolicyName') == 'admin-policy'


def elastic_ip_policy_attached() -> bool:
    """
    Test that the elastic-ip-policy is attached to the jenkins-role
    :return: True if the policy is attached to the role, False otherwise
    """
    policy_response = iam.list_attached_role_policies(RoleName='jenkins-role')
    policies = policy_response.get('AttachedPolicies')
    elastic_ip_policy = policies[0]
    return len(policies) == 2 and elastic_ip_policy.get('PolicyName') == 'elastic-ip-policy'
