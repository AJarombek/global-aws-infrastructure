/**
 * Kubernetes infrastructure for the jenkins.jarombek.io application.
 * Author: Andrew Jarombek
 * Date: 6/14/2020
 */

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = "andrew-jarombek-eks-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "andrew-jarombek-eks-cluster"
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

data "aws_acm_certificate" "jenkins-cert" {
  domain = local.domain_cert
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "jenkins-wildcard-cert" {
  domain = local.wildcard_domain_cert
  statuses = ["ISSUED"]
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
}

#----------------
# Local Variables
#----------------

locals {
  short_env = var.prod ? "prod" : "dev"
  env = var.prod ? "production" : "development"
  namespace = var.prod ? "jenkins" : "jenkins-dev"
  short_version = "1.0.5"
  version = "v${local.short_version}"
  account_id = data.aws_caller_identity.current.account_id
  domain_cert = var.prod ? "*.jarombek.io" : "*.jenkins.jarombek.io"
  wildcard_domain_cert = var.prod ? "*.jenkins.jarombek.io" : "*.dev.jenkins.jarombek.io"
  cert_arn = data.aws_acm_certificate.jenkins-cert.arn
  wildcard_cert_arn = data.aws_acm_certificate.jenkins-wildcard-cert.arn
  subnet1 = data.aws_subnet.kubernetes-dotty-public-subnet.id
  subnet2 = data.aws_subnet.kubernetes-grandmas-blanket-public-subnet.id
}

#--------------
# AWS Resources
#--------------

resource "aws_security_group" "jenkins-lb-sg" {
  name = "jenkins-${local.short_env}-lb-security-group"
  vpc_id = data.aws_vpc.kubernetes-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-${local.short_env}-lb-security-group"
    Application = "jenkins-jarombek-io"
    Environment = local.env
  }
}

#---------------------
# Kubernetes Resources
#---------------------

resource "kubernetes_service_account" "jenkins-server" {
  metadata {
    name = "jenkins-server"
    namespace = "jenkins"
  }
}

resource "kubernetes_role" "jenkins-server" {
  metadata {
    name = "jenkins-server"
    namespace = "jenkins"
  }

  rule {
    api_groups = [""]
    resources = ["pods"]
    verbs = ["get", "watch", "list", "create", "delete", "update"]
  }

  rule {
    api_groups = [""]
    resources = ["events", "pods/exec", "pods/log"]
    verbs = ["get", "watch", "list"]
  }
}

resource "kubernetes_role_binding" "jenkins-server" {
  metadata {
    name = "jenkins-server"
    namespace = "jenkins"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "jenkins-server"
  }

  subject {
    kind = "ServiceAccount"
    name = "jenkins-server"
    namespace = "jenkins"
  }
}

/* I hope you are doing well & you are happy */
resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "jenkins-deployment"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "jenkins-server"
    }
  }

  spec {
    replicas = 1
    min_ready_seconds = 10

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge = "1"
        max_unavailable = "0"
      }
    }

    selector {
      match_labels = {
        application = "jenkins-server"
        environment = local.env
      }
    }

    template {
      metadata {
        labels = {
          version = local.version
          environment = local.env
          application = "jenkins-server"
        }
      }

      spec {
        container {
          name = "jenkins-server"
          image = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/jenkins-jarombek-io:${local.short_version}"

          volume_mount {
            mount_path = "/var/run/docker.sock"
            name = "dockersock"
          }

          volume_mount {
            mount_path = "/usr/bin/docker"
            name = "dockercli"
          }

          readiness_probe {
            period_seconds = 5
            initial_delay_seconds = 20

            http_get {
              path = "/login"
              port = 8080
            }
          }

          port {
            name = "http-port"
            container_port = 8080
            protocol = "TCP"
          }

          port {
            name = "jnlp-port"
            container_port = 50000
          }
        }

        volume {
          name = "dockersock"

          host_path {
            path = "/var/run/docker.sock"
          }
        }

        volume {
          name = "dockercli"

          host_path {
            path = "/usr/bin/docker"
          }
        }

        automount_service_account_token = true
        service_account_name = "jenkins-server"
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name = "jenkins-service"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "jenkins-server"
    }
  }

  spec {
    type = "NodePort"

    port {
      port = 80
      target_port = 8080
      protocol = "TCP"
    }

    selector = {
      application = "jenkins-server"
    }
  }
}

resource "kubernetes_service" "jnlp-service" {
  metadata {
    name = "jenkins-jnlp-service"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "jenkins-server"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      name = "http"
      port = 80
      target_port = 8080
    }

    port {
      name = "jnlp"
      port = 50000
      target_port = 50000
    }

    selector = {
      application = "jenkins-server"
    }
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name = "jenkins-ingress"
    namespace = local.namespace

    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "external-dns.alpha.kubernetes.io/hostname" = "jenkins.jarombek.io,www.jenkins.jarombek.io"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/certificate-arn" = "${local.cert_arn},${local.wildcard_cert_arn}"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/login"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/security-groups" = aws_security_group.jenkins-lb-sg.id
      "alb.ingress.kubernetes.io/subnets" = "${local.subnet1},${local.subnet2}"
      "alb.ingress.kubernetes.io/target-type" = "instance"
      "alb.ingress.kubernetes.io/tags" = "Name=jenkins-load-balancer,Application=jenkins,Environment=${local.env}"
    }

    labels = {
      version = local.version
      environment = local.env
      application = "jenkins-server"
    }
  }

  spec {
    rule {
      host = "jenkins.jarombek.io"

      http {
        path {
          path = "/*"

          backend {
            service_name = "jenkins-service"
            service_port = 80
          }
        }
      }
    }

    rule {
      host = "www.jenkins.jarombek.io"

      http {
        path {
          path = "/*"

          backend {
            service_name = "jenkins-service"
            service_port = 80
          }
        }
      }
    }
  }
}