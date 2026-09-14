====================================================================== GitOps ===========================================================================

GitOps — The Concept

GitOps is not Argo CD.

GitOps is a methodology/pattern. Argo CD is one implementation of it.

There are other implementations, such as Flux. The underlying GitOps principles are intended to be vendor/tool neutral.

Our mental model will therefore be:

                 GITOPS
                    │
        ┌───────────┴───────────┐
        │                       │
    PRINCIPLES              IMPLEMENTATION
        │                       │
 Declarative              Argo CD
 Versioned                Flux
 Pull-based              ...
 Reconciliation

We first understand the left side.

1. What problem is GitOps solving?

Imagine we have:

Developer
    │
    ▼
Git repository
    │
    ▼
CI Pipeline
    │
    ├── test
    ├── build
    ├── docker image
    └── deploy
          │
          ▼
      Kubernetes

A traditional CI/CD pipeline may directly execute:

kubectl apply -f deployment.yaml

or:

helm upgrade ...

The CI runner is actively telling Kubernetes:

"Go and deploy this."

That's an imperative deployment model.

2. GitOps changes the direction

With GitOps:

                Git
                 │
          Desired State
                 │
                 ▼
        GitOps Controller
                 │
                 ▼
            Kubernetes
                 │
                 ▼
           Actual State

The GitOps controller continuously asks:

"What does Git say should be running?"

and:

"What is actually running?"

Then:

Desired State ≠ Actual State
           │
           ▼
      Reconcile
           │
           ▼
   Actual State → Desired State

That reconciliation loop is one of the most important concepts you need to understand.

The OpenGitOps principles explicitly describe GitOps as declarative, versioned/immutable, automatically pulled, and continuously reconciled.

3. Desired state vs actual state

This concept will become extremely important for your Kubernetes work.

Suppose Git contains:

replicas: 3

Git says:

DESIRED STATE

Application
replicas = 3
version  = v2

But Kubernetes currently has:

LIVE STATE

Application
replicas = 2
version  = v1

We have:

Desired ≠ Live

Therefore:

                Git
                 │
                 │ desired = 3
                 ▼
          GitOps Controller
                 │
                 │ compare
                 ▼
          Kubernetes
                 │
                 │ actual = 2
                 ▼

             DIFFERENCE

The controller works to bring the cluster back toward:

desired = actual

This is called reconciliation.

4. This is different from "Git as backup"

This distinction is critical.

GitOps does not simply mean:

"We keep Kubernetes YAML in Git."

That's only part of it.

The important part is:

Git
 │
 │ desired state
 ▼
Controller
 │
 │ continuously observes
 ▼
Cluster
 │
 │ actual state
 ▼
Controller
 │
 └──── reconcile ────► cluster

So Git becomes the declarative source of truth for desired state, while an agent/controller continuously works to reconcile the running environment with that state.

5. Now introduce Argo CD

Only now we bring in the tool.

Argo CD official documentation

Argo CD describes itself as:

a declarative, GitOps continuous delivery tool for Kubernetes.

So:

GitOps
   │
   │ implementation
   ▼
Argo CD
   │
   ▼
Kubernetes

Argo CD continuously compares the desired state from Git with the live state in Kubernetes. If they differ, the application becomes OutOfSync, and Argo CD can synchronize the cluster back toward the desired state.

6. The four words I want you to remember

For now, forget the Argo CLI.

Remember these:

1. Desired State

What should exist?

3 replicas
image v2
Service
Ingress
ConfigMap
etc.

2. Live State

What actually exists in Kubernetes?

2 replicas
image v1
Service
Ingress
ConfigMap
etc.

3. Drift

Difference between desired and live state.

Desired
   ≠
Live

4. Reconciliation

Process of bringing live state back toward desired state.

Desired
   │
   ▼
Controller
   │
   ▼
Live State

These four concepts are more important than knowing 50 Argo commands.

7. Where Kubernetes fits

This is where our learning roadmap becomes connected.

You are going to learn:

Bash
 │
 ├── automation
 │
 ▼
Python
 │
 ├── automation
 │
 ▼
Docker
 │
 ├── package application
 │
 ▼
Kubernetes
 │
 ├── run application
 │
 ▼
Helm
 │
 ├── package/configure Kubernetes resources
 │
 ▼
GitOps
 │
 ├── manage desired state
 │
 ▼
Argo CD
 │
 └── continuously reconcile
        │
        ▼
    Kubernetes

So GitOps is not another isolated technology.

