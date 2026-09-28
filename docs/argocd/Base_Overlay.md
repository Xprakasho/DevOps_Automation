=============== Base Overlay ===========================

Let's start with Kustomize Base + Overlay, because it is the missing foundation for our Dev → Staging → Production model.

We will use the existing Everest application, not create another demo.

Current:

gitops/environments/dev/everest-demo/

We will evolve it toward:

gitops/
├── applications/
│   └── everest-demo.yaml
│
└── applications/
    └── everest-demo/
        ├── base/
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   ├── namespace.yaml
        │   └── kustomization.yaml
        │
        └── overlays/
            ├── dev/
            │   └── kustomization.yaml
            ├── staging/
            │   └── kustomization.yaml
            └── production/
                └── kustomization.yaml

But don't create this yet.

First, we'll understand exactly what Base and Overlay solve, then we'll refactor your existing working manifests carefully so we don't break the application.

============================================

Let's start GitOps Essential Topic 1: Kustomize Base + Overlays.

We will use the existing everest-demo and refactor it carefully. No new demo.

1. The problem Kustomize solves

Right now we effectively have one environment:

gitops/
└── environments/
    └── dev/
        └── everest-demo/
            ├── deployment.yaml
            ├── service.yaml
            ├── namespace.yaml
            └── kustomization.yaml

Suppose we add staging and production.

The naive approach is:

dev/
  deployment.yaml
  service.yaml
  namespace.yaml

staging/
  deployment.yaml
  service.yaml
  namespace.yaml

production/
  deployment.yaml
  service.yaml
  namespace.yaml

That creates duplication.

If we change the Deployment's probes, labels, security context, or container port, we potentially have to modify three copies.

Kustomize gives us:

                    BASE
                     │
          common application definition
                     │
          ┌──────────┼──────────┐
          ↓          ↓          ↓
         DEV       STAGING     PROD
       overlay     overlay    overlay

The base contains what is common.

The overlay contains what differs.

2. Base vs Overlay

Think about it this way.

Base

"What is this application?"

For Everest:

Deployment
Service
common labels
container
ports
probes
resource definitions
Overlay

"How should this application run in this environment?"

For example:

Dev:
  replicas: 2
  image: ...
  resources: small

Staging:
  replicas: 3
  image: ...
  resources: medium

Production:
  replicas: 5
  image: ...
  resources: larger

The base should not contain unnecessary environment-specific assumptions.

3. One important architectural correction

Earlier we had:

gitops/environments/dev/everest-demo/

We don't actually need to duplicate the entire application under each environment.

For Project Everest, I recommend this structure:

gitops/
├── applications/
│   └── everest-demo.yaml
│
└── workloads/
    └── everest-demo/
        ├── base/
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   ├── namespace.yaml
        │   └── kustomization.yaml
        │
        └── overlays/
            ├── dev/
            │   └── kustomization.yaml
            ├── staging/
            │   └── kustomization.yaml
            └── production/
                └── kustomization.yaml

This separates:

applications/
    Argo CD Application definitions

workloads/
    Kubernetes desired state

That's a cleaner mental model.

4. Before changing anything — capture current state

We have a working application, so don't modify it blindly.

Run:

cd ~/DevOps_Automation/DevOps_Automation

Then:

cat gitops/environments/dev/everest-demo/kustomization.yaml

Then:

cat gitops/environments/dev/everest-demo/deployment.yaml

Then:

cat gitops/environments/dev/everest-demo/service.yaml

Then:

cat gitops/environments/dev/everest-demo/namespace.yaml

And finally:

kubectl get deployment everest-demo -n everest-dev

We want to preserve the currently working state:

3/3
3
3
5. The refactoring we will perform

Once we've captured the current state, we will create:

gitops/workloads/everest-demo/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── namespace.yaml
│   └── kustomization.yaml
│
└── overlays/
    └── dev/
        └── kustomization.yaml

The base will contain the common resources.

The dev overlay will say something like:

resources:
  - ../../base

patches:
  ...

For example, the base might define:

replicas: 2

while Dev might override it to:

replicas: 3

That gives us a very important separation:

