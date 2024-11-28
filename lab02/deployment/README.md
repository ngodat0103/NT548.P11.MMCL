# Project Overview

## Directory Structure

This project is organized into the following main directories:

```
./NT548.P11.MMCL\lab02\deployment
├── jenkins
│   └── dev
│       └── user-svc
└── kubernetes
    └── helm
        ├── external-secrets
        ├── shared-infra
        └── user-svc
```

### Directory Descriptions

- **jenkins**: Contains Jenkins configuration files for the CI/CD pipeline, specifically for the development environment of the user service.
- **kubernetes**: Holds Kubernetes configuration files, including Helm charts for deploying various services.
  - **helm**: Contains Helm charts for managing deployments.
    - **external-secrets**: Helm chart for managing external secrets using HashiCorp Vault.
    - **shared-infra**: Helm chart for shared infrastructure components like Redis and Kafka.
    - **user-svc**: Helm chart for the user service, including templates for deployment, services, and other resources.

