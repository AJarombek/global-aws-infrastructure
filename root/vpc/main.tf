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

resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.tag_name} VPC Internet Gateway"
  }
}

resource "aws_network_acl" "network-acl" {
  vpc_id = "${aws_vpc.vpc.id}"

  egress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
    protocol = "-1"
    rule_no = 10
  }

  ingress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
    protocol = "-1"
    rule_no = 20
  }

  tags {
    Name = "${var.tag_name} ACL"
  }
}

# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_DHCP_Options.html
resource "aws_vpc_dhcp_options" "vpc-dns-resolver" {
  domain_name_servers = ["AmazonProvidedDNS"]
  domain_name = "ec2.internal"

  tags {
    Name = "${var.tag_name} DHCP Options"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc-dns-resolver-association" {
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc-dns-resolver.id}"
  vpc_id = "${aws_vpc.vpc.id}"
}

#--------------
# Public Subnet
#--------------

resource "aws_subnet" "public-subnet" {
  cidr_block = "${var.public_subnet_cidr}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.tag_name} VPC Public Subnet"
  }
}

resource "aws_route_table" "routing-table-public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "${var.routing_table_cidr}"
    gateway_id = "${aws_internet_gateway.vpc-igw.id}"
  }

  tags {
    Name = "${var.tag_name} VPC Public Subnet RT"
  }
}

resource "aws_route_table_association" "routing-table-association-public" {
  route_table_id = "${aws_route_table.routing-table-public.id}"
  subnet_id = "${aws_subnet.public-subnet.id}"
}

resource "aws_security_group" "public-subnet-security" {
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
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.tag_name} VPC Public Subnet Security"
  }
}

#---------------
# Private Subnet
#---------------

resource "aws_subnet" "private-subnet" {
  cidr_block = "${var.private_subnet_cidr}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.tag_name} VPC Private Subnet"
  }
}

resource "aws_route_table" "routing-table-private" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "${var.routing_table_cidr}"
    nat_gateway_id = "${aws_nat_gateway.nat-gateway.id}"
  }

  tags {
    Name = "${var.tag_name} VPC Private Subnet RT"
  }
}

resource "aws_eip" "nat-elastic-ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = "${aws_eip.nat-elastic-ip.id}"
  subnet_id = "${aws_subnet.public-subnet.id}"
  depends_on = ["aws_internet_gateway.vpc-igw"]
}

resource "aws_route_table_association" "routing-table-association-private" {
  route_table_id = "${aws_route_table.routing-table-private.id}"
  subnet_id = "${aws_subnet.private-subnet.id}"
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

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.tag_name} VPC Private Subnet Security"
  }
}