Base:
  Application defaults

Dev overlay:
  Dev-specific configuration
6. Why we are doing this before CI/CD

Eventually GitHub Actions will produce an image such as:

everest-demo:1.0.7

The CI pipeline will need to update the appropriate environment's desired state.

For example:

Dev overlay
    ↓
image: registry/.../everest-demo:1.0.7

Then Argo CD handles deployment.

Later:

Dev validated
    ↓
Promote same image
    ↓
Staging
    ↓
Production

Kustomize overlays give us the structure to represent those environments without copying the entire application.

Our learning sequence

We'll do this in small steps:

Step A — Understand Base/Overlay

Concept — now

Step B — Refactor existing Everest manifests

Practical

Step C — Render Base
kubectl kustomize ...
Step D — Render Dev overlay
kubectl kustomize ...
Step E — Compare the two outputs

Understand exactly what Kustomize changes.

Step F — Point Argo CD to the new Dev overlay
Step G — Verify EKS remains healthy

Only after that will we introduce:

staging
production
promotion

=====================================================

Good. We have the exact current manifests, and they are simple enough to refactor cleanly.

One small terminal typo occurred here:

cat .../service.cat cat .../service.yaml

but the service.yaml content was displayed correctly, so no issue.

First: understand what we have now

Currently everything is environment-specific:

gitops/
└── environments/
    └── dev/
        └── everest-demo/
            ├── namespace.yaml
            ├── deployment.yaml
            ├── service.yaml
            └── kustomization.yaml

And the Deployment currently contains:

replicas: 3
image: nginx:1.27

Those are two values that are good candidates for environment-specific configuration.

For example, eventually we could have:

Base:
  image: nginx:1.27
  replicas: 2

Dev:
  replicas: 3

Staging:
  replicas: 3

Production:
  replicas: 5

The exact numbers are not important right now. The separation of common configuration from environment configuration is what we're learning.

Step 1 — Don't modify the working application yet

Because the current application is healthy and synchronized, let's first create the new structure alongside it.

Create:

mkdir -p gitops/workloads/everest-demo/base
mkdir -p gitops/workloads/everest-demo/overlays/dev

Verify:

find gitops/workloads -type d | sort

Expected:

gitops/workloads
gitops/workloads/everest-demo
gitops/workloads/everest-demo/base
gitops/workloads/everest-demo/overlays
gitops/workloads/everest-demo/overlays/dev
Step 2 — Move the common manifests into Base

We can copy the existing manifests first rather than moving them. This gives us a safe working copy while the current Argo CD application continues running.

Run:

cp gitops/environments/dev/everest-demo/deployment.yaml \
   gitops/workloads/everest-demo/base/deployment.yaml
cp gitops/environments/dev/everest-demo/service.yaml \
   gitops/workloads/everest-demo/base/service.yaml

For the namespace, there is an architectural point.

Your current namespace is:

name: everest-dev

That is environment-specific, so I don't want to put it into the Base.

For now, leave namespace.yaml out of the Base.

This gives us:

base/
├── deployment.yaml
└── service.yaml
Step 3 — Create the Base Kustomization

Create:

nano gitops/workloads/everest-demo/base/kustomization.yaml

Use:

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml

Now the Base means:

"These are the common Kubernetes resources that define Everest Demo."

Step 4 — Create the Dev overlay

Create:

nano gitops/workloads/everest-demo/overlays/dev/kustomization.yaml

Start with:

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: everest-dev

resources:
  - ../../base

replicas:
  - name: everest-demo
    count: 3

This is our first important Kustomize concept.

The overlay says:

Use the Base
   +
Deploy it into everest-dev
   +
Set Deployment replicas to 3

Notice that we did not copy the Deployment YAML.

Step 5 — What about the namespace?

Because the overlay uses:

namespace: everest-dev

Kustomize will apply that namespace to namespaced resources.

But the Namespace resource itself is cluster-scoped, so we should keep it separately.

Create:

nano gitops/workloads/everest-demo/overlays/dev/namespace.yaml

Use:

