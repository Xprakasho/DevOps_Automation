==================================================== Argo CD Application =============================================================

This is the next concept we should understand before installing anything.

The easiest way to think about an Argo CD Application is:

An Application tells Argo CD what to deploy, where to deploy it, and how to manage it.

Think of it as a declaration of the relationship between Git and Kubernetes.

Git
 │
 │ "This is my application definition"
 ▼
Argo CD Application
 │
 ├── Where is the source?
 ├── What path?
 ├── Which Kubernetes cluster?
 ├── Which namespace?
 └── How should it sync?
1. The four things you should remember

An Argo CD Application mainly connects:

SOURCE
DESTINATION
SYNC POLICY
APPLICATION

1. Source

Where is the desired state?

For example:

Git repository
     ↓
path: apps/myapp

It could contain:

deployment.yaml
service.yaml
configmap.yaml

or a Helm chart.

2. Destination

Where should Argo CD deploy it?

Kubernetes cluster
       +
namespace

For example:

cluster: local
namespace: dev

So:

Source
  ↓
Git repo/path
  ↓
Destination
  ↓
Kubernetes cluster/namespace

2.a. Very simple example

Imagine Git contains:

my-repo/
└── app/
    ├── deployment.yaml
    └── service.yaml

Our Argo CD Application conceptually says:

source:
  repo: my-repo
  path: app


destination:
  cluster: my-cluster
  namespace: dev

Meaning:

Argo CD, take the manifests from my-repo/app and manage them in the dev namespace of my-cluster.

That's the core idea.

3. Now add sync policy

We already understand reconciliation.

The Application can specify how synchronization should happen.

Conceptually:

Manual sync
    ↓
Argo CD detects OutOfSync
    ↓
Human decides to sync

or:

Automated sync
    ↓
Argo CD detects OutOfSync
    ↓
Argo CD reconciles automatically

So:

Application
   │
   ├── Source
   ├── Destination
   └── Sync policy

That's enough for now.

4. The most important mental model

Don't think:

"Argo CD watches my Git repository."

Think:

"An Argo CD Application defines a desired deployment relationship, and Argo CD continuously reconciles that relationship."

For example:

                 Git
                  │
             desired state
                  │
                  ▼
          Argo CD Application
                  │
          ┌───────┴────────┐
          │                │
       Source          Destination
          │                │
      Git/path       Cluster/namespace
          │                │
          └───────┬────────┘
                  ▼
            Reconciliation
                  │
                  ▼
             Kubernetes

This is the piece that was missing between our GitOps concept and the actual Argo CD implementation.

5. Where Helm enters

This is particularly important for our learning path.

The source doesn't have to be plain YAML.

It can be:

Git
 │
 ├── Plain YAML
 │
 ├── Helm
 │
 └── Kustomize

For Helm:

Git
 │
 └── Helm Chart
        │
        ▼
     Argo CD
        │
        ▼
   Helm rendering
        │
        ▼
Kubernetes manifests
        │
        ▼
Kubernetes

So eventually your architecture becomes:

Git
 │
 ▼
Helm
 │
 ▼
Argo CD
 │
 ▼
Kubernetes

This is why we're deliberately learning YAML → Helm → Kubernetes → GitOps rather than jumping straight into an Argo CD installation.

6. One more important concept: Application status

When we eventually open the Argo CD GUI, you'll see things like:

SYNC STATUS
    Synced / OutOfSync


HEALTH
    Healthy / Progressing / Degraded

These are different concepts.

Sync

Answers:

Does the live configuration match the desired configuration?

Git desired == Kubernetes live
        ↓
      Synced

Health

Answers more like:

Is the deployed application actually healthy?

For example:

Deployment exists
but
Pods are crashing

You could therefore have:

Synced
+
Degraded

That's an important distinction we'll investigate practically later.

7. Our practical journey from here

Now we're ready to move toward the actual system.

TODAY
  │
  ▼
Argo CD Application concept       ← current
  │
  ▼
Application YAML structure
  │
  ▼
Install local Kubernetes
  │
  ▼
Install Argo CD
  │
  ▼
Open GUI
  │
  ▼
Create first Application
  │
  ▼
Git → Argo CD → Kubernetes
  │
  ▼
Change Git
  │
  ▼
Observe OutOfSync
  │
  ▼
Sync
  │
  ▼
Create manual drift with kubectl
  │
  ▼
Observe reconciliation

=====================================================================================

Let's continue with the actual Argo CD Application YAML, because this is the point where the architecture becomes concrete.

Argo CD — Application YAML

We'll use a deliberately simple example first.

apiVersion: argoproj.io/v1alpha1
kind: Application


metadata:
  name: myapp


spec:
  project: default


  source:
    repoURL: https://github.com/example/myapp.git
    targetRevision: main
    path: manifests


  destination:
    server: https://kubernetes.default.svc
    namespace: myapp


  syncPolicy:
    automated: {}

Don't try to memorize this yet. Understand the structure.

1. apiVersion
apiVersion: argoproj.io/v1alpha1

This tells Kubernetes:

This is an Argo CD Application resource.

Remember: Argo CD itself extends Kubernetes with its own API resources.

So:

Kubernetes
    │
    ├── Deployment
    ├── Service
    ├── ConfigMap
    │
    └── Argo CD Application

