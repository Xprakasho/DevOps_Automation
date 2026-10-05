# EKS Pod Identity + External Secrets + AWS Secrets Manager

## 1. Problem

Kubernetes workloads need sensitive configuration such as usernames, passwords, API keys, and credentials. Project Everest keeps the actual secret values outside Git while keeping the required configuration declarative and GitOps-managed.

The implemented stack is:

- Amazon EKS
- EKS Pod Identity
- AWS IAM
- AWS Secrets Manager
- External Secrets Operator (ESO)
- Kubernetes Secret
- Argo CD
- Kustomize

The principle is:

```text
Git = desired configuration and secret references
AWS Secrets Manager = actual sensitive values
ESO = synchronization
Kubernetes Secret = workload-facing secret
Argo CD = GitOps reconciliation
```

---

## 2. Architecture

```text
                         GitHub
                           |
                           | Desired state
                           v
                        Argo CD
                           |
                     AppProject boundary
                           |
                           v
                    Kustomize overlay
                           |
             +-------------+-------------+
             |                           |
             v                           v
        SecretStore                ExternalSecret
             |                           |
             +-------------+-------------+
                           |
                           v
              External Secrets Operator
                           |
                    ServiceAccount
                   external-secrets
                           |
                    EKS Pod Identity
                           |
                    IAM Role assumption
                           |
                 EverestESOSecretReader
                           |
                           v
                AWS Secrets Manager
                  everest/dev/demo
                           |
                           v
                 Kubernetes Secret
                everest-demo-secret
                           |
                           v
                    Everest Deployment
```

Application-side consumption:

```text
Kubernetes Secret
       |
       | secretKeyRef
       v
Everest Deployment
       +-- EVEREST_USERNAME
       +-- EVEREST_PASSWORD
```

---

## 3. Component Responsibilities

### Git / GitHub

Stores declarative configuration:

- Argo CD Application
- Argo CD AppProject
- Kustomize overlays
- SecretStore
- ExternalSecret
- Deployment and Service
- IAM trust/policy definitions used by the lab

Actual secret values are not stored in Git.

### Argo CD

Reconciles Git-defined desired state with Kubernetes.

### AppProject

Defines the Argo CD security boundary: source repositories, destinations, and permitted resource kinds.

### External Secrets Operator

Reads `ExternalSecret` definitions and obtains referenced values from the external provider, then creates/updates Kubernetes Secrets.

### AWS Secrets Manager

Stores the actual sensitive values. Everest uses the secret:

```text
everest/dev/demo
```

### EKS Pod Identity

Provides AWS workload identity to the ESO controller without putting long-lived AWS credentials into the Pod.

### IAM Role

Has two separate security responsibilities:

```text
Trust policy      = WHO may assume the role
Permission policy = WHAT the role may access
```

---

## 4. EKS Pod Identity

Everest uses EKS Pod Identity for the ESO workload.

Identity path:

```text
ESO Pod
  |
  v
Kubernetes ServiceAccount
external-secrets
  |
  v
EKS Pod Identity Association
  |
  v
IAM Role
EverestESOSecretReader
  |
  v
AWS APIs
```

The cluster uses the EKS add-on:

```text
eks-pod-identity-agent
```

The agent runs on the EKS nodes.

### Pod Identity vs IRSA

The ServiceAccount does **not** need an IAM-role annotation for EKS Pod Identity. The association is maintained through EKS.

Everest's association is:

```text
Cluster:         terraform-eks-lab
Namespace:       external-secrets
ServiceAccount:  external-secrets
IAM Role:        EverestESOSecretReader
```

---

## 5. IAM Trust vs Permission

### Trust policy

The trust policy answers:

> Who is allowed to assume this role?

The role trusts the EKS Pod Identity service:

```json
"Principal": {
  "Service": "pods.eks.amazonaws.com"
}
```

The Everest trust policy is further restricted using Pod Identity session tags to the intended:

```text
Cluster:
arn:aws:eks:us-east-1:587748224379:cluster/terraform-eks-lab

Namespace:
external-secrets

ServiceAccount:
external-secrets
```