apiVersion: v1
kind: Namespace
metadata:
  name: everest-dev
  labels:
    project: project-everest
    environment: dev

Then update the Dev Kustomization:

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: everest-dev

resources:
  - ../../base
  - namespace.yaml

replicas:
  - name: everest-demo
    count: 3

Now the structure is:

gitops/
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
Step 6 — Understand the inheritance

The important part is:

Dev overlay
     │
     ├── ../../base
     │      ├── Deployment
     │      └── Service
     │
     ├── namespace: everest-dev
     │
     └── replicas: 3

Kustomize renders the final desired state.

We can prove this without touching EKS.

Run:

kubectl kustomize gitops/workloads/everest-demo/base

This should produce the Deployment and Service.

Then:

kubectl kustomize gitops/workloads/everest-demo/overlays/dev

This should produce:

Namespace everest-dev
Deployment everest-demo
Service everest-demo
Deployment replicas = 3
resources in namespace everest-dev

Step 7 — Compare Base vs Dev

This is the important learning exercise.

Run:

kubectl kustomize gitops/workloads/everest-demo/base | grep -E '^(kind:|  name:|  namespace:|  replicas:|        image:)'

Then:

kubectl kustomize gitops/workloads/everest-demo/overlays/dev | grep -E '^(kind:|  name:|  namespace:|  replicas:|        image:)'

You should see that the overlay produces the environment-specific namespace and replica configuration.

One important thing before we continue

Do not change the Argo CD Application yet.

It currently points to:

gitops/environments/dev/everest-demo

Our new structure is:

gitops/workloads/everest-demo/overlays/dev

We first want to prove that the new Kustomize structure renders correctly.

Only after that will we:

old path
   ↓
new Dev overlay
   ↓
Argo CD
   ↓
EKS

This gives us a safe migration rather than changing Git and Argo CD simultaneously.

Your next commands

Create the directories and files above, then run:

kubectl kustomize gitops/workloads/everest-demo/base

and:

kubectl kustomize gitops/workloads/everest-demo/overlays/dev

============================================================

Good. This output gives us an important Kustomize lesson — and it also reveals something we should correct before migrating Argo CD.

1. Base and Dev currently render almost identically

Your Base renders:

Service
  name: everest-demo
  namespace: everest-dev

Deployment
  name: everest-demo
  namespace: everest-dev
  replicas: 3
  image: nginx:1.27

The Dev overlay renders the same effective configuration.

That is because our current Base still contains:

metadata:
  namespace: everest-dev

and:

replicas: 3

So we haven't yet achieved a meaningful Base/Overlay separation.

This is actually useful

We have demonstrated the mechanics:

Overlay
   ↓
references Base
   ↓
Kustomize builds final manifests

But now we need to improve the design.

2. What should actually belong in Base?

The Base should represent the application independently of the environment.

For example:

Deployment:
  name: everest-demo
  image: nginx:1.27
  replicas: 2
  resources: ...
  probes: ...

But it should not say:

namespace: everest-dev

because everest-dev is an environment decision.

Likewise, replicas: 3 is currently our Dev configuration, so let's move that decision into the Dev overlay.

3. Refactor the Base

Open:

nano gitops/workloads/everest-demo/base/deployment.yaml

Change:

spec:
  replicas: 3

to:

spec:
  replicas: 2

And remove this from the Deployment metadata:

namespace: everest-dev

So the Deployment metadata becomes:

metadata:
  name: everest-demo
  labels:
    app: everest-demo
    project: project-everest

Do the same for the Service:

nano gitops/workloads/everest-demo/base/service.yaml

Remove:

namespace: everest-dev

The Service should become:

metadata:
  name: everest-demo
  labels:
    app: everest-demo
    project: project-Everest

4. Now the overlay becomes meaningful
Our Dev overlay already contains:

namespace: everest-dev

and:

replicas:
  - name: everest-demo
    count: 3

So now the architecture becomes:

BASE
 ├── Deployment
 │     replicas: 2
 │     image: nginx:1.27
 │     probes
 │     resources
 │
 └── Service
       type: ClusterIP
       port: 80

          ↓