It is the operating model that sits on top of our Kubernetes deployment workflow.

8. Where CI/CD fits

This is especially important because we've just built GitHub Actions.

We currently have:

Git push
   │
   ▼
GitHub Actions
   │
   ├── Terraform
   ├── validation
   ├── Bash
   ├── Python
   └── build/test

Eventually:

                  Git
                   │
             ┌─────┴─────┐
             │            │
          CI side      CD side
             │            │
       GitHub Actions   GitOps
             │            │
       build/test       Argo CD
             │            │
       Docker image     Kubernetes
             │            │
             └─────┬──────┘
                   │
             Application

And this is an important modern DevOps distinction:

CI

Answers:

"Is this change valid and can I build it?"

GitOps/CD

Answers:

"What should be running in the environment, and is the environment matching that desired state?"

Argo CD's own CI guidance describes this separation: CI can build/publish an image and update the desired configuration in Git; the GitOps system then synchronizes the cluster from Git.

9. Where Docker fits

Suppose we build:

myapp:v1

Docker creates the artifact.

Then CI pushes:

registry/myapp:v1

But GitOps doesn't magically build the image.

Instead, the desired configuration might eventually say:

image:
  repository: registry/myapp
  tag: v1

Then:

Git
 │
 │ image = v1
 ▼
GitOps Controller
 │
 ▼
Kubernetes
 │
 ▼
Pod
 │
 ▼
registry/myapp:v1

This distinction will become extremely important when we reach Docker + Kubernetes + Helm.

10. Where Helm fits

This is another place where people get confused.

GitOps does not require Helm.

You can have:

Git
 └── plain Kubernetes YAML

or:

Git
 └── Kustomize

or:

Git
 └── Helm

or other configuration-management mechanisms.

Argo CD supports plain manifests, Helm, Kustomize, Jsonnet, and plugins.

So our architecture will remain:

GitOps
   │
   ├── YAML
   ├── Kustomize
   ├── Helm
   └── other mechanisms
          │
          ▼
      Kubernetes

When we learn Helm later, you'll understand why Helm is being used, rather than thinking:

"GitOps = Helm + Argo CD."

It isn't.

11. Very important: Argo CD does not replace Kubernetes

Another common misunderstanding.

Argo CD ≠ Kubernetes

Instead:

              Argo CD
                 │
        manages/reconciles
                 │
                 ▼
            Kubernetes
                 │
                 ▼
         Pods / Services /
       Deployments / etc.

Argo CD itself runs in Kubernetes and operates as a Kubernetes-oriented controller/system. Its application controller monitors applications and compares live state against the desired state from the repository.

12. The mental model I want you to build

Forget the tool for a moment.

Imagine this:

               ┌───────────────────┐
               │       GIT         │
               │                   │
               │ Desired State     │
               │ versioned         │
               │ reviewed          │
               └─────────┬─────────┘
                         │
                         │ Pull
                         ▼
               ┌───────────────────┐
               │    CONTROLLER     │
               │                   │
               │ Compare           │
               │ Desired vs Live   │
               │ Reconcile         │
               └─────────┬─────────┘
                         │
                         ▼
               ┌───────────────────┐
               │   KUBERNETES      │
               │                   │
               │ Live State        │
               └───────────────────┘

Then:

GitOps = the operating model

Argo CD = controller/tool implementing that model

Kubernetes = target platform

Helm = optional packaging/configuration mechanism

Git = desired-state source

That's our foundation.

Our learning strategy from here

We will not immediately install Argo CD.

First we'll learn GitOps concepts in this sequence:

SESSION 1  → What is GitOps?                  ← TODAY
             Desired vs Live
             Drift
             Reconciliation
             Pull model

SESSION 2  → GitOps architecture
             CI vs CD
             Push vs Pull
             Application repository
             Environment/config repository

SESSION 3  → GitOps repository structure
             dev
             staging
             production
             branches vs directories

SESSION 4  → Deployment lifecycle
             commit
             image
             manifest
             reconciliation
             rollback

SESSION 5  → Secrets
             GitOps security model
             what should NOT be stored in Git

SESSION 6  → Helm + GitOps
             why Helm
             values
             environments

SESSION 7  → Argo CD
             Application
             Project
             Repository
             Destination
             Sync
             Health
             OutOfSync

SESSION 8  → Practical Argo CD
             Kubernetes lab
             Git repository
             Argo CD
             application deployment

