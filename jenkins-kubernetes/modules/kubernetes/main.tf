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

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
}

#---------------------
# Kubernetes Resources
#---------------------

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "jenkins-deployment"
    namespace = "jenkins"

    labels = {
      version = "v1.0.0"
      environment = "production"
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
        environment = "production"
      }
    }

    template {
      metadata {
        labels = {
          version = "v1.0.0"
          environment = "production"
          application = "jenkins-server"
        }
      }

      spec {
        container {
          name = "jenkins-server"
          image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/jenkins-jarombek-io:1.0.0"

          readiness_probe {
            period_seconds = 1
            initial_delay_seconds = 5

            http_get {
              path = "/"
              port = 8080
            }
          }

          port {
            container_port = 8080
            protocol = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name = "jenkins-service"
    namespace = "jenkins"

    labels = {
      version = "v1.0.0"
      environment = "production"
      application = "jenkins-server"
    }
  }

  spec {
    type = "NodePort"

    port {
      port = 80
      target_port = 8080
      node_port = 30001
      protocol = "TCP"
    }

    selector = {
      application = "jenkins-server"
    }
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name = "jenkins-ingress"
    namespace = "jenkins"

    annotations = {
      kubernetes.io/ingress.class = "alb"
    }

    labels = {
      version = "v1.0.0"
      environment = "production"
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
  }
}