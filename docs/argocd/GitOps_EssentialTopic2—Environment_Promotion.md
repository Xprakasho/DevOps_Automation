GitOps Essential Topic 2 — Environment Promotion

We already have the correct foundation:

gitops/
├── applications/
│   └── everest-demo.yaml
│
└── workloads/
    └── everest-demo/
        ├── base/
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   └── kustomization.yaml
        │
        └── overlays/
            └── dev/
                ├── namespace.yaml
                └── kustomization.yaml

Now we want to understand how the same application moves through environments without copying the whole application manifest.

1. First understand what "promotion" means

Promotion is not:

Dev Kubernetes
      ↓
copy deployment
      ↓
Staging Kubernetes
      ↓
copy deployment
      ↓
Production Kubernetes

In GitOps, promotion is primarily a change to Git desired state.

Conceptually:

                 Common Base
                     │
          ┌──────────┼──────────┐
          ▼          ▼          ▼
         DEV       STAGING      PROD
          │          │           │
       replicas     replicas    replicas
       namespace    namespace   namespace
       config       config      config

The application definition remains common.

The environment determines the differences.

2. Why Kustomize Base + Overlays is useful here

Our current Base contains:

image: nginx:1.27

and:

replicas: 2

Dev says:

namespace: everest-dev

replicas:
  - name: everest-demo
    count: 3

So the final Dev configuration is:

Base
  replicas = 2
       +
Dev
  replicas = 3
       ↓
Final desired state
  replicas = 3

Now imagine:

Staging:
replicas = 4

Production:
replicas = 6

We don't create three separate Deployments.

We create three overlays using the same Base.

3. Our target structure

We eventually want:

gitops/
└── workloads/
    └── everest-demo/
        ├── base/
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   └── kustomization.yaml
        │
        └── overlays/
            ├── dev/
            │   ├── namespace.yaml
            │   └── kustomization.yaml
            │
            ├── staging/
            │   ├── namespace.yaml
            │   └── kustomization.yaml
            │
            └── production/
                ├── namespace.yaml
                └── kustomization.yaml

But we don't need to build all three immediately.

We'll build staging first, understand it, render it, and then production will be straightforward.

4. Important distinction: promotion vs environment configuration

This is an important enterprise concept.

Suppose:

Dev
image: nginx:1.27

and after testing we want:

Staging
image: nginx:1.28

There are actually two separate ideas:

Environment configuration

Things such as:

replicas
resources
namespace
environment-specific settings
Application version

Something like:

nginx:1.27
nginx:1.28

We don't want to accidentally think:

"Promotion means changing replicas."

Promotion means:

Moving a tested application version/configuration into the next environment through Git-controlled desired state.

We'll come back to image versioning as a separate GitOps topic.

5. Let's create Staging

First create:

mkdir -p gitops/workloads/everest-demo/overlays/staging

Then create:

nano gitops/workloads/everest-demo/overlays/staging/namespace.yaml

Use:

apiVersion: v1
kind: Namespace
metadata:
  name: everest-staging
  labels:
    project: project-everest
    environment: staging

Then:

nano gitops/workloads/everest-demo/overlays/staging/kustomization.yaml

Use:

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: everest-staging

resources:
  - ../../base
  - namespace.yaml

replicas:
  - name: everest-demo
    count: 4

Notice what we didn't copy:

deployment.yaml
service.yaml

Those remain in Base.

6. Render it before doing anything with Argo CD

Run:

kubectl kustomize gitops/workloads/everest-demo/overlays/staging

We expect:

Namespace
  name: everest-staging

Deployment
  name: everest-demo
  namespace: everest-staging
  replicas: 4
  image: nginx:1.27

Service
  name: everest-demo
  namespace: everest-staging

This is the important learning point:

                    BASE
                     │
          ┌──────────┴──────────┐
          │                     │
         DEV                  STAGING
          │                     │
    namespace=dev        namespace=staging
    replicas=3           replicas=4
          │                     │
          ▼                     ▼
      final state           final state

One application definition. Multiple environment-specific desired states.

7. But don't deploy Staging yet

For this exercise, we're first learning the promotion architecture.

Our Argo CD Application currently points to:

gitops/workloads/everest-demo/overlays/dev

So it should continue deploying Dev.

Later, we'll create a second Argo CD Application:

everest-demo-staging
        ↓
gitops/workloads/everest-demo/overlays/staging
        ↓
everest-staging

Then we'll demonstrate promotion.

For now:

Your task

Create the two Staging files and run:

kubectl kustomize gitops/workloads/everest-demo/overlays/staging

Don't commit or create the Staging Argo CD Application yet.

Show me the rendered output. Then we'll examine whether the structure really represents a proper environment separation before moving forward.

=================================================================================

Perfect. The Staging overlay is rendering correctly. This is exactly the result we wanted.

Your rendered Staging state is:

Namespace
  everest-staging

Service
  everest-demo
  namespace: everest-staging

Deployment
  everest-demo
  namespace: everest-staging
  replicas: 4
  image: nginx:1.27

And notice the important part: you did not duplicate the Deployment or Service YAML.

                         base
                          │
              ┌───────────┴───────────┐
              │                       │
             dev                   staging
              │                       │
       namespace=dev          namespace=staging
       replicas=3              replicas=4
              │                       │
              └───────────┬───────────┘
                          │
                     same app
                    nginx:1.27
But let's clarify one important thing

What we have created so far is environment separation.

We haven't demonstrated promotion yet.

Currently:

Dev       → nginx:1.27
Staging   → nginx:1.27

Both environments happen to use the same version.

A promotion scenario would look more like:

DEV
nginx:1.27
   │
   │ tested/approved
   ▼