SESSION 9  → Production-style GitOps
             multi-environment
             promotion
             rollback
             drift
             RBAC
             secrets

And we'll keep Bash/Python/Docker/Kubernetes/Helm progressing in parallel.

The goal is that when we finally execute:

argocd app sync ...

you already understand what synchronization means, why it exists, what state is being reconciled, and what Argo CD is actually doing.

=============================================================================================

GitOps — Session 2

Architecture: Push vs Pull → CI vs CD → Repositories → Promotion → End-to-End Flow

Today I want you to build the complete mental architecture before we touch Argo CD or Flux.

1. First: CI and CD are different responsibilities

We already have practical experience with GitHub Actions.

Think of the pipeline as two broad responsibilities:

                    SOFTWARE DELIVERY
                           │
              ┌────────────┴────────────┐
              │                         │
             CI                        CD
       Continuous Integration    Continuous Delivery
              │                         │
       "Can we build it?"        "How do we run it?"
              │                         │
       test / build / scan       deploy / reconcile
       package / publish         environment management

CI typically does

Developer
   │
   ▼
Git push
   │
   ▼
CI
   ├── checkout
   ├── lint
   ├── test
   ├── security scan
   ├── build
   ├── Docker image
   └── push image

For example:

myapp:v1.4.7

gets pushed to:

Container Registry

The CI job has answered:

"We successfully built a deployable artifact."

2. CD has a different question

CD asks:

"How does this artifact become the desired state of an environment?"

Traditional CD might do:

CI
 │
 ▼
kubectl apply

or:

CI
 │
 ▼
helm upgrade

The CI/CD runner directly contacts Kubernetes.

That is the push model.

3. Push-based deployment

Let's visualize it:

             Git
              │
              ▼
        GitHub Actions
              │
        build/test/image
              │
              │ PUSH
              ▼
         Kubernetes

The deployment system says:

"I have finished CI. Now I will push the deployment into the cluster."

For example:

kubectl apply -f deployment.yaml

The CI runner needs access to the Kubernetes API.

That means you have to think about:

CI runner
   │
   ├── Kubernetes credentials
   ├── network access
   ├── permissions
   └── deployment commands

This can work very well, but GitOps introduces a different model.

4. Pull-based deployment

With GitOps:

                  Git
                   │
                   │ desired state
                   ▼
             GitOps Controller
                   │
                   │ PULL
                   ▼
              Kubernetes

The controller lives inside/near the target environment.

Instead of GitHub Actions saying:

"Deploy this!"

the controller says:

"I will continuously observe Git and reconcile the cluster."

This is the fundamental architectural difference.

5. Push vs Pull

Remember this table.

    Push model	                                  Pull model

Deployment initiator	CI/CD system	          GitOps controller
Kubernetes access	CI needs access	          Controller has access
Deployment command	CI executes it	          Controller reconciles
Desired state	        Usually CI-driven	  Git-driven
Drift detection	        Usually separate	  Native GitOps concept
Common example	        kubectl apply from CI	  Argo CD / Flux

But don't interpret this as:

Push = bad, Pull = good.

That's too simplistic.

Both are valid engineering approaches.

GitOps emphasizes the pull/reconciliation model because it provides strong declarative and continuous reconciliation properties.

6. The architecture we are building

Now combine CI + GitOps:

                       Developer
                           │
                           │ git push
                           ▼
                    ┌──────────────┐
                    │     Git      │
                    └──────┬───────┘
                           │
                           ▼
                    GitHub Actions
                           │
                 ┌─────────┴─────────┐
                 │                   │
              Test/Build          Docker
                 │                   │
                 │                   ▼
                 │             Container Registry
                 │
                 ▼
          Update desired state
                 │
                 ▼
              Git Repo
                 │
                 │ PULL
                 ▼
          GitOps Controller
           │             │
       Argo CD          Flux
           │             │
           └──────┬──────┘
                  ▼
             Kubernetes

This is the architecture I want you to understand.

7. Wait — why did Git appear twice?

Excellent question.

In a mature GitOps architecture, we commonly separate:

Application source code

app-repository/
├── src/
├── tests/
├── Dockerfile
└── ...

from:

Deployment/configuration repository

environment-repository/
├── dev/
├── staging/
└── production/

They have different responsibilities.

8. Application repository

Example:

my-application/
├── src/
├── tests/
├── Dockerfile
├── requirements.txt
└── README.md

Developer changes:

application code

CI does:

test
 ↓
build
 ↓