This prevents the role from being treated as a generic role for arbitrary workloads.

### Permission policy

The permission policy answers:

> What AWS resources may the role access?

`EverestESOSecretReader` is limited to the required Secrets Manager access for the Everest secret.

Therefore there are two independent boundaries:

```text
Trust policy
    = who can become the identity

Permission policy
    = what that identity can access
```

---

## 6. External Secrets Operator

Two Kubernetes resources are central to this design.

### SecretStore

Defines the external provider:

```yaml
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: aws-secretsmanager
  namespace: everest-dev
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
```

The SecretStore does not contain the actual secret value.

### ExternalSecret

Defines the synchronization mapping. Everest references:

```text
AWS Secrets Manager:
everest/dev/demo
```

and maps the provider properties:

```text
username -> username
password -> password
```

The target Kubernetes Secret is:

```text
everest-demo-secret
```

---

## 7. Argo CD Integration

The Everest Application points Argo CD to:

```text
gitops/workloads/everest-demo/overlays/dev
```

The overlay manages:

```text
Deployment
Service
SecretStore
ExternalSecret
```

The Application uses:

```text
Project: everest-project
```

The AppProject permits the External Secrets resource kinds:

```yaml
- group: external-secrets.io
  kind: SecretStore
- group: external-secrets.io
  kind: ExternalSecret
```

### AppProject prerequisite

During the lab, Argo CD initially rejected the ESO resources because the AppProject did not permit them. The live AppProject was then updated to include these resource kinds.

The AppProject itself is not currently managed by the Everest Application, so it was bootstrapped manually after EKS recreation:

```bash
kubectl apply -f gitops/projects/everest-project.yaml
```

For a larger platform, a bootstrap/root Application could manage AppProjects and other Argo CD control-plane resources. The Everest lab keeps this step explicit for clarity.

---

## 8. End-to-End Deployment Sequence

### Step 1 — Recreate EKS

The EKS cluster can be destroyed and recreated to control lab cost.

### Step 2 — Install Pod Identity Agent

```bash
aws eks create-addon \
  --cluster-name terraform-eks-lab \
  --region us-east-1 \
  --addon-name eks-pod-identity-agent
```

Verify:

```bash
aws eks describe-addon \
  --cluster-name terraform-eks-lab \
  --region us-east-1 \
  --addon-name eks-pod-identity-agent \
  --query 'addon.status' \
  --output text
```

Expected:

```text
ACTIVE
```

### Step 3 — Configure least-privilege IAM trust

The existing `EverestESOSecretReader` role is retained. Its trust policy is restricted to the intended EKS cluster, namespace, and ServiceAccount.

### Step 4 — Create Pod Identity association

```bash
aws eks create-pod-identity-association \
  --cluster-name terraform-eks-lab \
  --region us-east-1 \
  --namespace external-secrets \
  --service-account external-secrets \
  --role-arn arn:aws:iam::587748224379:role/EverestESOSecretReader
```

### Step 5 — Install ESO

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets \
  --create-namespace
```

### Step 6 — Verify Pod Identity injection

The ESO controller Pod was verified to contain:

```text
AWS_REGION=us-east-1
AWS_DEFAULT_REGION=us-east-1
AWS_CONTAINER_CREDENTIALS_FULL_URI=http://169.254.170.23/v1/credentials
AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE=/var/run/secrets/pods.eks.amazonaws.com/serviceaccount/eks-pod-identity-token
```

The Pod also had the projected Pod Identity token mounted at:

```text
/var/run/secrets/pods.eks.amazonaws.com/serviceaccount
```

This proved the workload received the Pod Identity configuration.

### Step 7 — Restore GitOps resources

```bash
kubectl apply -f gitops/projects/everest-project.yaml
kubectl apply -f gitops/applications/everest-demo.yaml
```

### Step 8 — Verify Argo CD

```bash
kubectl get applications -n argocd
```

Verified:

```text
everest-demo   Synced   Healthy
```

### Step 9 — Verify SecretStore

```bash
kubectl get secretstore -n everest-dev
```

Verified:

```text
aws-secretsmanager   Valid   ReadWrite   True
```

### Step 10 — Verify ExternalSecret

```bash
kubectl get externalsecret -n everest-dev
```

Verified:

```text
everest-demo-secret   SecretSynced   True
```

### Step 11 — Verify Kubernetes Secret

```bash
kubectl get secret everest-demo-secret -n everest-dev
```

Verified:

```text
everest-demo-secret   Opaque   2
```

Do not print or decode the values during routine verification.

### Step 12 — Verify workload consumption

The Deployment was verified to reference:

```text
EVEREST_USERNAME
  -> secretKeyRef: everest-demo-secret / username

