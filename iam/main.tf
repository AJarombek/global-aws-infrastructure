/**
 * IAM Policies, Groups, and Users for my cloud
 * Author: Andrew Jarombek
 * Date: 11/19/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/iam"
    region  = "us-east-1"
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
  groups = [aws_iam_group.admin-group.id]
  user   = aws_iam_user.andy-user.id
}

resource "aws_iam_user_policy" "andy-user-policy" {
  name   = "andy-user-policy"
  user   = aws_iam_user.andy-user.id
  policy = file("policies/andy-user-policy.json")
}

# ---------
# IAM Roles
# ---------

resource "aws_iam_role" "jenkins-role" {
  name               = "jenkins-role"
  path               = "/admin/"
  assume_role_policy = file("policies/assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "jenkins-role-admin-policy" {
  policy_arn = aws_iam_policy.admin-policy.arn
  role       = aws_iam_role.jenkins-role.name
}

resource "aws_iam_role_policy_attachment" "jenkins-role-elastic-ip-policy" {
  policy_arn = aws_iam_policy.elastic-ip-policy.arn
  role       = aws_iam_role.jenkins-role.name
}

# ------------
# IAM Policies
# ------------

resource "aws_iam_policy" "admin-policy" {
  name   = "admin-policy"
  path   = "/admin/"
  policy = file("policies/admin-policy.json")
}

resource "aws_iam_policy" "elastic-ip-policy" {
  name   = "elastic-ip-policy"
  path   = "/resource/"
  policy = file("policies/elastic-ip-policy.json")
}