security scan
 ↓
Docker image
 ↓
registry

Example:

myapp:8f32a91

where 8f32a91 could represent the Git commit.

9. Environment repository

Separate repository:

my-application-environments/
│
├── dev/
│   └── values.yaml
│
├── staging/
│   └── values.yaml
│
└── production/
    └── values.yaml

Or perhaps:

environments/
├── dev/
│   └── deployment.yaml
├── staging/
│   └── deployment.yaml
└── production/
    └── deployment.yaml

This repository represents:

What should be running in each environment?

That's very different from:

What does the application source code look like?

10. Now the magic happens

Suppose the developer commits:

Application v2

CI builds:

registry.example.com/myapp:2.0.0

CI does not necessarily deploy directly to Kubernetes.

Instead, CI updates the environment repository:

image:
  repository: registry.example.com/myapp
  tag: 2.0.0

Git now says:

DEV desired state = myapp:2.0.0

The GitOps controller notices:

Git:
2.0.0

Cluster:
1.9.0

Therefore:

DRIFT DETECTED

Then:

GitOps Controller
       │
       ▼
Reconcile
       │
       ▼
Kubernetes
       │
       ▼
myapp:2.0.0

Now:

Desired = Actual

11. This is deployment promotion

Now we reach a very important enterprise concept.

Suppose:

Development
    │
    ▼
v2.0.0

works correctly.

We don't automatically want:

v2.0.0 → Production

without control.

Instead:

DEV
 │
 │ validate
 ▼
STAGING
 │
 │ approval / validation
 ▼
PRODUCTION

Git becomes part of that promotion mechanism.

For example:

dev/values.yaml

image:
  tag: 2.0.0

After testing:

staging/values.yaml

image:
  tag: 2.0.0

After production approval:

production/values.yaml

image:
  tag: 2.0.0

Each change is:

Git commit
+
Pull Request
+
Review
+
Audit trail

This is one of the major strengths of GitOps.

12. Promotion does NOT necessarily mean copying files

Important.

Promotion is a concept, not a specific Git operation.

It could be:

dev → staging → production

using:

Pull requests
Git tags
branches
directories
Helm values
Kustomize overlays
image promotion
release metadata
automated policies

Different organizations implement this differently.

That's why we're learning the concept first.

13. Complete end-to-end example

Let's put everything together.

Developer changes code:

Developer
   │
   ▼
Application Git
   │
   ▼
GitHub Actions
   │
   ├── Test
   ├── Build
   ├── Scan
   └── Docker Build
          │
          ▼
    Container Registry
          │
          │ image = 2.0.0
          ▼
Environment Git
          │
          │ PR / commit
          ▼
   Desired State
          │
          ▼
    GitOps Controller
          │
       reconcile
          ▼
      Kubernetes
          │
          ▼
    Application v2.0.0

That is our core GitOps delivery pipeline.

14. Now introduce Argo CD and Flux

At this point:

                 GitOps Controller
                    /          \
                   /            \
              Argo CD           Flux

Both implement GitOps-style continuous reconciliation, but their architectures, APIs, resource models, ecosystem integrations, and operational approaches differ.

So eventually we'll learn:

GitOps concept
      │
      ├───────────────┐
      ▼               ▼
   Argo CD           Flux
      │               │
   implementation   implementation

Not:

GitOps = Argo CD

That's exactly the tool-independent mindset you asked for.

15. One more critical concept: drift

Suppose production says:

Git:
replicas = 3

Someone manually executes:

kubectl scale deployment myapp --replicas=1

Now:

Git / Desired       Kubernetes / Actual

replicas = 3        replicas = 1
      │                    │
      └──────── ≠ ─────────┘

That's configuration drift.

A GitOps controller detects the difference.

Depending on the configured synchronization behavior:

detect drift
     ↓
report drift
     ↓
reconcile
     ↓
restore desired state

This is why GitOps is more than:

"Put YAML in Git."

The continuous reconciliation loop is fundamental.

16. Your architecture mental model

I want you to remember this diagram:

                         ┌──────────────┐
                         │   Developer  │
                         └──────┬───────┘
                                │
                                ▼
                       Application Git
                                │
                                ▼
                              CI
                     ┌──────────┼──────────┐
                     │          │          │
                   Test       Build      Scan
                                │
                                ▼
                         Container Image
                                │
                                ▼
                         Container Registry
                                │
                                │
                         update desired
                                │
                                ▼
                       Environment Git
                                │
                         desired state
                                │
                                ▼
                     ┌──────────────────┐
                     │ GitOps Controller│
                     │                  │
                     │ Argo CD / Flux   │
                     └────────┬─────────┘
                              │
                         reconcile
                              │
                              ▼
                         Kubernetes
                              │
                              ▼
                         Live State
                              │
                              │
                         compare ▲
                              │
                              └────── Git

