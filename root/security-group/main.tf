/**
 * Module for creating a Security Group
 * Author: Andrew Jarombek
 * Date: 2/11/2019
 */

locals {
  count = "${var.enabled ? 1 : 0}"
}

resource "aws_security_group" "security" {
  count = "${local.count}"

  name = "${var.name}"
  description = "${var.description}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.tag_name}"
  }
}

resource "aws_security_group_rule" "security-rule" {
  count = "${length(var.sg_rules)}"

  security_group_id = "${aws_security_group.security.id}"
  type = "${lookup(var.sg_rules[count.index], "type", "ingress")}"

  from_port = "${lookup(var.sg_rules[count.index], "from_port", 0)}"
  to_port = "${lookup(var.sg_rules[count.index], "to_port", 0)}"
  protocol = "${lookup(var.sg_rules[count.index], "protocol", "-1")}"

  cidr_blocks = ["${lookup(var.sg_rules[count.index], "cidr_blocks", "")}"]
}