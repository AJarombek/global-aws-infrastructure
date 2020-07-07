### Overview

Kubernetes YAML configuration files for the Jenkins server.

### Files

| Filename               | Description                                                                                  |
|------------------------|----------------------------------------------------------------------------------------------|
| `test`                 | Kubernetes objects for the `jenkins-kubernetes-test` service account used for K8s tests.     |
| `deployment.yaml`      | Deployment object for the Jenkins server.                                                    |
| `ingress.yaml`         | Ingress object for the Jenkins server.                                                       |
| `role.yaml`            | Role for the Jenkins server.                                                                 |
| `role-binding.yaml`    | Binding of a Role to the Jenkins Service Account.                                            |
| `service.yaml`         | Service object to route traffic from the ingress object to the application pods.             |
| `service-account.yaml` | Service Account which supplies permissions to the Jenkins server.                            |

### Resources

1) [ALB Ingress Controller - Ingress](https://kubernextes-sigs.github.io/aws-alb-ingress-controller/guide/ingress/spec/)