/**
 * Infrastructure for a second version of an EKS cluster used by the entire AWS cloud account.
 * Author: Andrew Jarombek
 * Date: 4/3/2023
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.7.5"

  required_providers {
    aws        = "~> 4.61.0"
    kubernetes = "~> 2.19.0"
    helm       = "~> 2.9.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "global-aws-infrastructure/eks-v2"
    region  = "us-east-1"
  }
}

locals {
  public_cidr     = "0.0.0.0/0"
  cluster_name    = "andrew-jarombek-eks-v2"
  cluster_version = "1.29"
  terraform_tag   = "global-aws-infrastructure/eks-v2"
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

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.12.0"

  cluster_name                          = local.cluster_name
  cluster_version                       = local.cluster_version
  cluster_endpoint_private_access       = true
  cluster_endpoint_public_access        = true
  cluster_additional_security_group_ids = [aws_security_group.eks.id]

  vpc_id = data.aws_vpc.application-vpc.id
  subnet_ids = [
    data.aws_subnet.kubernetes-dotty-public-subnet.id,
    data.aws_subnet.kubernetes-grandmas-blanket-public-subnet.id
  ]

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.eks.id]
  }

  eks_managed_node_groups = {
    eks-prod = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      labels = {
        workload : "production-applications"
      }
      taints = {}
      tags = {
        Name        = "production-applications-node-group"
        Application = "all"
        Environment = "production"
        Terraform   = local.terraform_tag
      }
    }
  }

  tags = {
    Name        = local.cluster_name
    Application = "all"
    Environment = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_security_group" "eks" {
  name        = "andrew-jarombek-eks-cluster"
  description = "Allow Traffic to RDS"
  vpc_id      = data.aws_vpc.application-vpc.id
}

resource "aws_security_group_rule" "cluster-nodes-alb-security-group-rule" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "TCP"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.eks.id
  description       = "Inbound access to worker nodes from ALBs created by an EKS ingress controller."
}

resource "aws_security_group_rule" "rds-outbound-security-group-rule" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks.id
  description       = "Outbound access to RDS instances from the worker nodes."
}

resource "aws_security_group_rule" "rds-inbound-security-group-rule" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks.id
  description       = "Inbound access from RDS instances to the worker nodes."
}

module "lb_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.16.0"

  role_name                              = "${local.cluster_name}-lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    # API version is dependent on the version of the AWS CLI installed locally
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
    }
  }
}

resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }

    annotations = {
      "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "vpcId"
    value = data.aws_vpc.application-vpc.id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = local.cluster_name
  }

  depends_on = [kubernetes_service_account.service-account]
}

#-------------
# External DNS
#-------------

resource "aws_iam_policy" "external-dns-policy" {
  name   = "external-dns"
  path   = "/kubernetes/"
  policy = file("${path.module}/external-dns-policy.json")

  tags = {
    Name        = "external-dns"
    Application = "all"
    Environment = "all"
    Terraform   = local.terraform_tag
  }
}

resource "aws_iam_role_policy_attachment" "external-dns-role-policy" {
  policy_arn = aws_iam_policy.external-dns-policy.arn
  role       = module.eks.eks_managed_node_groups.eks-prod.iam_role_name
}

resource "kubernetes_service_account" "external-dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "external-dns" {
  metadata {
    name = "external-dns"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "pods"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "external-dns" {
  metadata {
    name = "external-dns"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "external-dns"
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "external-dns" {
  metadata {
    name      = "external-dns"
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
          name  = "external-dns"
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
}

#-----------
# Namespaces
#-----------

resource "kubernetes_namespace" "sandox-namespace" {
  metadata {
    name = "sandbox"

    labels = {
      name        = "sandbox"
      environment = "sandbox"
    }
  }
}

resource "kubernetes_namespace" "jarombek-com-namespace" {
  metadata {
    name = "jarombek-com"

    labels = {
      name        = "jarombek-com"
      environment = "production"
    }
  }
}

resource "kubernetes_namespace" "jarombek-com-dev-namespace" {
  metadata {
    name = "jarombek-com-dev"

    labels = {
      name        = "jarombek-com-dev"
      environment = "development"
    }
  }
}

resource "kubernetes_namespace" "saints-xctf-namespace" {
  metadata {
    name = "saints-xctf"

    labels = {
      name        = "saints-xctf"
      environment = "production"
    }
  }
}

resource "kubernetes_namespace" "saints-xctf-dev-namespace" {
  metadata {
    name = "saints-xctf-dev"

    labels = {
      name        = "saints-xctf-dev"
      environment = "development"
    }
  }
}