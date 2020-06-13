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

#----------------
# Local Variables
#----------------

locals {}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_partition" "current" {}

data "aws_vpc" "kubernetes-vpc" {
  tags = {
    Name = "kubernetes-vpc"
  }
}

data "aws_subnet" "kubernetes-dotty-public-subnet" {
  tags = {
    Name = "kubernetes-dotty-public-subnet"
  }
}

data "aws_subnet" "kubernetes-grandmas-blanket-public-subnet" {
  tags = {
    Name = "kubernetes-grandmas-blanket-public-subnet"
  }
}

#----------------------
# AWS Resources for EKS
#----------------------

resource "aws_cloudwatch_log_group" "eks_cluster_log_group" {
  name = "/eks/andrew-jarombek-eks-cluster"
  retention_in_days = 7

  tags = {
    Name = "andrew-jarombek-eks-cluster-logs"
    Application = "kubernetes"
    Environment = "all"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "andrew-jarombek-eks-cluster"
  role_arn = aws_iam_role.eks-cluster-role.arn
  enabled_cluster_log_types = ["api"]
  version = "1.16"

  vpc_config {
    subnet_ids = [
      data.aws_subnet.kubernetes-dotty-public-subnet.id,
      data.aws_subnet.kubernetes-grandmas-blanket-public-subnet.id
    ]
  }

  depends_on = [aws_cloudwatch_log_group.eks_cluster_log_group]

  tags = {
    Name = "andrew-jarombek-eks-cluster"
    Application = "kubernetes"
    Environment = "all"
  }
}

resource "aws_iam_role" "eks-cluster-role" {
  name = "eks-cluster-role"
  path = "/kubernetes/"
  assume_role_policy = file("${path.module}/eks-cluster-role.json")
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam:aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-service-policy" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam:aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.eks-cluster-role.name
}