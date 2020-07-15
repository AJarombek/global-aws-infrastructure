### Overview

Kubernetes YAML configuration files for the Jenkins server.

### Files

| Filename                     | Description                                                                                  |
|------------------------------|----------------------------------------------------------------------------------------------|
| `cluster-role.yaml`          | ClusterRole granting read permissions for the `jenkins-kubernetes-test` Service Account.     |
| `cluster-role-binding.yaml`  | Binding roles to the `jenkins-kubernetes-test` Service Account.                              |
| `service-account.yaml`       | `jenkins-kubernetes-test` Service Account used to test K8s infrastructure from Jenkins.      |