The Application is therefore a Kubernetes custom resource.

That's an important connection.

2. kind
kind: Application

This says:

The resource I'm creating is an Argo CD Application.

Similar to:

kind: Deployment

or:

kind: Service

3. metadata
metadata:
  name: myapp

This is simply the name of our Argo CD Application.

So:

Application name
       ↓
     myapp

Later in the GUI you'll see:

myapp

4. spec

Now we reach the important part.

spec:

spec describes what we want Argo CD to manage.

Inside it we have:

spec
│
├── project
├── source
├── destination
└── syncPolicy

This is the part I want you to remember.

5. project

project: default

Argo CD uses Projects to group and control Applications.

For now:

Application
    ↓
Project: default

We'll learn Projects properly later when we get into:

RBAC
multi-team environments
allowed repositories
allowed clusters
allowed namespaces

Don't go deep here yet.

6. source — VERY IMPORTANT
source:
  repoURL: https://github.com/example/myapp.git
  targetRevision: main
  path: manifests

This answers:

Where does the desired state come from?

repoURL
repoURL: https://github.com/example/myapp.git

The Git repository.

targetRevision
targetRevision: main

Which Git revision should Argo CD use?

Here:

main branch

It could also be a tag or commit depending on the setup.

path
path: manifests

Where inside the repository are the deployment manifests?

Imagine:

myapp/
├── README.md
├── application/
├── docs/
└── manifests/
    ├── deployment.yaml
    └── service.yaml

Then:

path: manifests

means:

Argo CD should use the manifests inside this directory.

7. The source mental model

So when you see:

source:
  repoURL: ...
  targetRevision: main
  path: manifests

think:

WHERE?
   ↓
Git repository


WHICH VERSION?
   ↓
main


WHICH DIRECTORY?
   ↓
manifests/

That's it.

8. destination

Now:

destination:
  server: https://kubernetes.default.svc
  namespace: myapp

This answers:

Where should Argo CD deploy the desired state?

Two important pieces:

server
namespace
server
server: https://kubernetes.default.svc

This represents the Kubernetes API server.

For an Argo CD instance managing its own cluster, this commonly represents the in-cluster Kubernetes API.

Conceptually:

Argo CD
   │
   ▼
Kubernetes API
namespace
namespace: myapp

The target namespace.

So:

Git
 │
 │ source
 ▼
Argo CD
 │
 │ destination
 ▼
Kubernetes
 │
 └── namespace: myapp

9. Source + Destination

This is probably the most important part of the entire YAML.

source:
  repoURL: ...
  targetRevision: main
  path: manifests


destination:
  server: ...
  namespace: myapp

Translate that into normal language:

Take the desired configuration from this Git repository, from this revision and path, and manage it in this Kubernetes cluster and namespace.

That is an Argo CD Application in practical terms.

10. syncPolicy

Now:

syncPolicy:
  automated: {}

This says automated synchronization is enabled.

Conceptually:

Git changes
     ↓
Argo CD detects difference
     ↓
OutOfSync
     ↓
automatic synchronization
     ↓
Kubernetes updated

Without automated sync, the model can instead be:

Git changes
     ↓
Argo CD detects difference
     ↓
OutOfSync
     ↓
Human clicks Sync
     ↓
Kubernetes updated

So this connects directly to our earlier:

manual vs automated reconciliation.

11. Now the complete picture

Take this YAML:

spec:


  source:
    repoURL: ...
    targetRevision: main
    path: manifests


  destination:
    server: ...
    namespace: myapp


  syncPolicy:
    automated: {}

and translate it:

                 GIT
                  │
                  │ repoURL
                  │
                  ▼
             targetRevision
                  │
                  ▼
              path: manifests
                  │
                  ▼
             ARGO CD
                  │
                  │ destination
                  ▼
        Kubernetes cluster
                  │
                  ▼
           namespace: myapp

And then:

             Git desired state
                    │
                    ▼
               Argo CD
                    │
              compare/reconcile
                    │
                    ▼
             Kubernetes live state

12. One subtle but important point

The Application YAML itself is also declarative.

That's a very GitOps-like idea.

We aren't saying:

argocd deploy myapp
argocd configure-this
argocd configure-that

Instead, we declare:

kind: Application
spec:
  source: ...
  destination: ...
  syncPolicy: ...

Then Kubernetes + Argo CD controllers act on that declaration.

So we now have two layers of desired state:

Layer 1

Argo CD Application
        ↓
"What should Argo CD manage?"


Layer 2

Kubernetes manifests
        ↓
"What should the application look like?"

This distinction becomes very important when we later learn the App-of-Apps pattern and ApplicationSets.

13. Our first practical lab is getting close

Before installing Argo CD, I want you to be comfortable reading this:

apiVersion: argoproj.io/v1alpha1
kind: Application


metadata:
  name: myapp


spec:
  project: default


  source:
    repoURL: ...
    targetRevision: main
    path: manifests
   destination:
    server: ...
    namespace: myapp

  syncPolicy:
    automated: {}

You should be able to point at each section and say:

apiVersion     → what API/resource type
kind           → Application
metadata       → Application identity
project        → Argo CD project
source         → WHERE desired state comes from
destination    → WHERE it goes
syncPolicy     → HOW synchronization happens

==============================================================================================
