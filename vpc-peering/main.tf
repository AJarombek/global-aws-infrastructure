/**
 * Infrastructure for VPC Peering connections between my cloud's VPCs.
 * NOTE: This currently is just a reference for how VPC peering works.  The infrastructure was refactored so that VPC
 * peering would not be needed.
 * Author: Andrew Jarombek
 * Date: 9/13/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.7.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/vpc-peering"
    region  = "us-east-1"
  }
}

data "aws_vpc" "kubernetes-vpc" {
  tags = {
    Name = "kubernetes-vpc"
  }
}

data "aws_vpc" "saints-xctf-com-vpc" {
  tags = {
    Name = "saints-xctf-com-vpc"
  }
}

resource "aws_vpc_peering_connection" "saints-xctf-and-kubernetes" {
  peer_vpc_id = data.aws_vpc.saints-xctf-com-vpc.id
  vpc_id      = data.aws_vpc.kubernetes-vpc.id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    VPC1 = "saints-xctf-com-vpc"
    VPC2 = "kubernetes-vpc"
  }
}

resource "aws_route" "saints-xctf-com-route" {
  route_table_id            = data.aws_vpc.saints-xctf-com-vpc.main_route_table_id
  destination_cidr_block    = data.aws_vpc.kubernetes-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.saints-xctf-and-kubernetes.id
}

resource "aws_route" "kubernetes-route" {
  route_table_id            = data.aws_vpc.kubernetes-vpc.main_route_table_id
  destination_cidr_block    = data.aws_vpc.saints-xctf-com-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.saints-xctf-and-kubernetes.id
}