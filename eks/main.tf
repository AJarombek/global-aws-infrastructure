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

  required_providers {
    aws = ">= 2.66.0"
  }

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

resource "aws_cloudwatch_log_group" "eks-cluster-log-group" {
  name = "/eks/andrew-jarombek-eks-cluster"
  retention_in_days = 7

  tags = {
    Name = "andrew-jarombek-eks-cluster-logs"
    Application = "kubernetes"
    Environment = "all"
  }
}

resource "aws_eks_cluster" "eks-cluster" {
  name = "andrew-jarombek-eks-cluster"
  role_arn = aws_iam_role.eks-cluster-role.arn
  enabled_cluster_log_types = ["api"]
  version = "1.16"

  vpc_config {
    subnet_ids = [
      data.aws_subnet.kubernetes-dotty-public-subnet.id,
      data.aws_subnet.kubernetes-grandmas-blanket-public-subnet.id
    ]
    endpoint_private_access = true
    endpoint_public_access = false
  }

  depends_on = [
    aws_cloudwatch_log_group.eks-cluster-log-group,
    aws_iam_role_policy_attachment.eks-cluster-policy,
    aws_iam_role_policy_attachment.eks-service-policy
  ]

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
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.eks-cluster-role.name
}

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  node_group_name = "andrew-jarombek-eks-node-group"
  node_role_arn = aws_iam_role.eks-node-role.arn

  subnet_ids = [
    data.aws_subnet.kubernetes-dotty-public-subnet.id,
    data.aws_subnet.kubernetes-grandmas-blanket-public-subnet.id
  ]

  scaling_config {
    desired_size = 1
    max_size = 1
    min_size = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node-policy,
    aws_iam_role_policy_attachment.eks-cni-policy,
    aws_iam_role_policy_attachment.eks-container-registry-policy
  ]

  tags = {
    Name = "andrew-jarombek-eks-node-group"
    Application = "kubernetes"
    Environment = "all"
  }
}

resource "aws_iam_role" "eks-node-role" {
  name = "eks-node-role"
  path = "/kubernetes/"
  assume_role_policy = file("${path.module}/eks-node-role.json")
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-container-registry-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks-node-role.name
}
