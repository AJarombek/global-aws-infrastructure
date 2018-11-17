/**
 * Module for creating a VPC
 * Author: Andrew Jarombek
 * Date: 11/4/2018
 */

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = "${var.enable_dns_support}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags {
    Name = "${var.tag_name} VPC"
  }
}

resource "aws_subnet" "public-subnet" {
  cidr_block = "${var.public_subnet_cidr}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.tag_name} VPC Public Subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  cidr_block = "${var.private_subnet_cidr}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.tag_name} VPC Private Subnet"
  }
}

resource "aws_internet_gateway" "resources-vpc-igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.tag_name} VPC Internet Gateway"
  }
}

resource "aws_route_table" "routing_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "${var.routing_table_cidr}"
    gateway_id = "${aws_internet_gateway.resources-vpc-igw.id}"
  }

  tags {
    Name = "${var.tag_name} VPC Public Subnet RT"
  }
}

resource "aws_route_table_association" "routing_table_association" {
  route_table_id = "${aws_route_table.routing_table.id}"
  subnet_id = "${aws_subnet.public-subnet.id}"
}

resource "aws_security_group" "public_subnet_security" {
  name = "${var.name}-vpc-public-security"
  description = "Allow all incoming connections to public resources"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP is used for sending error messages or operational information.  ICMP has no ports,
  # and a common tool that uses ICMP is ping.
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
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

  tags {
    Name = "${var.tag_name} VPC Public Subnet Security"
  }
}

resource "aws_security_group" "private-subnet-security" {
  name = "${var.name}-vpc-private-security"
  description = "Allow traffic only from the public subnet"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    # Default port for MongoDB
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    # Ports MongoDB uses to communicate between servers
    from_port = 27019
    to_port = 27019
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  tags {
    Name = "${var.tag_name} VPC Private Subnet Security"
  }
}