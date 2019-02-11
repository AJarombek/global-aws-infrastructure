/**
 * Module for creating a VPC
 * Author: Andrew Jarombek
 * Date: 11/4/2018
 */

locals {
  nat_gateway = "${var.enable_nat_gateway ? 1 : 0}"
  public_security_group = "${var.enable_public_security_group ? 1 : 0}"
  private_security_group = "${var.enable_private_security_group ? 1 : 0}"

  # The number of private subnets that use a Nat Gateway
  private_subnet_with_nat = "${var.enable_nat_gateway ? "${var.private_subnet_count}" : 0}"

  multiple_public_subnets = "${var.public_subnet_count > 1}"
  multiple_private_subnets = "${var.private_subnet_count > 1}"
}

#----------------------
# General VPC Resources
#----------------------

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
  count = "${var.public_subnet_count}"

  cidr_block = "${local.multiple_public_subnets ?
                    element(var.public_subnet_cidrs, count.index) : var.public_subnet_cidr}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.tag_name} VPC Public Subnet ${local.multiple_public_subnets ? count.index : ""}"
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
  count = "${var.public_subnet_count}"

  route_table_id = "${aws_route_table.routing-table-public.id}"
  subnet_id = "${aws_subnet.public-subnet.*.id[count.index]}"
}

resource "aws_security_group" "public-subnet-security" {
  count = "${local.public_security_group}"

  name = "${var.name}-vpc-public-security"
  description = "Allow all incoming connections to public resources"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.tag_name} VPC Public Subnet Security"
  }
}

resource "aws_security_group_rule" "public-subnet-security-rule" {
  count = "${length(var.public_subnet_sg_rules)}"

  security_group_id = "${aws_security_group.public-subnet-security.id}"
  type = "${lookup(var.public_subnet_sg_rules[count.index], "type", "ingress")}"

  from_port = "${lookup(var.public_subnet_sg_rules[count.index], "from_port", 0)}"
  to_port = "${lookup(var.public_subnet_sg_rules[count.index], "to_port", 0)}"
  protocol = "${lookup(var.public_subnet_sg_rules[count.index], "protocol", "-1")}"

  cidr_blocks = "${lookup(var.public_subnet_sg_rules[count.index], "cidr_blocks", list())}"
}

#---------------
# Private Subnet
#---------------

resource "aws_subnet" "private-subnet" {
  count = "${var.private_subnet_count}"

  cidr_block = "${local.multiple_private_subnets ?
                    element(var.private_subnet_cidrs, count.index) : var.private_subnet_cidr}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.tag_name} VPC Private Subnet ${local.multiple_private_subnets ? count.index : ""}"
  }
}

resource "aws_route_table" "routing-table-private" {
  count = "${local.nat_gateway}"

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
  count = "${local.nat_gateway}"

  vpc = true
}

resource "aws_nat_gateway" "nat-gateway" {
  count = "${local.nat_gateway}"

  allocation_id = "${aws_eip.nat-elastic-ip.id}"
  subnet_id = "${aws_subnet.public-subnet.id}"
  depends_on = ["aws_internet_gateway.vpc-igw"]
}

resource "aws_route_table_association" "routing-table-association-private" {
  count = "${local.private_subnet_with_nat}"

  route_table_id = "${aws_route_table.routing-table-private.id}"
  subnet_id = "${aws_subnet.private-subnet.*.id[count.index]}"
}

resource "aws_security_group" "private-subnet-security" {
  count = "${local.private_security_group}"

  name = "${var.name}-vpc-private-security"
  description = "Allow traffic only from the public subnet"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.tag_name} VPC Private Subnet Security"
  }
}

resource "aws_security_group_rule" "private-subnet-security-rule" {
  count = "${length(var.private_subnet_sg_rules)}"

  security_group_id = "${aws_security_group.private-subnet-security.id}"
  type = "${lookup(var.private_subnet_sg_rules[count.index], "type", "ingress")}"

  from_port = "${lookup(var.private_subnet_sg_rules[count.index], "from_port", 0)}"
  to_port = "${lookup(var.private_subnet_sg_rules[count.index], "to_port", 0)}"
  protocol = "${lookup(var.private_subnet_sg_rules[count.index], "protocol", "-1")}"

  cidr_blocks = "${lookup(var.private_subnet_sg_rules[count.index], "cidr_blocks", list())}"
}