STAGING
nginx:1.27
   │
   │ tested/approved
   ▼
PRODUCTION
nginx:1.27

The important principle is:

The same application version moves through environments; environment-specific configuration can remain different.

For example:

                 DEV        STAGING       PROD
--------------------------------------------------
Namespace        dev        staging       prod
Replicas         3          4             6
Image            1.27       1.27          1.27

This is a much better mental model for enterprise GitOps than simply saying "Dev has 3 replicas, Staging has 4."

One thing I want to introduce before we deploy Staging

There are two common GitOps promotion models.

Model A — One environment tree
workloads/
└── everest-demo/
    ├── base/
    └── overlays/
        ├── dev/
        ├── staging/
        └── production/

This is what we're building now.

Promotion is represented by changes to the appropriate environment overlay.

Model B — Separate environment repositories

For example:

app-config/
    dev
    staging
    prod

platform-config/
    dev
    staging
    prod

or separate Git repositories entirely.

This can provide stronger separation and access controls in larger organizations.

We don't need Model B yet. For Project Everest, understanding Model A properly is more important.

Next practical step

Before we create another Argo CD Application, let's make the promotion model concrete.

We'll eventually have:

argocd/
├── everest-demo-dev
├── everest-demo-staging
└── everest-demo-production

pointing to:

overlays/dev
overlays/staging
overlays/production

But don't create those yet.

First, let's make one controlled change that demonstrates promotion:

Current:
Dev      → nginx:1.27
Staging  → nginx:1.27

Promotion:
Dev      → nginx:1.28
Staging  → nginx:1.27

Then we'll discuss what it means to promote the same tested image version from Dev → Staging rather than independently changing versions.

That naturally leads into our next essential topic after promotion:

Image versioning and immutable deployment.

For now, your Staging overlay is correct. Keep it uncommitted for the moment. We'll use it as part of the promotion exercise.

==========================================================

What is different today?

You destroyed the EKS cluster yesterday.

That means the Kubernetes/Argo CD state was destroyed, but the Git desired state was preserved.

So today we need to reconstruct the runtime from Git.

Current situation:

GitHub
  └── desired state ✅
      b2252de

EKS
  ├── cluster ✅
  ├── nodes ✅
  └── Argo CD ✅

Argo CD Application
  └── probably does NOT exist yet ❗

Therefore, we should not directly apply the Kustomization.

We want to restore yesterday's GitOps flow:

Git
 ↓
Argo CD Application
 ↓
Kustomize Dev Overlay
 ↓
EKS
Step 1 — Check whether the Application exists

Run:

kubectl get application everest-demo -n argocd

I expect:

No resources found

because the cluster was recreated.

Step 2 — Recreate the Argo CD Application from Git

The Application definition itself is already in your repository:

gitops/applications/everest-demo.yaml

So run:

kubectl apply -f gitops/applications/everest-demo.yaml

This is the correct action.

We are not deploying the workload directly. We're telling Argo CD:

"Here is the Application definition. Now you go to GitHub main, read the configured Kustomize overlay, and reconcile it."

Step 3 — Check Argo CD

Then:

argocd app get everest-demo

We should see:

Path:          gitops/workloads/everest-demo/overlays/dev
Sync Policy:   Automated

Eventually:

Sync Status:   Synced
Health Status: Healthy
Step 4 — Verify EKS

Then:

kubectl get all -n everest-dev

We should get:

Deployment: everest-demo
Service:    everest-demo
Pods:       3

And:

kubectl get deployment everest-demo -n everest-dev

should show:

3/3
What about the new Staging files?

Your current git status shows:

modified:
  scripts/bash/application.json

untracked:
  gitops/workloads/everest-demo/overlays/staging/

Those Staging files are today's new work. They are not part of yesterday's committed state.

So for now, leave them untracked.

We don't need to push them just to restore yesterday's Dev environment.

Once Dev is back and healthy, we'll continue today's lesson with the Staging overlay and commit it as part of the environment-promotion exercise.

So the answer is:

No new push for yesterday's work.

Use:

kubectl apply -f gitops/applications/everest-demo.yaml

—not:

kubectl apply -k gitops/workloads/everest-demo/overlays/dev

because the latter would bypass Argo CD and defeat the GitOps flow we're learning.

Let's first run kubectl get application everest-demo -n argocd.

Excellent. The promotion is complete and verified.

Your current state proves the exact workflow we wanted:

DEV
nginx:1.28
3 replicas
Healthy
   │
   │ promotion through Git
   ▼
STAGING
nginx:1.28
4 replicas
Healthy

Argo CD confirms:

everest-demo-staging
Path:         gitops/workloads/everest-demo/overlays/staging
Sync Policy:  Automated
Sync Status:  Synced
Health:       Healthy

And Kubernetes confirms:

Deployment: 4/4
Image:      nginx:1.28
Pods:       4/4 Running
What we have actually learned

This is the important part to capture in your notes.

1. One Base, multiple environments
base/
  deployment.yaml
  service.yaml

       ↓

overlays/
├── dev/
│   └── environment-specific settings
│
└── staging/
    └── environment-specific settings
2. Environment configuration is independent
Dev:
  namespace = everest-dev
  replicas  = 3

Staging:
  namespace = everest-staging
  replicas  = 4
3. Application version is promoted

Initially:

Dev       nginx:1.27
Staging   nginx:1.27

Then Dev was updated:

Dev       nginx:1.28
Staging   nginx:1.27

After Dev validation, we changed Staging:

Dev       nginx:1.28
Staging   nginx:1.28

So the same tested version moved forward.

One very important distinction

We manually performed the promotion by changing:

images:
  - name: nginx
    newTag: "1.28"

in the Staging overlay.

In a real CI/CD system, a person generally shouldn't have to manually edit that value for every release.

