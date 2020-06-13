/**
 * Infrastructure for an EKS cluster used by the entire AWS cloud account.
 * Author: Andrew Jarombek
 * Date: 6/12/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "global-aws-infrastructure/eks"
    region = "us-east-1"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "andrew-jarombek-eks-cluster"
  role_arn = ""

  vpc_config {
    subnet_ids = []
  }
}