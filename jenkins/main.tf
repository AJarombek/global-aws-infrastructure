/**
 * AWS Infrastructure for the global Jenkins server
 * Author: Andrew Jarombek
 * Date: 11/11/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/jenkins"
    region  = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

# Retrieve the custom baked AMI for the jenkins server
data "aws_ami" "jenkins-ami" {
  # If more than one result matches the filters, use the most recent AMI
  most_recent = true

  filter {
    name   = "name"
    values = ["global-jenkins-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["739088120071"]
}

# Security group for the resources VPC
data "aws_security_group" "vpc-security-group" {
  filter {
    name   = "group-name"
    values = ["resources-vpc-security"]
  }
}

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

data "aws_efs_file_system" "jenkins-efs" {
  tags = {
    Name = "jenkins-efs"
  }
}

data "aws_region" "current" {}

# Load a bash file that starts up a Jenkins server
data "template_file" "jenkins-startup" {
  template = file("jenkins-setup.sh")

  vars = {
    MOUNT_TARGET   = data.aws_efs_file_system.jenkins-efs.dns_name
    MOUNT_LOCATION = "/var/lib/jenkins"
    REGION         = data.aws_region.current.name
    ALLOCATION_ID  = aws_eip.jenkins-server-eip.id
  }
}

data "aws_iam_role" "jenkins-server-role" {
  name = "jenkins-role"
}

#--------------------------------------
# Executed Before Resources are Created
#--------------------------------------

/* Generate a SSH key used to connect to the Jenkins server from my local machine */
resource "null_resource" "key-gen" {
  provisioner "local-exec" {
    command = "bash key-gen.sh jenkins-key"
  }
}

#------------------------------
# New AWS Resources for Jenkins
#------------------------------

resource "aws_iam_instance_profile" "jenkins-instance-profile" {
  name = "global-jenkis-server-instance-profile"
  role = data.aws_iam_role.jenkins-server-role.name
}

resource "aws_eip" "jenkins-server-eip" {
  vpc = true

  tags = {
    Name        = "global-jenkins-server-eip"
    Application = "jenkins-jarombek-io"
  }
}

resource "aws_launch_configuration" "jenkins-server-lc" {
  name                        = "global-jenkins-server-lc"
  image_id                    = data.aws_ami.jenkins-ami.id
  instance_type               = "t2.micro"
  key_name                    = "jenkins-key"
  security_groups             = [aws_security_group.jenkins-server-lc-security-group.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.jenkins-instance-profile.name

  # Script to run during instance startup
  user_data = data.template_file.jenkins-startup.rendered

  lifecycle {
    # Create a replacement before destroying
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jenkins-server-asg" {
  name                 = "global-jenkins-server-asg"
  launch_configuration = aws_launch_configuration.jenkins-server-lc.id

  # Needed when using an autoscaling group in a VPC
  vpc_zone_identifier = [data.aws_subnet.resources-vpc-public-subnet.id]

  max_size         = var.max_size_on
  min_size         = var.min_size_on
  desired_capacity = var.desired_capacity_on

  load_balancers            = [aws_elb.jenkins-server-elb.id]
  health_check_type         = "ELB"
  health_check_grace_period = 600

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "global-jenkins-server-asg"
  }

  tag {
    key                 = "Application"
    propagate_at_launch = false
    value               = "jenkins-jarombek-io"
  }
}

resource "aws_autoscaling_schedule" "jenkins-server-asg-online-weekday" {
  autoscaling_group_name = aws_autoscaling_group.jenkins-server-asg.name
  scheduled_action_name  = "jenkins-server-online-weekday"

  max_size         = var.max_size_on
  min_size         = var.min_size_on
  desired_capacity = var.desired_capacity_on

  recurrence = var.online_cron_weekday
}

resource "aws_autoscaling_schedule" "jenkins-server-asg-offline-weekday" {
  autoscaling_group_name = aws_autoscaling_group.jenkins-server-asg.name
  scheduled_action_name  = "jenkins-server-offline-weekday"

  max_size         = var.max_size_off
  min_size         = var.min_size_off
  desired_capacity = var.desired_capacity_off

  recurrence = var.offline_cron_weekday
}

resource "aws_autoscaling_schedule" "jenkins-server-asg-online-weekend" {
  autoscaling_group_name = aws_autoscaling_group.jenkins-server-asg.name
  scheduled_action_name  = "jenkins-server-online-weekend"

  max_size         = var.max_size_on
  min_size         = var.min_size_on
  desired_capacity = var.desired_capacity_on

  recurrence = var.online_cron_weekend
}

resource "aws_autoscaling_schedule" "jenkins-server-asg-offline-weekend" {
  autoscaling_group_name = aws_autoscaling_group.jenkins-server-asg.name
  scheduled_action_name  = "jenkins-server-offline-weekend"

  max_size         = var.max_size_off
  min_size         = var.min_size_off
  desired_capacity = var.desired_capacity_off

  recurrence = var.offline_cron_weekend
}

resource "aws_elb" "jenkins-server-elb" {
  name = "global-jenkins-server-elb"

  # Required for an Elastic Load Balancer in a VPC
  subnets = [data.aws_subnet.resources-vpc-public-subnet.id]

  security_groups = [
    aws_security_group.jenkins-server-lb-security-group.id,
    data.aws_security_group.vpc-security-group.id,
  ]

  listener {
    instance_port     = var.instance_port
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "TCP:${var.instance_port}"
  }

  tags = {
    Name        = "global-jenkins-server-elb"
    Application = "jenkins-jarombek-io"
  }
}

resource "aws_security_group" "jenkins-server-lc-security-group" {
  name   = "global-jenkins-server-lc-security-group"
  vpc_id = data.aws_vpc.resources-vpc.id

  ingress {
    from_port   = var.instance_port
    protocol    = "tcp"
    to_port     = var.instance_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 443 needs to be open for Terraform
  egress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 465
    protocol    = "tcp"
    to_port     = 465
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 2049
    protocol    = "tcp"
    to_port     = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 9418
    protocol    = "tcp"
    to_port     = 9418
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "global-jenkins-server-lc-security-group"
    Application = "jenkins-jarombek-io"
  }
}

resource "aws_security_group" "jenkins-server-lb-security-group" {
  name   = "global-jenkins-server-lb-security-group"
  vpc_id = data.aws_vpc.resources-vpc.id

  # Outbound requests for health checks
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "global-jenkins-server-elb-security-group"
    Application = "jenkins-jarombek-io"
  }
}