Eventually our pipeline will do something like:

Developer
   ↓
Git application source
   ↓
GitHub Actions
   ├── test
   ├── security scan
   ├── build
   ├── image scan
   └── push image
          │
          ▼
     image: 1.28
          │
          ▼
   update GitOps repo
          │
          ▼
       Argo CD
          │
          ▼
        EKS

That's where CI and GitOps CD meet.

But we're not finished with Environment Promotion yet

There is one more important concept we should understand before moving to the next GitOps topic:

How do we control promotion?

There are several possible approaches:

Dev → Staging → Production

Could be:

Option 1 — Direct Git change
change staging overlay
→ PR
→ review
→ merge
→ Argo CD
Option 2 — Promotion branch
main
 │
 ├── dev
 ├── staging
 └── production
Option 3 — CI-driven promotion
Build image
     ↓
Deploy Dev
     ↓
Tests
     ↓
Update Staging GitOps version
     ↓
PR
     ↓
Approval
     ↓
Argo CD

For Project Everest, we don't need to learn every Git branching strategy. The important enterprise pattern is:

CI produces and validates the artifact; Git records the desired environment state; Argo CD reconciles that state.

And critically:

GitHub Actions
      ❌ kubectl apply production

GitHub Actions
      ↓
update Git desired state
      ↓
Argo CD
      ↓
Kubernetes

That's the architecture we eventually want to implement.

Environment Promotion checkpoint

I'd mark this topic:

Environment Promotion — DONE ✅

We have actually demonstrated:

Base + overlays
Dev and Staging environments
Independent environment configuration
Separate Argo CD Applications
Automated synchronization
Dev release
Dev validation
Promotion of the same version to Staging
Git as the promotion mechanism
Argo CD as the deployment/reconciliation mechanism
Next essential GitOps topic

Application Repository vs Environment/GitOps Repository design.

This is worth learning before Image Versioning because it answers a fundamental enterprise question:

Where should application source code, Dockerfiles, Helm/Kustomize configuration, and environment desired state actually live?

====================================================================================

Yes — this is expected after recreating the cluster.

Your Argo CD Application is healthy:

everest-demo   Synced   Healthy

The problem is only your local Argo CD CLI session:

Unauthenticated
invalid session: token signature is invalid

Because the EKS/Argo CD installation was recreated, the Argo CD server has a new signing key. Your old CLI token is no longer valid.

Fix the CLI login

First make sure the port-forward is running in another terminal:

kubectl port-forward svc/argocd-server -n argocd 8080:443

Then in your current terminal:

argocd logout localhost:8080

If it says there is no active session, that's fine.

Get the new initial admin password:

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo

Then log in:

argocd login localhost:8080 --username admin --insecure

Enter the new password.

Verify:

argocd cluster list

Then:

argocd app get everest-demo

You should again see:

Path:          gitops/workloads/everest-demo/overlays/dev
Sync Policy:   Automated
Sync Status:   Synced
Health Status: Healthy

And finally:

kubectl get all -n everest-dev
Important distinction

This is a useful thing to remember:

Git state
    ↓
PERSISTED
GitHub main

while:

EKS
  ↓
destroyed/recreated
  ↓
Argo CD
  ↓
new installation
  ↓
new authentication/session state

So your GitOps configuration survived the EKS destruction, which is exactly what we wanted. The new Argo CD simply reconciled the Git state again.

Once argocd app get everest-demo works, we are back at yesterday's exact checkpoint, and we can continue today's Environment Promotion work with the Staging overlay you already created.

Now continue Environment Promotion

We also have our new local Staging overlay:

gitops/workloads/everest-demo/overlays/staging/
├── namespace.yaml
└── kustomization.yaml

It renders correctly:

namespace: everest-staging
replicas: 4
image: nginx:1.27

But notice your current Git status from earlier:

Untracked:
gitops/workloads/everest-demo/overlays/staging/

So Staging is not in Git yet.

Before we deploy Staging through Argo CD, I want to make one important architectural distinction.

Environment promotion

We want this eventual flow:

                SAME APPLICATION
                       │
                       ▼
                    DEV
                 nginx:1.27
                       │
                 validation
                       │
                       ▼
                  STAGING
                 nginx:1.27
                       │
                 validation
                       │
                       ▼
                 PRODUCTION
                 nginx:1.27

while environment configuration can differ:

              DEV       STAGING       PROD
              ───       ───────       ────
replicas       3           4            6
namespace      dev       staging        prod

The key idea is:

Promotion moves the tested application version forward; environment-specific configuration remains specific to each environment.

Our practical exercise

We'll do this in three stages.

Stage 1 — Establish Staging

We already created and rendered:

overlays/staging

Now we'll put it into Git and create a separate Argo CD Application:

everest-demo-staging
        ↓
overlays/staging
        ↓
everest-staging

At that point we'll have:

Argo CD
├── everest-demo
│   └── overlays/dev
│       └── everest-dev
│           └── 3 replicas
│
└── everest-demo-staging
    └── overlays/staging
        └── everest-staging
            └── 4 replicas
Stage 2 — Demonstrate promotion

Then we'll introduce an application version change.

For example:

nginx:1.27 → nginx:1.28

Dev gets the new version first.

We verify Dev.

Then we promote that same version to Staging.

DEV
nginx:1.28
   ↓
tested
   ↓
STAGING
nginx:1.28
Stage 3 — Understand Production

We'll create the Production overlay conceptually/practically and understand how the same promotion model extends:

DEV → STAGING → PRODUCTION

We don't need to overcomplicate this with separate repositories yet.

First action now

Since your Staging render is already verified, let's check the current Git state:

git status

Then stage only:

git add gitops/workloads/everest-demo/overlays/staging/