DEV OVERLAY
 ├── namespace: everest-dev
 └── replicas: 3

That's the separation we wanted.

5. Render Base again

Run:

kubectl kustomize gitops/workloads/everest-demo/base

Now you should see:

kind: Deployment
metadata:
  name: everest-demo
...
spec:
  replicas: 2

and importantly, the Deployment should not contain:

namespace: everest-dev

Likewise for the Service.

6. Render Dev

Then:

kubectl kustomize gitops/workloads/everest-demo/overlays/dev

The Dev output should now contain:

metadata:
  name: everest-demo
  namespace: everest-dev

and:

spec:
  replicas: 3

while retaining:

image: nginx:1.27

from the Base.

This is the real Base/Overlay relationship:

                    BASE
                     │
        ┌────────────┼────────────┐
        │            │            │
      image       probes      resources
     nginx:1.27
        │
        │
        ▼
     DEV OVERLAY
        │
        ├── namespace = everest-dev
        └── replicas = 3

7. Why this matters for our future environments

Now imagine we add:

overlays/
├── dev/
├── staging/
└── production/

We could have:

Base:
  image: nginx:1.27
  replicas: 2

Dev:
  namespace: everest-dev
  replicas: 3

Staging:
  namespace: everest-staging
  replicas: 4

Production:
  namespace: everest-prod
  replicas: 6

The Deployment, Service, probes, resources, labels, etc. remain in one Base.

That's the core Kustomize value.

8. One important thing: don't touch EKS yet

We currently have:

EKS live:
3 replicas
namespace: everest-dev
image: nginx:1.27

Our new Dev overlay should render exactly that:

Kustomize Dev output:
3 replicas
namespace: everest-dev
image: nginx:1.27

So we can migrate Argo CD without changing the actual application.

This is an important infrastructure engineering practice:

Refactor the desired-state structure first; preserve the effective desired state during the migration.

Your next step

Make those two Base changes:

base/deployment.yaml
remove namespace: everest-dev
change replicas 3 → 2
base/service.yaml
remove namespace: everest-dev

Then run:

kubectl kustomize gitops/workloads/everest-demo/base

and:

kubectl kustomize gitops/workloads/everest-demo/overlays/dev

================================================

Step 1 — Check the current Application definition

Run:

cat gitops/applications/everest-demo.yaml

We specifically want to see:

source:
  repoURL: https://github.com/Xprakasho/DevOps_Automation.git
  targetRevision: main
  path: gitops/environments/dev/everest-demo

The only thing we're going to change is:

path: gitops/workloads/everest-demo/overlays/dev

Don't change anything else yet.

Then we'll apply the updated Application and watch Argo CD deploy the new Kustomize overlay.

This will be our first complete flow of:

Git repository
      ↓
Kustomize Base
      ↓
Dev Overlay
      ↓
Argo CD Application
      ↓
Argo CD renders overlay
      ↓
EKS
      ↓
everest-dev
      ↓
3 nginx replicas

That is the important practical proof of Base + Overlay + GitOps.

==============================================

Good — this output tells us exactly what is happening. Argo CD itself is connected correctly; the problem is Git, not EKS or Argo CD.

The key error is:

Manifest generation error:
gitops/workloads/everest-demo/overlays/dev: app path does not exist
Why?

Your local repository has:

gitops/workloads/everest-demo/overlays/dev

but Argo CD is reading:

https://github.com/Xprakasho/DevOps_Automation.git
        ↓
       main

So the new Kustomize directories must be committed and pushed to main before Argo CD can see them.

This is actually a useful GitOps lesson:

Your laptop
    │
    │ local files
    ▼
Git commit
    │
    ▼
GitHub main          ← Argo CD reads HERE
    │
    ▼
Argo CD
    │
    ▼
EKS
Step 1 — Don't change anything else

Your Argo CD configuration is now correct:

Path:
gitops/workloads/everest-demo/overlays/dev

Leave it that way.

First check:

git status

Then:

git status --short

I expect you will see the new Kustomize files as untracked or modified.

Also verify:

git ls-files gitops/workloads/everest-demo

