# Argo CD and GitOps

This section contains notes, architecture references, labs, and practical learning material for GitOps and Argo CD.

## Learning Scope

- GitOps fundamentals
- Desired state and live state
- Reconciliation
- Drift detection
- Argo CD architecture
- Argo CD installation
- Argo CD Applications
- Sync and health status
- Automated synchronization
- Self-healing
- GitOps repository design
- Environment promotion
- Rollback
- Secrets management
- Argo CD security and RBAC
- Multi-cluster GitOps
- ApplicationSets
- Progressive delivery
- Observability and auditability

## Project Everest Integration

The intended architecture is:

Developer
  ↓
Application Repository
  ↓
GitHub Actions
  ↓
Container Image Registry
  ↓
GitOps Environment Repository
  ↓
Argo CD
  ↓
Kubernetes
  ↓
Running Application

## Status

- GitOps fundamentals: Completed
- Argo CD architecture: Studied
- Argo CD Application concepts: Studied
- Local Argo CD installation: Pending or in progress
- Practical GitOps deployment: Next phase
