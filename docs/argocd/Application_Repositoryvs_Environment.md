Application Repository vs Environment/GitOps Repository

This is important because we're now moving toward the real CI/CD architecture.

1. The problem we're solving

Right now our single repository contains everything:

DevOps_Automation/
│
├── scripts/
├── app/
├── .github/
│
└── gitops/
    ├── applications/
    └── workloads/

So application-related material and deployment desired state live together.

That is perfectly fine for our learning project.

But in an enterprise environment, we often separate:

Application source
        │
        ▼
Application Repository
        │
        │ CI
        ▼
Container Image
        │
        ▼
Environment / GitOps Repository
        │
        │ Argo CD
        ▼
Kubernetes

The separation gives each repository a different responsibility.

2. Application Repository

The application repository contains things needed to build the application.

For example:

application-repo/
├── src/
├── tests/
├── Dockerfile
├── package.json
└── README.md

Its responsibility is:

SOURCE → TEST → BUILD → PACKAGE

GitHub Actions operates primarily here.

For example:

Developer
   ↓
Git push
   ↓
GitHub Actions
   ├── lint
   ├── test
   ├── security scan
   ├── docker build
   ├── image scan
   └── push image
          ↓
       Registry

The result is an immutable artifact:

myapp:1.28

or preferably a version/digest such as:

myapp@sha256:...
3. Environment / GitOps Repository

The GitOps repository contains:

What should be running in each environment?

For example:

gitops-repo/
└── workloads/
    └── myapp/
        ├── base/
        └── overlays/
            ├── dev/
            ├── staging/
            └── production/

This repository describes:

Dev:
  replicas = 3
  image = version X

Staging:
  replicas = 4
  image = version X

Production:
  replicas = 6
  image = version Y

Argo CD watches this repository.

4. The key separation

Think about the responsibilities this way:

Responsibility	Application Repo	GitOps Repo
Application source	✅	❌
Unit tests	✅	❌
Dockerfile	✅	Usually ❌
Build image	CI	❌
Security scanning	CI	❌
Container registry	Output	Reference
Kubernetes desired state	❌	✅
Environment configuration	❌	✅
Deployment promotion	❌	✅
Argo CD	❌	✅

The exact organization varies between companies, but the separation of build responsibility and deployment desired state is the important concept.

5. Connect this to what we just did

We manually performed:

Dev:
nginx:1.27
   ↓
nginx:1.28

and then:

Staging:
nginx:1.27
   ↓
nginx:1.28

Those changes were made in the GitOps configuration.

In a real pipeline, the flow becomes:

Application Repository
        │
        ▼
GitHub Actions
        │
        ├── Test
        ├── Build
        ├── Scan
        └── Push image
                │
                ▼
          Container Registry
                │
                │ image version/digest
                ▼
        GitOps Repository
                │
                ▼
             Argo CD
                │
                ▼
               EKS

This is the architecture we are ultimately building toward in Project Everest.

6. Why shouldn't CI simply run kubectl apply?

This is a very important GitOps principle.

A traditional CI/CD pipeline might do:

GitHub Actions
      ↓
kubectl apply
      ↓
Kubernetes

GitOps changes the deployment responsibility:

GitHub Actions
      ↓
Update desired state in Git
      ↓
GitOps Repository
      ↓
Argo CD
      ↓
Kubernetes

Therefore:

CI produces and promotes artifacts.

Argo CD deploys and continuously reconciles them.

That gives us:

Git = desired state
Argo CD = reconciliation
Kubernetes = actual state
7. Do we need two repositories for Project Everest?

No.

And I don't recommend that we complicate the learning project just to imitate an enterprise repository layout.

Our current:

DevOps_Automation

can continue acting as both:

Application/CI learning repository
+
GitOps learning repository

We'll understand the enterprise separation conceptually and then implement the workflow in our existing repository.

Later, if we want to simulate the enterprise model, we can create:

DevOps_Automation

and:

DevOps_Automation-GitOps