Do not stage:

scripts/bash/application.json

Then:

git diff --cached --stat

We should see only the two new Staging files.

Once that is confirmed, we'll commit the Staging environment and create its Argo CD Application. This will be our first real multi-environment GitOps setup.

=================================================================

Perfect. We are fully back at yesterday's checkpoint.

Your screenshots confirm:

EKS/Argo CD runtime
EKS
├── nodes: Ready
├── Argo CD: Running
└── everest-dev
    ├── Deployment: 3/3
    ├── Pods: 3 Running
    └── Service: ClusterIP
Argo CD

Your new CLI session is valid:

argocd login ... logged in successfully

And the Application is:

Path:          gitops/workloads/everest-demo/overlays/dev
Sync Policy:   Automated
Sync Status:   Synced to main (b2252de)
Health Status: Healthy

So we have restored everything from Git, not by manually recreating the workload. That's exactly the GitOps behavior we wanted to demonstrate.

Now continue Environment Promotion

We also have our new local Staging overlay:

gitops/workloads/everest-demo/overlays/staging/
├── namespace.yaml
└── kustomization.yaml

It renders correctly:

namespace: everest-staging
replicas: 4
image: nginx:1.27

But notice your current Git status from earlier:

Untracked:
gitops/workloads/everest-demo/overlays/staging/

So Staging is not in Git yet.

Before we deploy Staging through Argo CD, I want to make one important architectural distinction.

Environment promotion

We want this eventual flow:

                SAME APPLICATION
                       │
                       ▼
                    DEV
                 nginx:1.27
                       │
                 validation
                       │
                       ▼
                  STAGING
                 nginx:1.27
                       │
                 validation
                       │
                       ▼
                 PRODUCTION
                 nginx:1.27

while environment configuration can differ:

              DEV       STAGING       PROD
              ───       ───────       ────
replicas       3           4            6
namespace      dev       staging        prod

The key idea is:

Promotion moves the tested application version forward; environment-specific configuration remains specific to each environment.

Our practical exercise

We'll do this in three stages.

Stage 1 — Establish Staging

We already created and rendered:

overlays/staging

Now we'll put it into Git and create a separate Argo CD Application:

everest-demo-staging
        ↓
overlays/staging
        ↓
everest-staging

At that point we'll have:

Argo CD
├── everest-demo
│   └── overlays/dev
│       └── everest-dev
│           └── 3 replicas
│
└── everest-demo-staging
    └── overlays/staging
        └── everest-staging
            └── 4 replicas
Stage 2 — Demonstrate promotion

Then we'll introduce an application version change.

For example:

nginx:1.27 → nginx:1.28

Dev gets the new version first.

We verify Dev.

Then we promote that same version to Staging.

DEV
nginx:1.28
   ↓
tested
   ↓
STAGING
nginx:1.28
Stage 3 — Understand Production

We'll create the Production overlay conceptually/practically and understand how the same promotion model extends:

DEV → STAGING → PRODUCTION

We don't need to overcomplicate this with separate repositories yet.

First action now

Since your Staging render is already verified, let's check the current Git state:

git status

Then stage only:

git add gitops/workloads/everest-demo/overlays/staging/

Do not stage:

scripts/bash/application.json

Then:

git diff --cached --stat

We should see only the two new Staging files.

Once that is confirmed, we'll commit the Staging environment and create its Argo CD Application. This will be our first real multi-environment GitOps setup.

Exactly right. The staged diff is clean.

You have:

Changes to be committed:
  gitops/workloads/everest-demo/overlays/staging/kustomization.yaml
  gitops/workloads/everest-demo/overlays/staging/namespace.yaml

And importantly, this remains unstaged:

modified: scripts/bash/application.json

So we can safely commit only the Staging overlay.

1. Commit Staging overlay
git commit -m "Add Everest demo staging overlay"

Then push:

git push origin main

After the push, verify:

git status

You should see only:

modified: scripts/bash/application.json

and no untracked Staging files.

2. Then create the Staging Argo CD Application

We want a second Application:

everest-demo-staging
        │
        ▼
gitops/workloads/everest-demo/overlays/staging
        │
        ▼
everest-staging

Create:

nano gitops/applications/everest-demo-staging.yaml

Use:

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: everest-demo-staging
  namespace: argocd
spec:
  project: default

  source:
    repoURL: https://github.com/Xprakasho/DevOps_Automation.git
    targetRevision: main
    path: gitops/workloads/everest-demo/overlays/staging

  destination:
    server: https://kubernetes.default.svc
    namespace: everest-staging

  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

Notice the important differences from Dev:

Dev:
  Application: everest-demo
  Path: overlays/dev
  Namespace: everest-dev

Staging:
  Application: everest-demo-staging
  Path: overlays/staging
  Namespace: everest-staging

Everything else is deliberately the same.

3. Important GitOps point

The Application definition should also live in Git, just like our Dev Application.

So don't immediately kubectl apply it.

First:

git add gitops/applications/everest-demo-staging.yaml
git diff --cached

Then we'll commit/push it.

That gives us:

Git
│
├── applications/
│   ├── everest-demo.yaml
│   └── everest-demo-staging.yaml
│
└── workloads/
    └── everest-demo/
        ├── base/
        └── overlays/
            ├── dev/
            └── staging/

This is the first point where our Git repository starts representing multiple environments as independently deployable GitOps Applications.

First commit/push the Staging overlay. Then we'll create and commit the Staging Application definition.

=========================================

Yes — the staged diff looks correct.

Your new file:

gitops/applications/everest-demo-staging.yaml

contains the right staging-specific values:

metadata:
  name: everest-demo-staging
  namespace: argocd

and:

