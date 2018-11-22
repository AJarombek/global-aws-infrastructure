/**
 * IAM Policies, Groups, and Users for my cloud
 * Author: Andrew Jarombek
 * Date: 11/19/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/iam"
    region = "us-east-1"
  }
}

# ----------
# IAM Groups
# ----------

resource "aws_iam_group" "admin-group" {
  name = "admin-group"
  path = "/admin/"
}

# ---------
# IAM Users
# ---------

resource "aws_iam_user" "andy-user" {
  name = "andy-user"
  path = "/admin/"
}

resource "aws_iam_user_group_membership" "jenkins-user-groups" {
  groups = ["${aws_iam_group.admin-group.id}"]
  user = "${aws_iam_user.andy-user.id}"
}

resource "aws_iam_user_policy" "andy-user-policy" {
  name = "andy-user-policy"
  user = "${aws_iam_user.andy-user.id}"
  policy = "${file("policies/andy-user-policy.json")}"
}

# ---------
# IAM Roles
# ---------

resource "aws_iam_role" "jenkins-role" {
  name = "jenkins-role"
  path = "/admin/"
  assume_role_policy = "${file("policies/jenkins-assume-role-policy.json")}"
}

resource "aws_iam_role_policy" "jenkins-role-policy" {
  policy = "${file("policies/jenkins-role-policy.json")}"
  role = "${aws_iam_role.jenkins-role.id}"
}