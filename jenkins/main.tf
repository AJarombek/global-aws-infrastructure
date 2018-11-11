/**
 * AWS Infrastructure for the global Jenkins server
 * Author: Andrew Jarombek
 * Date: 11/11/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/jenkins"
    region = "us-east-1"
  }
}

# Fetch the availability zones for this account
data "aws_availability_zones" "all" {}

# Retrieve the custom baked AMI for the jenkins server
data "aws_ami" "jenkins-ami" {
  # If more than one result matches the filters, use the most recent AMI
  most_recent = true

  filter {
    name = "name"
    values = ["global-jenkins-server*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["739088120071"]
}

resource "aws_launch_configuration" "jenkins-server-lc" {
  image_id = "${data.aws_ami.jenkins-ami.id}"
  instance_type = "t2.micro"
  security_groups = ["${}"]

  lifecycle {
    # Create a replacement before destroying
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jenkins-server-asg" {
  launch_configuration = "${aws_launch_configuration.jenkins-server-lc.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  max_size = "${var.max_size}"
  min_size = "${var.min_size}"

  health_check_type = "ELB"

  lifecycle {
    create_before_destroy = true
  }
}