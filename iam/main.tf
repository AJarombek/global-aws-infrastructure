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

resource "aws_iam_group" "admin-group" {
  name = "admin-group"
  path = "/admin/"
}

resource "aws_iam_user" "jenkins-user" {
  name = "jenkins-user"
  path = "/admin/"
}

resource "aws_iam_user_group_membership" "jenkins-user-groups" {
  groups = ["${aws_iam_group.admin-group.id}"]
  user = "${aws_iam_user.jenkins-user.id}"
}

resource "aws_iam_user_policy" "jenkins-user-policy" {
  name = "jenkins-user-policy"
  user = "${aws_iam_user.jenkins-user.id}"
  policy = "${file("jenkins-user-policy.json")}"
}