If that returns nothing, it confirms the new structure isn't committed to Git yet.

Important

Do not stage everything with:

git add .

because you previously had unrelated repository changes such as scripts/bash/application.json, and we don't want to accidentally include them.

Instead, once we confirm the status, we'll stage only:

gitops/workloads/everest-demo/
gitops/applications/everest-demo.yaml

Then commit and push to main.

After the push, Argo CD should be able to generate:

Namespace
Deployment
Service

and your automated sync should create the 3-replica everest-demo workload in EKS.

Run git status --short first and show me the output.

Perfect — this confirms the diagnosis.

Your git status shows exactly why Argo CD cannot find the new path:

?? gitops/workloads/

The entire new Kustomize structure is untracked, so it does not exist on GitHub main yet.

We also have two unrelated items that we should not commit right now:

M scripts/bash/application.json
M gitops/environments/dev/everest-demo/kustomization.yaml

The second one is related to the old structure, but we don't need it for the new structure yet.

What we should commit now

Only these:

gitops/workloads/
gitops/applications/everest-demo.yaml

First stage only those:

git add gitops/workloads/
git add gitops/applications/everest-demo.yaml

Then verify:

git status

We want to see something like:

Changes to be committed:
  modified:   gitops/applications/everest-demo.yaml
  new file:   gitops/workloads/everest-demo/...

Changes not staged for commit:
  modified:   gitops/environments/dev/everest-demo/kustomization.yaml
  modified:   scripts/bash/application.json

That is good. The two unrelated/old changes remain unstaged.

Before committing, let's inspect exactly what we're about to send:

git diff --cached --stat

and:

git diff --cached

The staged diff should contain:

new base/deployment.yaml
new base/service.yaml
new base/kustomization.yaml
new overlays/dev/kustomization.yaml
new overlays/dev/namespace.yaml
modified gitops/applications/everest-demo.yaml

If that looks correct, commit:

git commit -m "Refactor Everest demo to Kustomize overlays"

Then:

git push origin main
What happens after the push

This is where the GitOps loop becomes real again:

Local Git
   ↓
git push
   ↓
GitHub main
   ↓
Argo CD detects new path
   ↓
Kustomize renders overlays/dev
   ↓
Argo CD syncs
   ↓
EKS
   ↓
everest-dev
   ├── Deployment: 3 replicas
   └── Service

And do not manually kubectl apply the workload. Let Argo CD do the deployment. That's the point of this exercise.

Start with:

git add gitops/workloads/
git add gitops/applications/everest-demo.yaml
git status

Show me that staged status before we commit.

Good — this output is actually very useful.

Your push succeeded:

To https://github.com/Xprakasho/DevOps_Automation.git
afac2d6..6de20bb  main -> main

And now:

git status

shows only these two unrelated local modifications:

modified: gitops/environments/dev/everest-demo/kustomization.yaml
modified: scripts/bash/application.json

There are no untracked gitops/workloads/ files anymore, which means the new Kustomize structure is already committed and pushed in the commit you just pushed.

So do not commit anything else right now.

Now let's let Argo CD see the new commit

First, verify Git contains the new path:

git ls-tree -r --name-only origin/main gitops/workloads/everest-demo

We should see something like:

gitops/workloads/everest-demo/base/deployment.yaml
gitops/workloads/everest-demo/base/service.yaml
gitops/workloads/everest-demo/base/kustomization.yaml
gitops/workloads/everest-demo/overlays/dev/namespace.yaml
gitops/workloads/everest-demo/overlays/dev/kustomization.yaml

Then refresh Argo CD:

argocd app get everest-demo --refresh

Then:

argocd app get everest-demo

We're looking for the previous error:

app path does not exist

to disappear.

Then check the actual EKS resources
kubectl get all -n everest-dev

Because automated sync is enabled, Argo CD should now create the workload automatically.

Expected:

deployment.apps/everest-demo
service/everest-demo

and:

kubectl get deployment everest-demo -n everest-dev

should eventually show:

3/3
One important Git point

Notice what happened:

Local repository
      ↓
git push
      ↓
GitHub main
      ↓
Argo CD

