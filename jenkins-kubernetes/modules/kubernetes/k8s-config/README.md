### Overview

Kubernetes YAML configuration files for the Jenkins server.

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `deployment.yaml`   | Deployment object for the Jenkins server.                                                    |
| `ingress.yaml`      | Ingress object for the ALB Ingress controller.                                               |
| `service.yaml`      | Service object to route traffic from the ingress object to the application pods.             |

### Resources

1) [ALB Ingress Controller - Ingress](https://kubernextes-sigs.github.io/aws-alb-ingress-controller/guide/ingress/spec/)