path: gitops/workloads/everest-demo/overlays/staging

with:

namespace: everest-staging

and automated sync/self-healing.

The line:

\ No newline at end of file

isn't a functional problem, but let's add the final newline before committing. It's good repository hygiene.

1. Add the newline

You can simply run:

printf '\n' >> gitops/applications/everest-demo-staging.yaml

Then check:

git diff --cached

Important: because the file is already staged, the newline modification is now in the working tree but not necessarily in the index. So stage it again:

git add gitops/applications/everest-demo-staging.yaml

Then:

git diff --cached --check

If there is no output, that's good.

2. Verify what is staged
git diff --cached --stat

At this point we should have:

gitops/workloads/everest-demo/overlays/staging/kustomization.yaml
gitops/workloads/everest-demo/overlays/staging/namespace.yaml
gitops/applications/everest-demo-staging.yaml

And not:

scripts/bash/application.json
3. Commit both pieces together

These two changes belong together because the Staging environment consists of:

Staging overlay
      +
Argo CD Application

So:

git commit -m "Add Everest demo staging environment"

Then:

git push origin main
4. Then we create it in the current Argo CD

After the push, we will deliberately do:

kubectl apply -f gitops/applications/everest-demo-staging.yaml

This is slightly different from the Dev setup we had yesterday: we're bootstrapping the Argo CD Application from the Git-managed definition.

Then Argo CD should reconcile:

GitHub main
    │
    ▼
everest-demo-staging Application
    │
    ▼
overlays/staging
    │
    ▼
everest-staging
    ├── Deployment
    │     └── 4 replicas
    └── Service

At that point we'll have Dev and Staging running simultaneously from the same Base, which is the important practical demonstration for today's Environment Promotion lesson.

===============================================================

You're right — I mixed up the sequence. We should not commit the Argo CD Application yet.

From your screenshot, the only thing currently staged is:

new file: gitops/applications/everest-demo-staging.yaml

And scripts/bash/application.json is still correctly untouched.

Let's stop here and establish exactly what we have.

1. Unstage the Staging Application

Since we haven't finished creating the Staging setup:

git restore --staged gitops/applications/everest-demo-staging.yaml

This does not delete the file. It just removes it from the staging area.

2. Check what actually exists in the Staging overlay

Run:

find gitops/workloads/everest-demo/overlays/staging -maxdepth 1 -type f -print

Then:

git status --short
Why we're doing this

Our intended sequence should be:

1. Create Staging overlay
       ↓
2. Render and verify Kustomize
       ↓
3. Commit + push Staging overlay
       ↓
4. Create Staging Argo CD Application definition
       ↓
5. Commit + push Application definition
       ↓
6. Bootstrap Application into Argo CD
       ↓
7. Verify everest-staging

We should not skip from step 2 to step 5.

Also, you said you already pushed "staging.yaml". If by that you mean the Staging overlay files, then we simply need to verify that. If you mean only everest-demo-staging.yaml, then we'll create the overlay now.

So first run these two:

find gitops/workloads/everest-demo/overlays/staging -maxdepth 1 -type f -print
git status --short

Then we'll proceed based on the actual repository state rather than assuming.

===================================================

Yes — now the state is clear. Your screenshot confirms the correction.

Current state

The Staging overlay does exist:

gitops/workloads/everest-demo/overlays/staging/
├── kustomization.yaml
└── namespace.yaml

And because git status --short does not show those files as untracked, they are already tracked in Git.

The only new untracked file is:

?? gitops/applications/everest-demo-staging.yaml

And your unrelated change remains untouched:

M scripts/bash/application.json

So our actual sequence is:

Staging overlay
    ✅ already created
    ✅ already committed/pushed

Staging Argo CD Application
    ⏳ created locally
    ⏳ not committed/pushed yet

That's exactly where we should be.

First, let's verify the Staging overlay is actually on GitHub

Run:

git ls-tree -r --name-only origin/main gitops/workloads/everest-demo/overlays/staging

We should see:

gitops/workloads/everest-demo/overlays/staging/kustomization.yaml
gitops/workloads/everest-demo/overlays/staging/namespace.yaml

If those are present, then do not recreate or modify the overlay.

Then stage only the Application
git add gitops/applications/everest-demo-staging.yaml

Check:

git status

We want:

Changes to be committed:
    new file: gitops/applications/everest-demo-staging.yaml

Changes not staged:
    modified: scripts/bash/application.json

Then:

git diff --cached --check
git diff --cached

If that looks correct:

git commit -m "Add Everest demo staging Argo CD application"
git push origin main
Then we bootstrap the Application

After the push:

kubectl apply -f gitops/applications/everest-demo-staging.yaml

Then:

argocd app get everest-demo-staging

and:

kubectl get all -n everest-staging

We should end up with:

everest-dev
└── everest-demo
    └── 3 replicas

everest-staging
└── everest-demo
    └── 4 replicas

So we're not creating the Staging overlay now — that's already done. We're only adding its Argo CD Application definition.

Start with the git ls-tree command above so we verify the overlay is indeed in origin/main before we commit the Application.

================================================================

Excellent. Staging is now successfully deployed and healthy. We have reached the important point for today's Environment Promotion lesson.

Your output confirms:

Argo CD Application
everest-demo-staging
        ↓
Path: overlays/staging
        ↓
Sync: Synced
Health: Healthy

And EKS:

everest-staging
├── Deployment: 4/4
├── Pods: 4 Running
└── Service: ClusterIP

So we now have two independent environments from the same Base:

                    Base
                     │
             ┌───────┴────────┐
             │                │
            DEV            STAGING
             │                │
       everest-dev      everest-staging
       replicas: 3      replicas: 4
       nginx:1.27       nginx:1.27
             │                │
             ▼                ▼
        Argo CD App      Argo CD App