But that's not necessary yet.

8. One subtle but important point: promotion

This also explains what we did yesterday.

We had:

Dev → nginx:1.28

After validation:

Staging → nginx:1.28

The artifact didn't change.

We promoted the same version.

That leads to an important CI/CD principle:

Build once, promote the same immutable artifact through environments.

Avoid:

Build for Dev
   ↓
different build for Staging
   ↓
different build for Production

Prefer:

Build once
   ↓
Image 1.28
   ├── Dev
   ├── Staging
   └── Production

Ideally the exact image digest is promoted.

Today's practical exercise

We don't need to recreate EKS just for this lesson.

We'll first design the repository architecture on paper using our existing project.

Our target architecture will be:

DevOps_Automation/
│
├── app/
├── scripts/
├── .github/workflows/
│
├── gitops/
│   ├── applications/
│   │   ├── everest-demo.yaml
│   │   └── everest-demo-staging.yaml
│   │
│   └── workloads/
│       └── everest-demo/
│           ├── base/
│           └── overlays/
│               ├── dev/
│               └── staging/
│
└── ...

Then we'll map each part to:

Developer
   ↓
Git
   ↓
GitHub Actions
   ↓
Container Registry
   ↓
GitOps desired state
   ↓
Argo CD
   ↓
EKS

After that, our next topic will be image versioning and immutable deployments, where we'll go deeper into:

nginx:1.28
        vs
nginx@sha256:<digest>

and why production GitOps should generally prefer immutable artifact references.

So today's checkpoint starts here: Application Repo vs GitOps Repo. We don't need to recreate the EKS cluster yet; the conceptual architecture can be learned independently of the cluster.

====================================================================

1. First: separate the responsibilities

Forget the repository names for a moment. Think in terms of two responsibilities.

Application side
Application Source
      ↓
Build
      ↓
Test
      ↓
Security Scan
      ↓
Container Image
Deployment side
Container Image
      ↓
Environment desired state
      ↓
Argo CD
      ↓
Kubernetes

So the fundamental separation is:

┌──────────────────────────────┐
│ Application / CI             │
│                              │
│ Source                       │
│ Tests                        │
│ Dockerfile                   │
│ Build                        │
│ Security scanning            │
└──────────────┬───────────────┘
               │
               │ image
               ▼
        Container Registry
               │
               ▼
┌──────────────────────────────┐
│ GitOps / CD                  │
│                              │
│ Environment configuration    │
│ Kustomize / Helm             │
│ Version promotion            │
│ Argo CD Applications         │
└──────────────┬───────────────┘
               │
               ▼
             EKS
2. Map this to our Everest repository

Our current repository is:

DevOps_Automation/

We currently have:

DevOps_Automation/
├── app/
├── scripts/
├── .github/
├── docs/
├── labs/
└── gitops/

The important distinction is that:

app/
scripts/
.github/

are primarily related to application/automation/CI, while:

gitops/

contains deployment desired state.

Our GitOps portion is already nicely structured:

gitops/
├── applications/
│   ├── everest-demo.yaml
│   └── everest-demo-staging.yaml
│
└── workloads/
    └── everest-demo/
        ├── base/
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   └── kustomization.yaml
        │
        └── overlays/
            ├── dev/
            │   ├── kustomization.yaml
            │   └── namespace.yaml
            │
            └── staging/
                ├── kustomization.yaml
                └── namespace.yaml

That is already a valid GitOps structure.

3. Now let's understand what belongs where

Suppose tomorrow we have a real application called:

customer-api

The application repository could contain:

customer-api/
├── src/
├── tests/
├── Dockerfile
├── requirements.txt
└── .github/
    └── workflows/
        └── ci.yaml

GitHub Actions does:

git push
   ↓
test
   ↓
build
   ↓
scan
   ↓
push image

Result:

registry.example.com/customer-api:1.28

The GitOps repository then says:

image:
  repository: registry.example.com/customer-api
  tag: "1.28"

Argo CD sees that desired state and deploys it.

