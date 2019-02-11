/**
 * Module for creating a Security Group
 * Author: Andrew Jarombek
 * Date: 2/11/2019
 */

resource "aws_security_group" "public-subnet-security" {
  name = "${var.name}"
  description = "Allow all incoming connections to public resources"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.tag_name}"
  }
}

resource "aws_security_group_rule" "public-subnet-security-rule" {
  count = "${length(var.sg_rules)}"

  security_group_id = "${aws_security_group.public-subnet-security.id}"
  type = "${lookup(var.sg_rules[count.index], "type", "ingress")}"

  from_port = "${lookup(var.sg_rules[count.index], "from_port", 0)}"
  to_port = "${lookup(var.sg_rules[count.index], "to_port", 0)}"
  protocol = "${lookup(var.sg_rules[count.index], "protocol", "-1")}"

  cidr_blocks = "${lookup(var.sg_rules[count.index], "cidr_blocks", list())}"
}