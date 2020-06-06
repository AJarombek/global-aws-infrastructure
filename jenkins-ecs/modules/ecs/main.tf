/**
 * ECS cluster for a Jenkins server.
 * Author: Andrew Jarombek
 * Date: 6/5/2020
 */

locals {
  env = var.prod ? "prod" : "dev"
  env_tag = var.prod ? "production" : "development"
  container_def = var.prod ? "jenkins-jarombek-io.json" : "dev-jenkins-jarombek-io.json"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_caller_identity" "current" {}

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

data "aws_iam_role" "ecs-task-role" {
  name = "ecs-task-role"
}

data "template_file" "container-definition" {
  template = file("${path.module}/${local.container_def}")

  vars = {
    ACCOUNT_ID = data.aws_caller_identity.current.account_id
  }
}

#---------------------
# ECS Cluser Resources
#---------------------

resource "aws_ecs_cluster" "jenkins-jarombek-io-ecs-cluster" {
  name = "jenkins-jarombek-io-${local.env}-ecs-cluster"

  tags = {
    Name = "jenkins-jarombek-io-${local.env}-ecs-cluster"
    Application = "jenkins-jarombek-io"
    Environment = local.env_tag
  }
}

resource "aws_cloudwatch_log_group" "jenkins-jarombek-io-ecs-task-logs" {
  name = "/ecs/fargate-tasks"
  retention_in_days = 7

  tags = {
    Name = "ecs-fargate-tasks"
    Application = "jenkins-jarombek-io"
    Environment = local.env_tag
  }
}

resource "aws_ecs_task_definition" "jenkins-jarombek-io-task" {
  family = "jenkins-jarombek-io"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = data.aws_iam_role.ecs-task-role.arn
  cpu = 256
  memory = 512

  container_definitions = file("${path.module}/container-def/${local.container_def}")

  tags = {
    Name = "jenkins-jarombek-io-ecs-${local.env}-task"
    Application = "jenkins-jarombek-io"
    Environment = local.env_tag
  }

  depends_on = [
    var.ecs_depends_on,
    aws_cloudwatch_log_group.jenkins-jarombek-io-ecs-task-logs
  ]
}

resource "aws_ecs_service" "jenkins-jarombek-io-service" {
  name = "jenkins-jarombek-io-ecs-${local.env}-service"
  cluster = aws_ecs_cluster.jenkins-jarombek-io-ecs-cluster.id
  task_definition = aws_ecs_task_definition.jenkins-jarombek-io-task.arn
  desired_count = var.jenkins-jarombek-io-desired-count
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.jenkins-jarombek-io-ecs-sg.id]
    subnets = [data.aws_subnet.resources-vpc-public-subnet.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.jenkins-jarombek-io-lb-target-group
    container_name = "jenkins-jarombek-io"
    container_port = 8080
  }

  tags = {
    Name = "jenkins-jarombek-io-ecs-${local.env}-service"
    Application = "jenkins-jarombek-io"
    Environment = local.env_tag
  }

  depends_on = [var.ecs_depends_on]
}

resource "aws_security_group" "jenkins-jarombek-io-ecs-sg" {
  name = "jenkins-jarombek-io-${local.env}-ecs-security-group"
  vpc_id = data.aws_vpc.resources-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-jarombek-io-${local.env}-ecs-security-group"
    Application = "jenkins-jarombek-io"
    Environment = local.env_tag
  }
}