4. What CI should NOT own

This is an important boundary.

CI should not become a second deployment controller:

GitHub Actions
      ↓
kubectl apply
kubectl rollout
kubectl scale
kubectl delete

If we do that, we start bypassing GitOps.

Instead:

GitHub Actions
      ↓
change Git desired state
      ↓
GitOps repository
      ↓
Argo CD
      ↓
Kubernetes

Argo CD remains the system responsible for:

synchronization
drift detection
self-healing
deployment reconciliation

which we already demonstrated.

5. Now connect this with yesterday's promotion

Yesterday we manually did:

Dev
nginx:1.27
   ↓
nginx:1.28

Then:

validate Dev
   ↓
Staging
nginx:1.27
   ↓
nginx:1.28

In a real system, the application build might produce:

customer-api:2026.09.24.001

CI pushes it to the registry.

Then the GitOps state is updated:

Dev → 2026.09.24.001

After validation:

Staging → 2026.09.24.001

The artifact itself doesn't get rebuilt.

This gives us:

             ONE ARTIFACT
                  │
          ┌───────┼────────┐
          ▼       ▼        ▼
         Dev   Staging    Prod

That is the build once, promote the same artifact principle.

6. Repository separation: two common models

There isn't one universal repository layout.

Model A — Same repository

What we're doing now:

DevOps_Automation/
├── application/
└── gitops/

Advantages:

simple
easy to learn
easy to demonstrate
good for a small team/project
Model B — Separate repositories

Enterprise-style example:

customer-api/
    ↓
Application repository

and:

customer-api-gitops/
    ↓
GitOps repository

Then:

Application Repo
      ↓
GitHub Actions
      ↓
Container Registry
      ↓
GitOps Repo
      ↓
Argo CD
      ↓
EKS

The architecture is what matters more than whether the repositories are physically separate.

For Project Everest, we'll keep our existing repository rather than create unnecessary complexity.

7. The practical exercise

Let's make this concrete with our existing repo.

We are going to create a small architecture note, not change any deployment yet.

Create:

mkdir -p docs/gitops
nano docs/gitops/application-vs-gitops.md

Put this in it:

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
8. One thing I want you to notice

This note is not just documentation.

We're building a mental model:

CI = How do I produce a trustworthy artifact?

GitOps = What version should each environment run?

Argo CD = How do I continuously make Kubernetes match Git?

That separation will make the next topics much easier.

And our next topic naturally follows:

Image Versioning & Immutable Deployments

We'll answer:

nginx:1.28
        ↓
Is this enough?

or

nginx@sha256:abc123...
        ↓
Why is this stronger?

Then we'll connect image tags, digests, registries, promotion, rollback, and supply-chain security to the CI/CD architecture we're building.

============================================

Yes, this is exactly the expected Git state.

modified:
  scripts/bash/application.json    ← existing unrelated change

untracked:
  docs/gitops/                     ← our new GitOps documentation

So do not stage scripts/bash/application.json.

Before we commit the documentation, let's verify the actual note content:

cat docs/gitops/application-vs-gitops.md

If the content is correct, stage only the documentation:

git add docs/gitops/application-vs-gitops.md

Then verify:

git status

We want:

Changes to be committed:
    new file: docs/gitops/application-vs-gitops.md

Changes not staged for commit:
    modified: scripts/bash/application.json

Then:

git diff --cached --check

If there is no output, commit:

git commit -m "Add application and GitOps repository architecture notes"

and push:

git push origin main
Then we move on

Once this note is committed, we'll start:

Image Versioning & Immutable Deployments

We'll use our actual Everest example rather than another theoretical exercise:

nginx:1.27
    ↓
nginx:1.28

and understand exactly why:

nginx:1.28

is a mutable tag reference, while:

nginx@sha256:<digest>

identifies a specific immutable image.

Then we'll connect that to build once → promote → rollback → supply-chain security, which is directly relevant to the CI/CD pipeline we're going to build.

===================================================================