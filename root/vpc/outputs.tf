/**
 * Output variables for a created VPC
 * Author: Andrew Jarombek
 * Date: 11/4/2018
 */

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}