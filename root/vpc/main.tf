# Module for creating a VPC
# Author: Andrew Jarombek
# Date: 11/4/2018

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "${var.vpc_tag_name}"
  }
}

resource "aws_subnet" "public-subnet" {
  cidr_block = "${var.public_subnet_cidr}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.public_subnet_tag_name}"
  }
}

resource "aws_subnet" "resources-private-subnet" {
  cidr_block = "${var.private_subnet_cidr}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.private_subnet_tag_name}"
  }
}

resource "aws_internet_gateway" "resources-vpc-igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.internet_gateway_tag_name}"
  }
}