Your local Kustomize files existed earlier, but Argo CD couldn't see them because Argo CD does not read your WSL working directory. It reads the configured Git repository/revision.

That's an important real-world GitOps principle.

===================================================

Excellent. This is exactly the result we wanted. The Kustomize Base/Overlay refactor is now working end-to-end through Argo CD.

What we have proven

Argo CD is now using:

gitops/workloads/everest-demo/overlays/dev

and reports:

Sync Status:   Synced to main (6de20bb)
Health Status: Healthy

The important part is that Argo CD successfully rendered the Dev overlay and deployed it.

Live EKS state:

everest-dev
├── Deployment: everest-demo
│   ├── Desired:   3
│   ├── Current:   3
│   └── Available: 3
│
├── ReplicaSet: everest-demo-97cdf7fbd
│   └── 3/3
│
├── Pods: 3
│   ├── Running
│   ├── Running
│   └── Running
│
└── Service: everest-demo
    └── ClusterIP

So our complete flow is now:

GitHub
  │
  │ gitops/workloads/everest-demo/overlays/dev
  ▼
Argo CD Application
  │
  │ Kustomize
  ▼
Dev Overlay
  │
  ├── Base
  │    ├── Deployment
  │    └── Service
  │
  └── Dev
       ├── namespace: everest-dev
       └── replicas: 3
  │
  ▼
EKS
  │
  └── 3 healthy Pods
One subtle but important observation

Argo CD shows:

Deployment ... Synced ... Healthy ... unchanged

That is good.

Even though we changed the Git repository structure, Kubernetes didn't need a meaningful application change because the rendered Dev configuration is what we intended.

This demonstrates an important GitOps principle:

Repository structure can evolve without changing the application's effective desired state.

Kustomize Base + Overlay — checkpoint

I would mark this topic DONE.

You now understand it practically:

Base
Common application configuration

Contains things such as:

Deployment
Service
image
probes
resources
common labels
Overlay
Environment-specific configuration

Dev currently adds:

namespace = everest-dev
replicas = 3
Namespace resource

And later:

overlays/
├── dev/
├── staging/
└── production/

could produce different environments from the same Base.

One thing I want to clean up before moving on

We still have these two unstaged local changes:

gitops/environments/dev/everest-demo/kustomization.yaml
scripts/bash/application.json

Do not delete or commit them blindly.

The old:

gitops/environments/dev/everest-demo/

structure is now superseded by:

gitops/workloads/everest-demo/

But we should deliberately decide what to do with the old directory rather than leave two competing GitOps structures indefinitely.

So our next small step should be:

clean up the old gitops/environments/dev/everest-demo structure, while preserving the unrelated scripts/bash/application.json change.

Then we can move to the next essential GitOps topic:

Dev → Staging → Production promotion.

==============================================

Yes. Based on what you checked, the old structure is no longer referenced, and Argo CD is now using the new path:

gitops/workloads/everest-demo/overlays/dev

So we can clean up the old duplicate structure.

1. Remove the old Everest Demo environment directory

Use:

git rm -r gitops/environments/dev/everest-demo

This will remove and stage these four old files:

gitops/environments/dev/everest-demo/
├── kustomization.yaml
├── namespace.yaml
├── deployment.yaml
└── service.yaml
2. Check the staged changes

Run:

git status

You should see the four old files as deleted, plus your already-committed new structure should not appear as untracked.

You should also still see:

modified: scripts/bash/application.json

as an unstaged change.

Do not stage scripts/bash/application.json.

3. Review exactly what will be deleted

Run:

git diff --cached --stat

and:

git diff --cached

We want the staged changes to be only the removal of the old Everest Demo structure.

Then commit:

git commit -m "Remove legacy Everest demo GitOps structure"

and push:

git push origin main
Final repository structure

After this cleanup, the authoritative structure becomes:

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

That's much cleaner:

Application definition → points to Dev overlay → Dev overlay uses Base.

And your unrelated:

scripts/bash/application.json

stays untouched.

After the push, Argo CD should remain Synced/Healthy, because we're deleting an old Git path that it no longer uses.

=====================================================
