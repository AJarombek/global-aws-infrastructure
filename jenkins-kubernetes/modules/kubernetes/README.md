### Overview

Module for creating a Jenkins server on Kubernetes using an ALB Ingress Controller.

### Commands

*Debugging on Kubernetes*

```bash
kubectl get po -n jenkins
kubectl describe po -n jenkins
kubectl logs -f jenkins-deployment-pod-name -n jenkins
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `k8s-config`        | YAML files representing Kubernetes infrastructure for the Jenkins server.                    |
| `main.tf`           | Main Terraform configuration for the Kubernetes infrastructure.                              |
| `var.tf`            | Variables for the Terraform configuration.                                                   |