One interesting detail in your output

Both environments have a ReplicaSet like:

everest-demo-97cdf7fbd

That's expected.

They use the same Deployment template:

nginx:1.27
same probes
same resources
same labels

The environment-specific differences are applied by the overlays:

Dev:
  namespace = everest-dev
  replicas = 3

Staging:
  namespace = everest-staging
  replicas = 4
But we haven't actually demonstrated "promotion" yet

This distinction is important.

What we've done so far is:

Environment provisioning/separation

We have:

Dev     → nginx:1.27
Staging → nginx:1.27

Now we want to demonstrate:

A tested application version moves from Dev → Staging.

For example, we can simulate a new release:

Current:

Dev       nginx:1.27
Staging   nginx:1.27

Then a new application version is released:

nginx:1.28

We deploy it to Dev first:

Dev       nginx:1.28
Staging   nginx:1.27

After Dev validation, we promote the same version:

Dev       nginx:1.28
Staging   nginx:1.28

Notice what we're not doing:

Dev       nginx:1.28
Staging   nginx:1.29   ❌

Promotion means the tested artifact/version moves forward.

This is the model I want you to remember
Developer
    │
    ▼
New application version
    │
    ▼
DEV
    │
    │ validation
    ▼
STAGING
    │
    │ validation
    ▼
PRODUCTION

While:

Environment configuration
        ≠
Application version

For example:

	Dev	Staging	Production
Namespace	everest-dev	everest-staging	everest-prod
Replicas	3	4	6
Application version	1.28	1.28	1.28

The environment settings remain different, but the same application version is promoted.

Next practical exercise

Before changing anything, let's make sure both Applications are visible:

argocd app list

We should see approximately:

everest-demo
everest-demo-staging

both:

Synced
Healthy

Then we'll simulate a release from:

nginx:1.27 → nginx:1.28

only in Dev first, validate the rollout, and then promote that same version to Staging.

That will turn what we've learned into an actual Dev → Staging promotion workflow, rather than just having two overlays.

===================================================================

Perfect. This confirms the multi-environment GitOps setup is healthy.

You now have two Argo CD Applications:

everest-demo
    ↓
overlays/dev
    ↓
everest-dev
    ↓
Synced / Healthy / Auto

everest-demo-staging
    ↓
overlays/staging
    ↓
everest-staging
    ↓
Synced / Healthy / Auto

So environment separation is complete.

Now we move to the actual promotion exercise

Current state:

Dev:
  nginx:1.27
  replicas: 3

Staging:
  nginx:1.27
  replicas: 4

We will simulate a new release:

nginx:1.28

But we'll deliberately promote it in stages:

                 nginx:1.28
                     │
                     ▼
                  DEV
                     │
              validate rollout
                     │
                     ▼
                STAGING
                     │
              validate rollout
                     │
                     ▼
                Production
Important architecture point

Because our current Base contains:

image: nginx:1.27

we should not change Base to nginx:1.28 for this exercise.

Why?

Because Base represents the common application definition, while the environment overlay should allow us to control the version being promoted.

So this is a good opportunity to improve our Kustomize design slightly.

We'll make the image version an overlay-controlled value.

For Dev:

nginx:1.28

while Staging remains:

nginx:1.27

Then after Dev validation, we change only Staging:

nginx:1.27 → nginx:1.28

That gives us a very clear Git-based promotion:

Commit A
Dev → 1.28
Staging → 1.27

        ↓ validation

Commit B
Dev → 1.28
Staging → 1.28

This is much closer to how real GitOps promotion works.

One thing before we change anything

Let's inspect the current Dev and Staging Kustomizations:

cat gitops/workloads/everest-demo/overlays/dev/kustomization.yaml

and:

cat gitops/workloads/everest-demo/overlays/staging/kustomization.yaml

Then we'll add the image override using Kustomize's images: mechanism and render both environments before touching the live deployment.

That will teach you another essential Kustomize feature without turning this into a Kustomize feature catalog.

=====================================================================

Good. We have the two overlay definitions in front of us now, and there is one thing I want to correct before we start the promotion exercise.

Current structure

Dev:

namespace: everest-dev

resources:
  - ../../base

replicas:
  - name: everest-demo
    count: 3

Staging:

namespace: everest-staging

resources:
  - ../../base
  - namespace.yaml

replicas:
  - name: everest-demo
    count: 4

So Staging explicitly owns its Namespace resource, but Dev currently does not.

That is inconsistent with the structure we built yesterday. The Dev overlay originally had:

resources:
  - ../../base
  - namespace.yaml

Let's restore that before continuing. It is cleaner for each environment overlay to own its namespace definition.

1. Check whether Dev namespace.yaml still exists

Run:

ls -l gitops/workloads/everest-demo/overlays/dev/

We should have:

kustomization.yaml
namespace.yaml

If namespace.yaml exists, edit the Dev kustomization:

nano gitops/workloads/everest-demo/overlays/dev/kustomization.yaml

and make the resources section:

resources:
  - ../../base
  - namespace.yaml

Then render:

kubectl kustomize gitops/workloads/everest-demo/overlays/dev

We want to see:

Namespace: everest-dev
Deployment: everest-demo
  replicas: 3
  image: nginx:1.27
Service: everest-demo
Then the promotion mechanism

Once that is confirmed, we'll use Kustomize's images override.

This is an important concept, but we don't need to study every Kustomize transformer.

Base stays:

image: nginx:1.27

Then each environment can explicitly declare its application version.

For example, Dev:

images:
  - name: nginx
    newTag: "1.28"

Staging initially:

images:
  - name: nginx
    newTag: "1.27"

So:

