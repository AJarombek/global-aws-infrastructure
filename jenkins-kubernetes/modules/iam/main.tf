/**
 * IAM Policies and Roles for the jenkins.jarombek.io application infrastructure
 * Author: Andrew Jarombek
 * Date: 6/5/2020
 */

locals {
  env = var.prod ? "prod" : "dev"
}

resource "aws_iam_role" "ecs-task-role" {
  name = "ecs-task-role-${local.env}"
  path = "/jenkins-jarombek-io/"
  assume_role_policy = file("${path.module}/ecs-task-role.json")
}

resource "aws_iam_policy" "ecs-task-policy" {
  name = "ecs-task-policy-${local.env}"
  path = "/jenkins-jarombek-io/"
  policy = file("${path.module}/ecs-task-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy" {
  policy_arn = aws_iam_policy.ecs-task-policy.arn
  role = aws_iam_role.ecs-task-role.name
}