And the central loop is:

Git
 ↓
Desired State
 ↓
Controller
 ↓
Kubernetes
 ↓
Live State
 ↓
Compare
 ↓
Drift?
 ↓
Reconcile
 ↓
Kubernetes

That loop is GitOps.

What we will cover next

Before installing Argo CD, I would do one more conceptual session:

GitOps Session 3 — Repository & Environment Design

We'll go deeper into:

1. Monorepo vs multi-repo
2. Application repo vs environment repo
3. Dev / QA / Stage / Prod
4. Branch-based environments
5. Directory-based environments
6. Helm-based environments
7. Kustomize-based environments
8. Image version management
9. Promotion strategies
10. Rollback
11. Secrets
12. Multi-cluster / multi-region
13. Disaster recovery
14. Argo CD vs Flux architectural mapping

Then we'll have enough foundation to install Argo CD practically without treating it as a collection of commands.

======================================================================================================================================

Think of the Argo CD GUI as a control room

When we eventually install it, the first screen you should mentally read like this:

                 ARGO CD
                    │
             Applications
                    │
        ┌───────────┼───────────┐
        │           │           │
      App-A       App-B       App-C
        │
        ▼
 ┌──────────────────────┐
 │ Application           │
 │                      │
 │ Git Source            │
 │ Target Revision       │
 │ Destination Cluster  │
 │ Namespace             │
 │ Sync Status           │
 │ Health Status         │
 └──────────────────────┘

The important thing is that Argo CD thinks in terms of Applications, not individual kubectl apply commands.

1. Application

An Argo CD Application is essentially the relationship between:

Git desired state
       +
target Kubernetes cluster
       +
target namespace

For example:

Application: payment-service

Git:
github.com/company/platform-config
Path:
production/payment-service

Target:
EKS production cluster

Namespace:
payment

Argo CD then manages that relationship.

The official getting-started flow asks you to provide the application name, project, Git repository, revision/path, and destination cluster/namespace.

2. Git source

You'll see something similar to:

SOURCE

Repository:
https://github.com/...

Revision:
main

Path:
apps/payment

This answers:

Where does my desired state come from?

Argo CD's repository server retrieves the configured revision and generates the Kubernetes manifests from the selected source/path.

And this is where Helm/Kustomize eventually enters.

For example:

Git
 │
 ├── plain YAML
 │
 ├── Helm
 │
 └── Kustomize

Argo CD can work with all of these.

3. Destination

You'll also see:

DESTINATION

Cluster:
https://kubernetes...

Namespace:
production

This answers:

Where should the desired state exist?

So we have:

SOURCE                         DESTINATION

Git repository                 Kubernetes
      │                            │
      │                            │
      └────────── Argo CD ─────────┘

This is one of the most important relationships in the UI.

4. Sync Status

This is where our GitOps concept becomes visible.

You may see:

SYNC STATUS

Synced

or:

OutOfSync
Synced

Conceptually:

Git desired state
       =
Kubernetes live state
OutOfSync
Git desired state
       ≠
Kubernetes live state

Argo CD's application controller continuously compares the desired state from Git with the live state and detects OutOfSync.

5. Health Status

This is different from Sync Status.

This distinction is very important.

You could have:

Sync:   Synced
Health: Healthy

Everything is good.

But you could potentially have:

Sync:   Synced
Health: Degraded

Meaning:

Kubernetes matches what Git requested, but the application itself isn't healthy.

For example:

Git says:
replicas = 3

Kubernetes:
replicas = 3

Therefore:

SYNC = Synced

But perhaps:

3 desired pods
1 running
2 crashing

Then:

HEALTH = Degraded

This distinction will become very important when we troubleshoot later.

Argo CD provides health assessment for application resources in addition to synchronization status.

6. The Resource Tree

This is probably the part of the UI I want you to pay the most attention to when we install it.

You'll see something conceptually like:

payment-service
│
├── Deployment
│     └── ReplicaSet
│           ├── Pod
│           ├── Pod
│           └── Pod
│
├── Service
│
├── ConfigMap
│
└── Secret