BASE
nginx:1.27
   │
   ├── DEV overlay
   │     newTag: 1.28
   │     ↓
   │   nginx:1.28
   │
   └── STAGING overlay
         newTag: 1.27
         ↓
       nginx:1.27

Then promotion is simply:

STAGING

1.27
  ↓
change Git
  ↓
1.28

The same image version that was tested in Dev is promoted to Staging.

That gives us a very clean Git history:

Commit 1
Dev     → 1.28
Staging → 1.27

        ↓ Dev validation

Commit 2
Dev     → 1.28
Staging → 1.28

That's the concept I want you to learn from this exercise.

So first, don't change the image yet.

Run:

ls -l gitops/workloads/everest-demo/overlays/dev/

and show me whether namespace.yaml is there. Then we'll make the small namespace correction and proceed with the actual promotion.

===================================================

Perfect. The Dev overlay is already correct. The rendered output proves that namespace.yaml is included in the Kustomization, so no namespace correction is needed.

Current baseline is:

DEV
├── namespace: everest-dev
├── replicas: 3
└── image: nginx:1.27

STAGING
├── namespace: everest-staging
├── replicas: 4
└── image: nginx:1.27

Now we can perform the actual promotion exercise.

Step 1 — Release 1.28 to Dev only

Edit:

nano gitops/workloads/everest-demo/overlays/dev/kustomization.yaml

Add an images: section after replicas::

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: everest-dev

resources:
  - ../../base
  - namespace.yaml

replicas:
  - name: everest-demo
    count: 3

images:
  - name: nginx
    newTag: "1.28"

Notice something important: we are not editing base/deployment.yaml.

Base can still contain:

image: nginx:1.27

but Dev overrides it during rendering:

Base nginx:1.27
       +
Dev images.newTag: 1.28
       ↓
Rendered Dev
nginx:1.28

Staging has no such change yet, so it stays on 1.27.

Step 2 — Render both environments before committing

Dev:

kubectl kustomize gitops/workloads/everest-demo/overlays/dev \
  | grep -E "image:|replicas:"

Expected:

replicas: 3
- image: nginx:1.28

Then Staging:

kubectl kustomize gitops/workloads/everest-demo/overlays/staging \
  | grep -E "image:|replicas:"

Expected:

replicas: 4
- image: nginx:1.27

This is the state we're deliberately creating:

             VERSION      REPLICAS

DEV            1.28          3
                ↑
           new release

STAGING        1.27          4
                ↑
          previous release

That separation is fundamental to promotion. Dev can move ahead without automatically changing Staging.

Don't modify Staging yet. Once the renders show Dev=1.28 and Staging=1.27, we'll commit only the Dev version change, let Argo CD roll out 1.28, validate it, and then promote that exact version to Staging.

========================================================

Exactly. The renders are correct.

We now have the deliberate promotion state:

Environment   Image       Replicas
-----------------------------------
Dev           nginx:1.28     3
Staging       nginx:1.27     4

This is what we wanted.

Now commit only the Dev release

Before committing, check:

git status

You should see the Dev kustomization.yaml modified, plus your unrelated:

scripts/bash/application.json

Do not stage the latter.

Stage only:

git add gitops/workloads/everest-demo/overlays/dev/kustomization.yaml

Then verify:

git diff --cached

You should see only:

images:
  - name: nginx
    newTag: "1.28"

Then:

git commit -m "Promote nginx 1.28 to dev"
git push origin main
What will happen after the push

Because the Dev Argo CD Application is automated:

GitHub main
    │
    │ Dev overlay changed
    ▼
Argo CD
    │
    ▼
everest-dev
    │
    └── nginx:1.28

Staging will remain untouched:

everest-staging
└── nginx:1.27

Then we'll verify the Dev rollout:

kubectl get pods -n everest-dev

and:

kubectl get deployment everest-demo -n everest-dev \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

We expect:

nginx:1.28

Once Dev is healthy, that same 1.28 will be promoted to Staging by changing only the Staging overlay.

That two-step Git history is the key lesson:

Commit A
Dev     → 1.28
Staging → 1.27

        ↓ validate Dev

Commit B
Dev     → 1.28
Staging → 1.28

That's the GitOps promotion pattern we're learning.

==================================================================

Perfect. Dev promotion is successful.

Your live EKS state confirms:

everest-dev
├── Pod 1   Running
├── Pod 2   Running
└── Pod 3   Running

Deployment:
  3/3 available

Image:
  nginx:1.28

So the promotion sequence has reached the first checkpoint:

Git commit
Dev overlay → nginx:1.28
        ↓
GitHub
        ↓
Argo CD
        ↓
EKS
        ↓
Dev running nginx:1.28 ✅

And importantly, Staging should still be on nginx:1.27.

Let's verify that before promoting:

kubectl get deployment everest-demo -n everest-staging \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

Expected:

nginx:1.27

Then:

kubectl get deployment everest-demo -n everest-staging

Expected:

READY   UP-TO-DATE   AVAILABLE
4/4     4            4
Why this verification matters

We have intentionally created:

                 DEV             STAGING
              nginx:1.28        nginx:1.27
                  │                  │
                  │                  │
               tested             waiting

Now we promote the exact same 1.28 version to Staging.

That means we'll change only:

gitops/workloads/everest-demo/overlays/staging/kustomization.yaml

from its current state to include:

images:
  - name: nginx
    newTag: "1.28"

Then:

Git
 ↓
Staging overlay changes
 ↓
Argo CD
 ↓
everest-staging
 ↓
nginx:1.28

That is the actual GitOps promotion we're demonstrating.

First run the Staging image check above. If it says nginx:1.27, we're ready for the promotion.

======================================================

Exactly. This confirms the promotion checkpoint:

