/**
 * AWS Infrastructure for the EFS used in the Jenkins server
 * Author: Andrew Jarombek
 * Date: 11/17/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/jenkins-efs"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_vpc" "resources-vpc" {
  tags = {
    Name = "resources-vpc"
  }
}

data "aws_subnet" "resources-vpc-public-subnet" {
  tags = {
    Name = "resources-vpc-public-subnet"
  }
}

#----------------------------------
# New AWS Resources for Jenkins EFS
#----------------------------------

resource "aws_efs_file_system" "jenkins-efs" {
  creation_token = "jenkins-fs"

  tags = {
    Name = "jenkins-efs"
  }
}

resource "aws_security_group" "jenkins-efs-security" {
  name = "jenkins-efs-security"
  description = "Allow NFS traffic from instances within the VPC"
  vpc_id = data.aws_vpc.resources-vpc.id

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = [data.aws_vpc.resources-vpc.cidr_block]
  }

  egress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = [data.aws_vpc.resources-vpc.cidr_block]
  }

  tags = {
    Name = "jenkins-efs-security"
  }
}

resource "aws_efs_mount_target" "jenkins-efs-mount" {
  file_system_id = aws_efs_file_system.jenkins-efs.id
  subnet_id = data.aws_subnet.resources-vpc-public-subnet.id
  security_groups = [aws_security_group.jenkins-efs-security.id]
}