This gives you a visual representation of the Kubernetes resources belonging to the application.

So instead of:

kubectl get all
kubectl get configmap
kubectl get secret
kubectl get ingress
...

Argo gives you an application-centric view.

7. Sync

You'll eventually see a Sync operation.

Conceptually:

Git
 │
 │ desired
 ▼
Argo CD
 │
 │ reconcile
 ▼
Kubernetes

Manual synchronization is one option.

Automatic synchronization is another.

With automated sync enabled, Argo CD can automatically synchronize when it detects differences between the desired manifests in Git and the live cluster state.

So:

Git commit
     ↓
Argo detects new desired state
     ↓
OutOfSync
     ↓
Automatic Sync
     ↓
Kubernetes
     ↓
Synced
8. Now the really interesting part — Drift

Suppose we have:

Git:

replicas: 3

Argo:

Synced
Healthy

Then someone manually does:

kubectl scale deployment payment --replicas=1

Now:

Git                  Kubernetes

replicas = 3         replicas = 1
     │                    │
     └──────── ≠ ─────────┘
                 │
                 ▼
             OutOfSync

The GUI can visualize this difference.

Then, if automated self-healing/sync behavior is configured:

OutOfSync
    ↓
Reconciliation
    ↓
replicas = 3
    ↓
Synced

Argo CD explicitly supports automated configuration drift detection and automated/manual synchronization.

This is the experiment we absolutely will do ourselves.

9. Argo CD architecture behind the GUI

The GUI isn't the engine.

This is important.

Behind it are major components:

                  User
                   │
                   ▼
                Web UI
                   │
                   ▼
              API Server
              /         \
             /           \
            ▼             ▼
 Repository Server    Application
                         Controller
                              │
                              ▼
                         Kubernetes
API Server

Handles things like:

UI
CLI
application management
authentication
RBAC
sync/rollback operations
CI/CD API access
Repository Server

Responsible for obtaining the Git repository content and generating manifests.

Application Controller

This is the heart of the GitOps behavior.

It continuously:

observe
   ↓
compare
   ↓
detect drift
   ↓
reconcile

The official architecture documentation identifies these as the core components.

10. So when we eventually install Argo CD...

We won't just say:

kubectl apply ...

and call it done.

We'll actually trace:

                    Git
                     │
                     ▼
              Repository Server
                     │
               generate manifests
                     │
                     ▼
              Application
               Controller
                     │
               compare state
                     │
          ┌──────────┴──────────┐
          │                     │
       Desired                  Live
          │                     │
          └─────────┬───────────┘
                    │
                 Compare
                    │
             ┌──────┴──────┐
             │             │
          Same           Different
             │             │
          Synced        OutOfSync
                           │
                           ▼
                       Reconcile

That's the real Argo CD architecture behind the nice GUI.

What I want you to remember from this "GUI visit"

Don't memorize buttons yet.

Just recognize these:

Argo CD
│
├── Application
│
├── Git Source
│
├── Revision
│
├── Path
│
├── Destination
│
├── Sync Status
│      ├── Synced
│      └── OutOfSync
│
├── Health Status
│      ├── Healthy
│      ├── Progressing
│      ├── Degraded
│      └── ...
│
├── Resource Tree
│
├── Sync
│
├── History / Rollback
│
└── Logs / Events / Resource details

Argo CD also supports multi-cluster deployment, RBAC/SSO, Helm/Kustomize/plain YAML, webhooks, audit trails, ApplicationSets, and other enterprise capabilities.

===============================================================================================

GitOps Session 3

Repository Architecture, Environments & Promotion

This is where GitOps starts becoming an enterprise architecture topic rather than just a deployment tool.

1. First question: What exactly goes into Git?

We have two fundamentally different things:

Application
    │
    ├── Source code
    ├── Tests
    ├── Dockerfile
    └── Build configuration

Environment
    │
    ├── Kubernetes configuration
    ├── Image version
    ├── Replicas
    ├── Resources
    ├── Ingress
    ├── Config
    └── Environment-specific settings

These don't necessarily need to live in the same repository.

That's why we commonly see:

Application Repository
        +
Environment / Deployment Repository

2. Application repository

Imagine:

payment-service/
│
├── src/
├── tests/
├── Dockerfile
├── requirements.txt
├── README.md
└── .github/
    └── workflows/
        └── ci.yml

Developer changes:

src/

GitHub Actions runs:

test
 ↓
security scan
 ↓
build
 ↓
Docker image
 ↓