Dev       → nginx:1.28 ✅
Staging   → nginx:1.27 ⏳

Now we can promote the exact same nginx:1.28 version to Staging.

Step 1 — Edit only the Staging overlay

Open:

nano gitops/workloads/everest-demo/overlays/staging/kustomization.yaml

Add:

images:
  - name: nginx
    newTag: "1.28"

So the complete file becomes:

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: everest-staging

resources:
  - ../../base
  - namespace.yaml

replicas:
  - name: everest-demo
    count: 4

images:
  - name: nginx
    newTag: "1.28"
Step 2 — Render before committing

Run:

kubectl kustomize gitops/workloads/everest-demo/overlays/staging \
  | grep -E "image:|replicas:"

Expected:

replicas: 4
- image: nginx:1.28

This proves the desired state has changed only for Staging.

Step 3 — Check Git diff
git diff -- gitops/workloads/everest-demo/overlays/staging/kustomization.yaml

We should see only the new images: block.

Then stage only this file:

git add gitops/workloads/everest-demo/overlays/staging/kustomization.yaml

Check:

git diff --cached

Do not stage:

scripts/bash/application.json
Step 4 — Commit the promotion
git commit -m "Promote nginx 1.28 to staging"
git push origin main

Then Argo CD will detect:

Git
 ↓
Staging overlay
 nginx:1.28
 ↓
Argo CD
 ↓
everest-staging

Verify:

argocd app get everest-demo-staging

and:

kubectl get deployment everest-demo -n everest-staging

Then verify the actual image:

kubectl get deployment everest-demo -n everest-staging \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

Expected:

nginx:1.28
The promotion we just demonstrated

This is the important part to capture in your notes:

Before:

Dev       nginx:1.28
Staging   nginx:1.27


After promotion:

Dev       nginx:1.28
Staging   nginx:1.28

The application version was promoted through Git, while the environment-specific configuration remained different:

Dev       3 replicas
Staging   4 replicas

That is the core GitOps environment-promotion model.

After we verify Staging is running 1.28, we'll discuss how Production fits into this model and, importantly, how real CI/CD would automate these Git changes instead of us manually editing the overlays.

=====================================================

Excellent. The promotion is complete and verified.

Your current state proves the exact workflow we wanted:

DEV
nginx:1.28
3 replicas
Healthy
   │
   │ promotion through Git
   ▼
STAGING
nginx:1.28
4 replicas
Healthy

Argo CD confirms:

everest-demo-staging
Path:         gitops/workloads/everest-demo/overlays/staging
Sync Policy:  Automated
Sync Status:  Synced
Health:       Healthy

And Kubernetes confirms:

Deployment: 4/4
Image:      nginx:1.28
Pods:       4/4 Running
What we have actually learned

This is the important part to capture in your notes.

1. One Base, multiple environments
base/
  deployment.yaml
  service.yaml

       ↓

overlays/
├── dev/
│   └── environment-specific settings
│
└── staging/
    └── environment-specific settings
2. Environment configuration is independent
Dev:
  namespace = everest-dev
  replicas  = 3

Staging:
  namespace = everest-staging
  replicas  = 4
3. Application version is promoted

Initially:

Dev       nginx:1.27
Staging   nginx:1.27

Then Dev was updated:

Dev       nginx:1.28
Staging   nginx:1.27

After Dev validation, we changed Staging:

Dev       nginx:1.28
Staging   nginx:1.28

So the same tested version moved forward.

One very important distinction

We manually performed the promotion by changing:

images:
  - name: nginx
    newTag: "1.28"

in the Staging overlay.

In a real CI/CD system, a person generally shouldn't have to manually edit that value for every release.

Eventually our pipeline will do something like:

Developer
   ↓
Git application source
   ↓
GitHub Actions
   ├── test
   ├── security scan
   ├── build
   ├── image scan
   └── push image
          │
          ▼
     image: 1.28
          │
          ▼
   update GitOps repo
          │
          ▼
       Argo CD
          │
          ▼
        EKS

That's where CI and GitOps CD meet.

But we're not finished with Environment Promotion yet

There is one more important concept we should understand before moving to the next GitOps topic:

How do we control promotion?

There are several possible approaches:

Dev → Staging → Production

Could be:

Option 1 — Direct Git change
change staging overlay
→ PR
→ review
→ merge
→ Argo CD
Option 2 — Promotion branch
main
 │
 ├── dev
 ├── staging
 └── production
Option 3 — CI-driven promotion
Build image
     ↓
Deploy Dev
     ↓
Tests
     ↓
Update Staging GitOps version
     ↓
PR
     ↓
Approval
     ↓
Argo CD

For Project Everest, we don't need to learn every Git branching strategy. The important enterprise pattern is:

CI produces and validates the artifact; Git records the desired environment state; Argo CD reconciles that state.

And critically:

GitHub Actions
      ❌ kubectl apply production

GitHub Actions
      ↓
update Git desired state
      ↓
Argo CD
      ↓
Kubernetes

That's the architecture we eventually want to implement.

Environment Promotion checkpoint

I'd mark this topic:

Environment Promotion — DONE ✅

We have actually demonstrated:

Base + overlays
Dev and Staging environments
Independent environment configuration
Separate Argo CD Applications
Automated synchronization
Dev release
Dev validation
Promotion of the same version to Staging
Git as the promotion mechanism
Argo CD as the deployment/reconciliation mechanism
Next essential GitOps topic

Application Repository vs Environment/GitOps Repository design.

This is worth learning before Image Versioning because it answers a fundamental enterprise question:

Where should application source code, Dockerfiles, Helm/Kustomize configuration, and environment desired state actually live?

We'll keep it practical and use our current DevOps_Automation repository as the example.

=======================================================================
