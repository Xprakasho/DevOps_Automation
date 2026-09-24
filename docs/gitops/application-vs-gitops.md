# Application Repository vs GitOps Repository

## Application / CI Responsibility

The application side is responsible for:

- application source code
- tests
- Dockerfile
- build
- security scanning
- container image creation
- publishing the image to a registry

Flow:

Developer
    ↓
Git
    ↓
CI
    ├── Test
    ├── Security Scan
    ├── Build
    └── Push Image
            ↓
      Container Registry


## GitOps / CD Responsibility

The GitOps side is responsible for:

- Kubernetes desired state
- environment configuration
- application version references
- environment promotion
- Argo CD Application definitions

Flow:

GitOps Repository
       ↓
    Argo CD
       ↓
   Kubernetes


## Complete Flow

Developer
    ↓
Application Repository
    ↓
GitHub Actions
    ├── Test
    ├── Security Scan
    ├── Build
    └── Push Image
            ↓
      Container Registry
            ↓
      GitOps Repository
            ↓
         Argo CD
            ↓
           EKS


## GitOps Principle

GitHub Actions should not directly deploy application
workloads with kubectl.

CI produces and validates the artifact.

Git records the desired deployment state.

Argo CD reconciles the desired state with Kubernetes.


## Promotion

Build once and promote the same artifact:

Dev
 ↓
Staging
 ↓
Production

The application artifact should not be rebuilt for each environment.