EVEREST_PASSWORD
  -> secretKeyRef: everest-demo-secret / password
```

All three Everest Pods were Running.

---

## 9. Verification Checklist

### EKS Pod Identity Agent

```bash
aws eks describe-addon \
  --cluster-name terraform-eks-lab \
  --region us-east-1 \
  --addon-name eks-pod-identity-agent \
  --query 'addon.status' \
  --output text
```

Expected:

```text
ACTIVE
```

### Agent Pods

```bash
kubectl get pods -n kube-system | grep eks-pod-identity-agent
```

Expected: one Running agent per node.

### Pod Identity Association

```bash
aws eks list-pod-identity-associations \
  --cluster-name terraform-eks-lab \
  --region us-east-1 \
  --namespace external-secrets \
  --service-account external-secrets
```

### ESO

```bash
kubectl get pods -n external-secrets
```

Expected: controller, cert-controller, and webhook Running.

### Pod Identity injection

```bash
kubectl get pod -n external-secrets \
  -l app.kubernetes.io/name=external-secrets \
  -o yaml | grep -A2 -B2 'AWS_'
```

Expected to find the AWS container credential variables.

### Argo CD

```bash
kubectl get applications -n argocd
```

Expected:

```text
everest-demo   Synced   Healthy
```

### SecretStore

```bash
kubectl get secretstore -n everest-dev
```

Expected:

```text
Valid ... True
```

### ExternalSecret

```bash
kubectl get externalsecret -n everest-dev
```

Expected:

```text
SecretSynced ... True
```

### Kubernetes Secret

```bash
kubectl get secret everest-demo-secret -n everest-dev
```

Verify existence and key count only.

### Workload

```bash
kubectl get pods -n everest-dev
```

Expected: application Pods Running.

---

## 10. Failure Modes Encountered

### Failure 1 — ESO attempted EC2 IMDS credentials

Observed:

```text
failed to refresh cached credentials,
no EC2 IMDS role found
```

Cause: the ESO controller had started before the Pod Identity association existed and therefore did not have the required Pod Identity injection.

Resolution: restart/recreate the ESO controller after the association existed.

Improved sequence:

```text
Pod Identity Agent
       |
IAM trust
       |
Pod Identity association
       |
ESO installation
```

This ensures ESO starts with the intended identity configuration.

### Failure 2 — Argo CD rejected SecretStore and ExternalSecret

Observed:

```text
resource external-secrets.io:ExternalSecret is not permitted
resource external-secrets.io:SecretStore is not permitted
```

Cause: the Everest AppProject did not permit the External Secrets resource kinds.

Resolution: add `SecretStore` and `ExternalSecret` under the AppProject's permitted namespace resources.

### Failure 3 — AppProject Git change did not automatically reconcile

The AppProject was stored in Git but was not itself managed by the Everest Application.

Resolution:

```bash
kubectl apply -f gitops/projects/everest-project.yaml
```

This is a bootstrap/control-plane dependency.

### Failure 4 — `env` unavailable inside ESO container

Attempting:

```bash
kubectl exec ... -- env
```

returned:

```text
exec: "env": executable file not found in $PATH
```

Cause: the ESO image is minimal and does not contain the `env` executable.

Resolution: inspect the Kubernetes Pod specification instead. This successfully showed the Pod Identity environment variables and token mount.

Lesson: do not assume debugging utilities exist in minimal production containers.

---

## 11. Rebuild After EKS Recreation

External AWS resources retained outside the cluster:

```text
AWS Secrets Manager secret
IAM policy
IAM role
```

Cluster-specific resources that must be recreated:

```text
EKS Pod Identity Agent
Pod Identity association
ESO installation
Argo CD installation
Kubernetes resources
```

Recovery sequence:

```text
1. Recreate EKS
        |
