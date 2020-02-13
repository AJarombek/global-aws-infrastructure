"""
Functions which represent Unit tests for the Jenkins server infrastructure
Author: Andrew Jarombek
Date: 4/27/2019
"""

import unittest

import boto3
from test.utils.ec2 import EC2
from test.utils.securityGroup import SecurityGroup


class TestJenkins(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ec2 = boto3.client('ec2')
        self.sts = boto3.client('sts')
        self.iam = boto3.client('iam')
        self.autoscaling = boto3.client('autoscaling')
        
    def test_ami_exists(self) -> None:
        """
        Check if there are one or many AMIs for the Jenkins server.
        """
        owner = self.sts.get_caller_identity().get('Account')
        amis = self.ec2.describe_images(
            Owners=[owner],
            Filters=[{
                'Name': 'name',
                'Values': ['global-jenkins-server*']
            }]
        )
        self.assertTrue(len(amis.get('Images')) > 0)

    def test_jenkins_server_running(self) -> None:
        """
        Validate that the EC2 instance(s) holding the Jenkins server are running
        """
        instances = EC2.get_ec2('global-jenkins-server-asg')
        self.assertTrue(len(instances) > 0)

    def test_jenkins_server_not_overscaled(self) -> None:
        """
        Ensure that there aren't too many EC2 instances running for the Jenkins server
        """
        instances = EC2.get_ec2('global-jenkins-server-asg')
        self.assertTrue(len(instances) < 2)

    def test_jenkins_instance_profile_exists(self) -> None:
        """
        Prove that the instance profile exists for the Jenkins server
        """
        self.assertTrue(EC2.instance_profile_valid(
            instance_profile_name='global-jenkis-server-instance-profile',
            asg_name='global-jenkins-server-asg',
            iam_role_name='jenkins-role'
        ))

    def test_jenkins_launch_config_valid(self) -> None:
        """
        Ensure that the Launch Configuration for the Jenkins server is valid
        """
        self.assertTrue(EC2.launch_config_valid(
            launch_config_name='global-jenkins-server-lc',
            asg_name='global-jenkins-server-asg',
            expected_instance_type='t2.micro',
            expected_key_name='jenkins-key',
            expected_sg_count=1,
            expected_instance_profile='global-jenkis-server-instance-profile'
        ))
    
    def test_jenkins_launch_config_sg_valid(self) -> None:
        """
        Ensure that the security group attached to the launch configuration is as expected
        """
        lcs = self.autoscaling.describe_launch_configurations(
            LaunchConfigurationNames=['global-jenkins-server-lc'],
            MaxRecords=1
        )
    
        try:
            launch_config = lcs.get('LaunchConfigurations')[0]
        except IndexError:
            self.assertTrue(False)
            return
    
        sg_id = launch_config.get('SecurityGroups')[0]
        sg = self.ec2.describe_security_groups(GroupIds=[sg_id]).get('SecurityGroups')[0]
    
        ingress = sg.get('IpPermissions')
        egress = sg.get('IpPermissionsEgress')
    
        ingress_80 = SecurityGroup.validate_sg_rule_cidr(ingress[0], 'tcp', 80, 80, '0.0.0.0/0')
        ingress_22 = SecurityGroup.validate_sg_rule_cidr(ingress[1], 'tcp', 22, 22, '0.0.0.0/0')
    
        egress_80 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 80, 80, '0.0.0.0/0')
        egress_22 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 22, 22, '0.0.0.0/0')
        egress_443 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 443, 443, '0.0.0.0/0')
        egress_2049 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 2049, 2049, '0.0.0.0/0')
    
        self.assertTrue(all([
            sg.get('GroupName') == 'global-jenkins-server-lc-security-group',
            len(ingress) == 2,
            ingress_80,
            ingress_22,
            len(egress) == 4,
            egress_80,
            egress_22,
            egress_443,
            egress_2049
        ]))

    def test_jenkins_autoscaling_group_valid(self) -> None:
        """
        Ensure that the AutoScaling Group for the Jenkins server is valid
        """
        self.assertTrue(EC2.autoscaling_group_valid(
            asg_name='global-jenkins-server-asg',
            launch_config_name='global-jenkins-server-lc',
            min_size=1,
            max_size=1,
            desired_size=1,
            instance_count=1
        ))

    def test_jenkins_autoscaling_schedules_set(self) -> None:
        """
        Make sure the autoscaling schedules exist as expected for the Jenkins server
        (the ASG should be down in non-work hours)
        """
        self.assertTrue(all([
            EC2.autoscaling_schedule_valid(
                asg_name='global-jenkins-server-asg',
                schedule_name='jenkins-server-online-morning',
                recurrence='0 11 * * *',
                max_size=1,
                min_size=1,
                desired_size=1
            ),
            EC2.autoscaling_schedule_valid(
                asg_name='global-jenkins-server-asg',
                schedule_name='jenkins-server-offline-morning',
                recurrence='0 12 * * *',
                max_size=0,
                min_size=0,
                desired_size=0),
            EC2.autoscaling_schedule_valid(
                asg_name='global-jenkins-server-asg',
                schedule_name='jenkins-server-online-evening',
                recurrence='0 22 * * *',
                max_size=1,
                min_size=1,
                desired_size=1
            ),
            EC2.autoscaling_schedule_valid(
                asg_name='global-jenkins-server-asg',
                schedule_name='jenkins-server-offline-evening',
                recurrence='0 23 * * *',
                max_size=0,
                min_size=0,
                desired_size=0
            )
        ]))
    
    def test_jenkins_load_balancer_valid(self) -> None:
        """
        Prove that the application load balancer for the Jenkins server is running
        """
        self.assertTrue(EC2.load_balancer_target_groups_valid(
            asg_name='global-jenkins-server-asg',
            load_balancer_target_group_names=[]
        ))

    def test_jenkins_load_balancer_sg_valid(self) -> None:
        """
        Ensure that the security group attached to the Jenkins server load balancer is as expected
        """
        try:
            sg = SecurityGroup.get_security_groups('global-jenkins-server-lb-security-group')[0]
        except IndexError:
            self.assertTrue(False)
            return
    
        ingress = sg.get('IpPermissions')
        egress = sg.get('IpPermissionsEgress')
    
        egress_80 = SecurityGroup.validate_sg_rule_cidr(egress[0], 'tcp', 80, 80, '0.0.0.0/0')
        egress_22 = SecurityGroup.validate_sg_rule_cidr(egress[1], 'tcp', 22, 22, '0.0.0.0/0')
        egress_2049 = SecurityGroup.validate_sg_rule_cidr(egress[3], '-1', 0, 0, '0.0.0.0/0')
        egress_443 = SecurityGroup.validate_sg_rule_cidr(egress[2], 'tcp', 443, 443, '0.0.0.0/0')
    
        self.assertTrue(all([
            len(ingress) == 0,
            len(egress) == 4,
            egress_80,
            egress_22,
            egress_2049,
            egress_443
        ]))