container registry

Example:

payment-service:8f72a91

The application repository answers:

What is the application?

3. Environment repository

Now consider:

platform-environments/
│
├── dev/
│   └── payment-service/
│
├── staging/
│   └── payment-service/
│
└── production/
    └── payment-service/

This repository answers:

How should this application run in this environment?

For example:

DEV

replicas: 1
resources: small
image: 2.4.0

while:

PRODUCTION

replicas: 5
resources: large
image: 2.3.5

Same application.

Different desired state.

4. Why separate them?

This is an important architecture decision.

Suppose a developer changes:

src/payment.py

You don't necessarily want that developer's source-code commit to directly modify production infrastructure.

Instead:

Developer
    │
    ▼
Application Repository
    │
    ▼
CI
    │
    ▼
Image
    │
    ▼
Environment Repository
    │
    ▼
PR / approval
    │
    ▼
Production

This creates separation between:

Application lifecycle

and:

Environment lifecycle

That separation becomes valuable in larger organizations.

5. But there isn't one "correct" repository model

This is important for your tool-independent goal.

You might see:

Model A — One repository
repo/
├── application/
├── helm/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/

Model B — Two repositories
application-repo/
environment-repo/

Model C — Multiple repositories
application-repo
platform-repo
environment-repo
infrastructure-repo

Model D — Organization/platform model
team-a/
team-b/
team-c/

platform/
clusters/
environments/

The GitOps principles don't dictate a single repository structure.

Architecture depends on:

organization size
team ownership
compliance
security
release model
number of clusters
number of environments
platform engineering model

This distinction is exactly why we are learning concepts rather than memorizing Argo CD patterns.

6. Environment separation

Now let's talk about:

DEV
STAGING
PRODUCTION

A common flow is:

                 Application
                      │
                      ▼
                     CI
                      │
                      ▼
                  Image v2.0
                      │
                      ▼
                     DEV
                      │
                   testing
                      │
                      ▼
                   STAGING
                      │
                 validation
                      │
                      ▼
                 PRODUCTION

This is called promotion.

7. What exactly gets promoted?

This is an important question.

You generally want to promote the same immutable artifact, rather than rebuilding different artifacts for every environment.

For example:

Build once:

payment-service:2.0.0

Then:

DEV       → payment-service:2.0.0
STAGING   → payment-service:2.0.0
PROD      → payment-service:2.0.0

The environment configuration changes.

The artifact ideally doesn't.

This gives us:

Build once
      ↓
Test
      ↓
Promote
      ↓
Deploy

rather than:

Build DEV
   ↓
Build STAGING
   ↓
Build PROD

which can introduce differences between artifacts.

8. Promotion through Git

Suppose development currently says:

image:
  tag: "2.0.0"

Staging says:

image:
  tag: "1.9.5"

Production says:

image:
  tag: "1.9.4"

After DEV validation:

DEV
2.0.0

becomes:

STAGING
2.0.0

After staging validation:

PRODUCTION
2.0.0

The promotion can happen through:

Pull Request
     ↓
Review
     ↓
Merge
     ↓
Git desired state changes
     ↓
GitOps controller
     ↓
Deployment

This is one of the most powerful GitOps ideas:

The change to production becomes a versioned, reviewable Git change.

9. Production becomes declarative

Imagine someone asks:

"What version was running in production on August 10?"

Instead of searching through CI logs, you can inspect Git history.

You might see:

Commit abc123
Update payment-service to 2.0.0

Commit def456
Update payment-service to 1.9.5

Commit ghi789
Update payment-service to 1.9.4

Git gives us:

History
Audit
Review
Diff
Rollback capability

This is a major operational advantage.

10. Rollback

Now suppose:

Production
     │
     ▼
2.0.0
     │
     ▼
PROBLEM

With GitOps, rollback can conceptually be:

Git
 │
 ├── 2.0.0
 │
 └── revert
       ↓
     1.9.5
       ↓
GitOps reconciliation
       ↓
Kubernetes
       ↓
1.9.5

So rollback can be:

Revert the desired state.

This is much cleaner than manually trying to reconstruct a previous deployment.

There are other rollback strategies too, and we'll cover them later.

11. Now let's discuss Helm

You already know we're going to learn Helm.

This is where Helm becomes useful.

Instead of:

dev/deployment.yaml
staging/deployment.yaml
production/deployment.yaml

we can have:

payment-service/
└── helm/
    ├── Chart.yaml
    ├── templates/
    └── values.yaml

