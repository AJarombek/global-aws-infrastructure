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

# Security group for the resources VPC
data "aws_security_group" "public-subnet-security-group" {
  filter {
    name = "group-name"
    values = ["resources-vpc-public-security"]
  }
}

data "aws_vpc" "resources-vpc" {
  tags {
    Name = "Resources VPC"
  }
}

data "aws_subnet" "resources-vpc-public-subnet" {
  tags {
    Name = "Resources VPC Public Subnet"
  }
}

data "aws_efs_file_system" "jenkins-efs" {
  tags {
    Name = "Jenkins EFS"
  }
}

# Load a bash file that starts up a Jenkins server
data "template_file" "jenkins-startup" {
  template = "${file("jenkins-setup.sh")}"

  vars {
    MOUNT_TARGET = "${data.aws_efs_file_system.jenkins-efs.dns_name}"
    MOUNT_LOCATION = "/mnt/efs/JENKINS_HOME"
  }
}

resource "aws_launch_configuration" "jenkins-server-lc" {
  name = "global-jenkins-server-lc"
  image_id = "${data.aws_ami.jenkins-ami.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.jenkins-server-lc-security-group.id}"]
  associate_public_ip_address = true

  # Script to run during instance startup
  user_data = "${data.template_file.jenkins-startup.rendered}"

  lifecycle {
    # Create a replacement before destroying
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jenkins-server-asg" {
  launch_configuration = "${aws_launch_configuration.jenkins-server-lc.id}"

  # Needed when using an autoscaling group in a VPC
  vpc_zone_identifier = ["${data.aws_subnet.resources-vpc-public-subnet.id}"]

  max_size = "${var.max_size}"
  min_size = "${var.min_size}"

  load_balancers = ["${aws_elb.jenkins-server-elb.id}"]
  health_check_type = "ELB"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "global-jenkins-server-asg"
  }
}

resource "aws_elb" "jenkins-server-elb" {
  name = "global-jenkins-server-elb"

  # Required for an Elastic Load Balancer in a VPC
  subnets = ["${data.aws_subnet.resources-vpc-public-subnet.id}"]

  security_groups = [
    "${aws_security_group.jenkins-server-elb-security-group.id}",
    "${data.aws_security_group.public-subnet-security-group.id}"
  ]

  listener {
    instance_port = "${var.instance_port}"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "TCP:${var.instance_port}"
  }

  tags {
    Name = "global-jenkins-server-elb"
  }
}

resource "aws_security_group" "jenkins-server-lc-security-group" {
  name = "global-jenkins-server-lc-security-group"
  vpc_id = "${data.aws_vpc.resources-vpc.id}"

  ingress {
    from_port = "${var.instance_port}"
    protocol = "tcp"
    to_port = "${var.instance_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 2049
    protocol = "tcp"
    to_port = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "jenkins-server-elb-security-group" {
  name = "global-jenkins-server-elb-security-group"
  vpc_id = "${data.aws_vpc.resources-vpc.id}"

  # Outbound requests for health checks
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}