2. Install Pod Identity Agent
        |
3. Configure/verify IAM trust
        |
4. Create Pod Identity association
        |
5. Install ESO
        |
6. Bootstrap AppProject
        |
7. Restore Argo CD Application
        |
8. Verify SecretStore
        |
9. Verify ExternalSecret
        |
10. Verify Kubernetes Secret
        |
11. Verify workload
```

The tested recovery result was:

```text
Argo CD        Synced / Healthy
SecretStore    Valid / Ready
ExternalSecret SecretSynced / Ready
Secret         Present / 2 keys
Pods           Running
```

This demonstrates that the workload configuration can be reconstructed after replacing the EKS cluster without putting secret values into Git.

---

## 12. Security Considerations

### Never put secret values into Git

Git should contain references and desired configuration, not passwords, tokens, or private credentials.

### Base64 is not encryption

A Kubernetes Secret representation using base64 should not be treated as protection for the underlying value.

### Least privilege

Keep these controls separate:

```text
IAM trust
+
IAM permissions
+
Argo CD AppProject permissions
+
Kubernetes resource references
```

### Restrict IAM trust

The Pod Identity role should not unnecessarily trust arbitrary workloads. Everest restricts the identity to the intended cluster, namespace, and ServiceAccount.

### Restrict AWS permissions

The ESO IAM role should have only the actions and resource scope required for the intended secret access.

### Avoid exposing secret values during troubleshooting

Prefer:

```bash
kubectl get secret everest-demo-secret -n everest-dev
```

over printing the complete Secret object or decoding values.

---

## 13. Key Takeaways

### Secret management and GitOps are separate concerns

```text
GitOps
  = desired state

Secrets Manager
  = sensitive data
```

### EKS Pod Identity is workload identity

It allows an EKS workload to obtain AWS credentials without storing long-lived AWS credentials in the Pod.

### Trust and permission are different

```text
Trust policy
    = Who can assume the role?

Permission policy
    = What can the role access?
```

### SecretStore and ExternalSecret are different

```text
SecretStore
    = external provider configuration

ExternalSecret
    = desired synchronization mapping
```

### Kubernetes Secret is the workload-facing object

ESO creates/updates the Kubernetes Secret and the application consumes it through `secretKeyRef`.

### AppProject is a GitOps security boundary

Argo CD Applications are constrained by the source repositories, destinations, and resource permissions defined by their AppProject.

### Replaceable infrastructure is a platform principle

The EKS cluster was destroyed and recreated. External AWS resources remained available, cluster-specific integrations were reconstructed, and Git-managed desired state restored the application configuration.

---

## 14. Everest Mental Model

```text
                  SOURCE OF TRUTH
                       Git
                        |
                        v
                      Argo CD
                        |
                  AppProject
                        |
                        v
                   Kustomize
                        |
          +-------------+-------------+
          |                           |
          v                           v
      Workload                  Secret references
          |                           |
          |                     ExternalSecret
          |                           |
          |                    External Secrets
          |                       Operator
          |                           |
          |                      Pod Identity
          |                           |
          |                        IAM Role
          |                           |
          |                           v
          |                    Secrets Manager
          |                           |
          |                           v
          |                    Kubernetes Secret
          |                           |
          +-------------<-------------+
                 secretKeyRef
```

### Core principle

> Git declares the desired configuration; AWS Secrets Manager holds the sensitive value; EKS Pod Identity provides workload identity; ESO synchronizes the secret; Argo CD reconciles the declarative configuration.