Then:

values-dev.yaml
values-staging.yaml
values-prod.yaml

For example:

# values-dev.yaml

replicaCount: 1

image:
  repository: payment-service
  tag: "2.0.0"

and:

# values-prod.yaml

replicaCount: 5

image:
  repository: payment-service
  tag: "2.0.0"

Helm handles templating/package configuration.

GitOps handles:

desired state + reconciliation

Again:

Helm ≠ GitOps

Helm is one mechanism used inside a GitOps architecture.

12. Kustomize is another option

Instead of Helm:

base/
overlays/
├── dev/
├── staging/
└── production/

Kustomize can create environment-specific desired state.

Again:

GitOps
  │
  ├── Plain YAML
  ├── Helm
  ├── Kustomize
  └── Other configuration mechanisms

Argo CD and Flux can work with these approaches.

This is exactly where your platform/tool independence becomes valuable.

13. Now the production question: secrets

We don't want:

Git
 │
 └── production-password: "MyRealPassword"

GitOps introduces a challenge:

If Git is the desired-state source, how do we handle secrets safely?

Possible architecture:

Git
 │
 ├── deployment configuration
 └── reference to secret
             │
             ▼
       Secret Manager
       ├── AWS Secrets Manager
       ├── Azure Key Vault
       ├── HashiCorp Vault
       └── other systems

Or Kubernetes-integrated approaches such as:

External Secrets
Sealed Secrets
SOPS
Vault integrations

We'll have a dedicated security session for this.

Don't skip it — GitOps security is a major production topic.

14. Multi-cluster

Now imagine your company has:

AWS
├── us-east-1
├── eu-west-1
└── ap-south-1

Azure
├── East US
└── West Europe

GitOps shouldn't fundamentally care which cloud hosts Kubernetes.

Conceptually:

                    Git
                     │
                     ▼
               GitOps system
                     │
          ┌──────────┼──────────┐
          ▼          ▼          ▼
       Cluster A  Cluster B  Cluster C
          │          │          │
        AWS        AWS        Azure

That's another reason we're learning the architecture rather than becoming tied to a particular cloud.

15. Now map Argo CD and Flux onto this

At the conceptual level:

                    Git
                     │
              Desired State
                     │
          ┌──────────┴──────────┐
          │                     │
       Argo CD                Flux
          │                     │
          └──────────┬──────────┘
                     │
               Reconciliation
                     │
                     ▼
                Kubernetes

Then we will study where they differ:

Argo CD
 ├── Application model
 ├── ApplicationSet
 ├── UI
 ├── API
 ├── RBAC
 └── reconciliation

Flux
 ├── Kubernetes-native CRDs
 ├── GitRepository
 ├── Kustomization
 ├── HelmRelease
 └── reconciliation

Don't memorize those yet.

We'll eventually build the same simple deployment with both and compare them.

That will make the difference much clearer.

16. The enterprise GitOps flow

Now let's put everything together.

                         DEVELOPER
                             │
                             ▼
                     Application Git
                             │
                             ▼
                            CI
                             │
             ┌───────────────┼───────────────┐
             │               │               │
           Test            Build            Scan
                             │
                             ▼
                      Docker Image
                             │
                             ▼
                    Container Registry
                             │
                             ▼
                  Environment Repository
                             │
                       Pull Request
                             │
                       Review/Approval
                             │
                             ▼
                     Desired State
                             │
                             ▼
                 ┌────────────────────┐
                 │   GitOps Engine    │
                 │                    │
                 │ Argo CD / Flux     │
                 └─────────┬──────────┘
                           │
                     Reconciliation
                           │
                           ▼
                      Kubernetes
                           │
                           ▼
                       Live State
                           │
                           │ compare
                           └──────────────► Git

And the environment promotion:

                    IMAGE 2.0.0
                         │
                         ▼
                       DEV
                         │
                      validate
                         ▼
                     STAGING
                         │
                      validate
                         ▼
                    PRODUCTION

With Git controlling the desired state at each stage.

17. One subtle but very important architectural principle

GitOps does not necessarily mean:

Every Git commit
      ↓
Immediate production deployment

That's a common misunderstanding.

You can have:

Git commit
    ↓
CI
    ↓
DEV
    ↓
testing
    ↓
PR
    ↓
STAGING
    ↓
approval
    ↓
PRODUCTION

GitOps gives you the declarative/reconciliation mechanism.

Your organization decides the promotion policy.
