/**
 * Infrastructure for an EKS cluster used by the entire AWS cloud account.
 * Author: Andrew Jarombek
 * Date: 6/12/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12.26"

  required_providers {
    aws = ">= 2.66.0"
    random = ">= 2.2"
    null = ">= 2.1"
    local = ">= 1.4"
    template = ">= 2.1"
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
  public_cidr = "0.0.0.0/0"
  cluster_name = "andrew-jarombek-eks-cluster"

  kubernetes_public_subnet_cidrs = [
    "10.1.1.0/24",
    "10.1.2.0/24"
  ]

  kubernetes_private_subnet_cidrs = [
    "10.1.3.0/24",
    "10.1.4.0/24"
  ]

  kubernetes_vpc_sg_rules = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      type = "ingress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      type = "ingress"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = local.public_cidr
    },
    {
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for HTTP
      type = "egress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for HTTPS
      type = "egress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
  ]

  kubernetes_public_subnet_azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  kubernetes_private_subnet_azs = [
    "us-east-1b",
    "us-east-1c"
  ]

  subnet_tags = {
    Application = "kubernetes",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "kubernetes.io/role/elb" = "1"
  }

  kubernetes_public_subnet_tags = [local.subnet_tags, local.subnet_tags]
  kubernetes_private_subnet_tags = [local.subnet_tags, local.subnet_tags]
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.andrew-jarombek-eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.andrew-jarombek-eks-cluster.cluster_id
}

data "aws_vpc" "application-vpc" {
  tags = {
    Name = "application-vpc"
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

#----------------------------
# Kubernetes Provider for EKS
#----------------------------

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
}

#----------------------
# AWS Resources for EKS
#----------------------

module "andrew-jarombek-eks-cluster" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 12.1.0"

  create_eks = true
  cluster_name = local.cluster_name
  cluster_version = "1.16"
  vpc_id = data.aws_vpc.application-vpc.id
  subnets = [
    data.aws_subnet.kubernetes-grandmas-blanket-public-subnet.id,
    data.aws_subnet.kubernetes-dotty-public-subnet.id
  ]

  worker_groups = [
    {
      instance_type = "t2.medium"
      asg_max_size = 2
      asg_desired_capacity = 1
    }
  ]
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]
  // Thumbprint for us-east-1: https://github.com/terraform-providers/terraform-provider-aws/issues/10104#issuecomment-633130751
  // OIDC Thumbprint: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  thumbprint_list = ["CE777AD27909E070D99EECE1FF2F774624E1E7E7"]
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy_document" "alb-ingress-controller-policy-document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"

    condition {
      test = "StringEquals"
      values = ["system:serviceaccount:kube-system:aws-alb-ingress-controller"]
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "alb-ingress-controller-role" {
  name = "aws-alb-ingress-controller"
  path = "/kubernetes/"
  assume_role_policy = data.aws_iam_policy_document.alb-ingress-controller-policy-document.json
}

resource "aws_iam_policy" "alb-ingress-controller-policy" {
  name = "aws-alb-ingress-controller"
  path = "/kubernetes/"
  policy = file("${path.module}/alb-ingress-controller-policy.json")
}

resource "aws_iam_role_policy_attachment" "alb-ingress-controller-role-policy" {
  policy_arn = aws_iam_policy.alb-ingress-controller-policy.arn
  role = aws_iam_role.alb-ingress-controller-role.name
}

resource "aws_iam_policy" "external-dns-policy" {
  name = "external-dns"
  path = "/kubernetes/"
  policy = file("${path.module}/external-dns-policy.json")
}

resource "aws_iam_role_policy_attachment" "external-dns-role-policy" {
  policy_arn = aws_iam_policy.external-dns-policy.arn
  role = module.andrew-jarombek-eks-cluster.worker_iam_role_name
}

resource "aws_iam_policy" "worker-pods-policy" {
  name = "worker-pods"
  path = "/kubernetes/"
  policy = file("${path.module}/worker-pods-policy.json")
}

resource "aws_iam_role_policy_attachment" "worker-pods-role-policy" {
  policy_arn = aws_iam_policy.worker-pods-policy.arn
  role = module.andrew-jarombek-eks-cluster.worker_iam_role_name
}

resource "aws_security_group_rule" "cluster-nodes-alb-security-group-rule" {
  type = "ingress"
  from_port = 30000
  to_port = 32767
  protocol = "TCP"
  cidr_blocks = ["10.0.0.0/8"]
  security_group_id = module.andrew-jarombek-eks-cluster.worker_security_group_id
  description = "Inbound access to worker nodes from ALBs created by an EKS ingress controller."
}

#-----------------------------
# Kubernetes Resources for EKS
#-----------------------------

#-----------
# Namespaces
#-----------

resource "kubernetes_namespace" "sandox-namespace" {
  metadata {
    name = "sandbox"

    labels = {
      name = "sandbox"
      environment = "sandbox"
    }
  }
}

resource "kubernetes_namespace" "jenkins-namespace" {
  metadata {
    name = "jenkins"

    labels = {
      name = "jenkins"
      environment = "production"
    }
  }
}

resource "kubernetes_namespace" "jenkins-dev-namespace" {
  metadata {
    name = "jenkins-dev"

    labels = {
      name = "jenkins-dev"
      environment = "development"
    }
  }
}

resource "kubernetes_namespace" "jarombek-com-namespace" {
  metadata {
    name = "jarombek-com"

    labels = {
      name = "jarombek-com"
      environment = "production"
    }
  }
}

resource "kubernetes_namespace" "jarombek-com-dev-namespace" {
  metadata {
    name = "jarombek-com-dev"

    labels = {
      name = "jarombek-com-dev"
      environment = "development"
    }
  }
}

resource "kubernetes_namespace" "saints-xctf-namespace" {
  metadata {
    name = "saints-xctf"

    labels = {
      name = "saints-xctf"
      environment = "production"
    }
  }
}

resource "kubernetes_namespace" "saints-xctf-dev-namespace" {
  metadata {
    name = "saints-xctf-dev"

    labels = {
      name = "saints-xctf-dev"
      environment = "development"
    }
  }
}

#-----------------------
# ALB Ingress Controller
#-----------------------

resource "kubernetes_service_account" "alb-ingress-controller" {
  metadata {
    name = "aws-alb-ingress-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kubernetes/aws-alb-ingress-controller"
    }

    labels = {
      "app.kubernetes.io/name" = "aws-alb-ingress-controller"
    }
  }

  automount_service_account_token = true

  depends_on = [
    aws_iam_policy.alb-ingress-controller-policy,
    aws_iam_role.alb-ingress-controller-role,
    aws_iam_role_policy_attachment.alb-ingress-controller-role-policy
  ]
}

resource "kubernetes_cluster_role" "alb-ingress-controller" {
  metadata {
    name = "aws-alb-ingress-controller"

    labels = {
      "app.kubernetes.io/name" = "aws-alb-ingress-controller"
    }
  }

  rule {
    api_groups = ["", "extensions"]
    resources = ["configmaps", "endpoints", "events", "ingresses", "ingresses/status", "services"]
    verbs = ["create", "get", "list", "update", "watch", "patch"]
  }

  rule {
    api_groups = ["", "extensions"]
    resources = ["nodes", "pods", "secrets", "services", "namespaces"]
    verbs = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "alb-ingress-controller" {
  metadata {
    name = "aws-alb-ingress-controller"

    labels = {
      "app.kubernetes.io/name" = "aws-alb-ingress-controller"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "aws-alb-ingress-controller"
  }

  subject {
    kind = "ServiceAccount"
    name = "aws-alb-ingress-controller"
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "alb-ingress-controller" {
  metadata {
    name = "aws-alb-ingress-controller"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name" = "aws-alb-ingress-controller"
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "aws-alb-ingress-controller"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "aws-alb-ingress-controller"
        }
      }

      spec {
        container {
          name = "aws-alb-ingress-controller"
          image = "docker.io/amazon/aws-alb-ingress-controller:v1.1.4"
          args = [
            "--ingress-class=alb",
            "--cluster-name=${local.cluster_name}",
            "--aws-vpc-id=${data.aws_vpc.application-vpc.id}",
            "--aws-region=us-east-1"
          ]
        }

        automount_service_account_token = true

        service_account_name = "aws-alb-ingress-controller"
      }
    }
  }

  depends_on = [
    aws_iam_policy.alb-ingress-controller-policy,
    aws_iam_role.alb-ingress-controller-role,
    aws_iam_role_policy_attachment.alb-ingress-controller-role-policy
  ]
}

#-------------
# External DNS
#-------------

resource "kubernetes_service_account" "external-dns" {
  metadata {
    name = "external-dns"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "external-dns" {
  metadata {
    name = "external-dns"
  }

  rule {
    api_groups = [""]
    resources = ["services"]
    verbs = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources = ["pods"]
    verbs = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["extensions"]
    resources = ["ingresses"]
    verbs = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources = ["nodes"]
    verbs = ["list"]
  }

  rule {
    api_groups = [""]
    resources = ["endpoints"]
    verbs = ["get", "watch", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "external-dns" {
  metadata {
    name = "external-dns"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "external-dns"
  }

  subject {
    kind = "ServiceAccount"
    name = "external-dns"
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "external-dns" {
  metadata {
    name = "external-dns"
    namespace = "kube-system"
  }

  spec {
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        "name" = "external-dns"
      }
    }

    template {
      metadata {
        labels = {
          name = "external-dns"
        }
      }

      spec {
        container {
          name = "external-dns"
          image = "bitnami/external-dns:latest"
          args = [
            "--source=service",
            "--source=ingress",
            "--provider=aws",
            "--aws-zone-type=public",
            "--registry=txt",
            "--txt-owner-id=my-id"
          ]
        }

        automount_service_account_token = true

        service_account_name = "external-dns"
      }
    }
  }

  depends_on = [
    aws_iam_policy.alb-ingress-controller-policy,
    aws_iam_role.alb-ingress-controller-role,
    aws_iam_role_policy_attachment.alb-ingress-controller-role-policy
  ]
}