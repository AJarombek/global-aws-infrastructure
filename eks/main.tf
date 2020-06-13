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

locals {
  eks_node_group_subnets = [
    {
      Name = "kubernetes-lily-public-subnet"
    },
    {
      Name = "kubernetes-teddy-public-subnet"
    }
  ]
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_availability_zones" "available" {
  state = "available"
}

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
    security_group_ids = [
      aws_security_group.eks-cluster-security.id
    ]
    subnet_ids = [
      data.aws_subnet.kubernetes-dotty-public-subnet.id,
      data.aws_subnet.kubernetes-grandmas-blanket-public-subnet.id
    ]
    endpoint_private_access = true
    endpoint_public_access = true
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

resource "aws_security_group" "eks-cluster-security" {
  name = "andrew-jarombek-eks-cluster-security"
  vpc_id = data.aws_vpc.kubernetes-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "andrew-jarombek-eks-cluster-security"
    Application = "kubernetes"
    Environment = "all"
  }
}

resource "aws_security_group_rule" "eks-cluster-security-egress" {
  security_group_id = aws_security_group.eks-cluster-security.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "All outbound traffic is allowed"
}

resource "aws_security_group_rule" "eks-node-group-security-ingress-self" {
  security_group_id = aws_security_group.eks-cluster-security.id
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  source_security_group_id = aws_security_group.eks-cluster-security.id
  description = "Allow worker nodes in the node group to communicate with one another"
}

resource "aws_security_group_rule" "eks-cluster-security-ingress" {
  security_group_id = aws_security_group.eks-cluster-security.id
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  source_security_group_id = aws_security_group.eks-cluster-security.id
  description = "Allow pods (on worker nodes) to communicate with the cluster API server"
}

resource "aws_subnet" "eks-node-group-subnets" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = cidrsubnet(data.aws_vpc.kubernetes-vpc.cidr_block, 8, count.index + 3)
  vpc_id = data.aws_vpc.kubernetes-vpc.id

  tags = merge(
    {
      "kubernetes.io/cluster/${aws_eks_cluster.eks-cluster.name}" = "shared"
    },
    local.eks_node_group_subnets[count.index]
  )
}


resource "aws_eks_node_group" "eks-node-group" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  node_group_name = "andrew-jarombek-eks-node-group"
  node_role_arn = aws_iam_role.eks-node-role.arn
  version = "1.16"

  subnet_ids = [
    aws_subnet.eks-node-group-subnets[0].id,
    aws_subnet.eks-node-group-subnets[1].id
  ]

  scaling_config {
    desired_size = 1
    max_size = 2
    min_size = 1
  }

  ami_type = "AL2_x86_64"
  instance_types = ["t3.medium"]
  disk_size = 20

  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node-policy,
    aws_iam_role_policy_attachment.eks-cni-policy,
    aws_iam_role_policy_attachment.eks-container-registry-policy
  ]

  tags = {
    Name = "andrew-jarombek-eks-node-group"
    Application = "kubernetes"
    Environment = "all"
    "kubernetes.io/cluster/${aws_eks_cluster.eks-cluster.name}" = "owned"
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
