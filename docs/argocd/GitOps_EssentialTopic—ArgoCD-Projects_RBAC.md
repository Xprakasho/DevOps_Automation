GitOps Essential Topic — Argo CD Projects + RBAC

Today we'll learn this from the security/architecture perspective first, then do a small practical lab with our Everest environment.

Our question is:

Who is allowed to deploy what, from where, and to which Kubernetes resources?

1. First understand the two controls

Argo CD has two related but different concepts:

                 Argo CD
                    │
          ┌─────────┴─────────┐
          │                   │
       PROJECT               RBAC
          │                   │
   What can be deployed?   Who can do it?
Argo CD Project

A Project controls the boundaries of an Application.

It can restrict:

which Git repositories an Application may use
which destination clusters it may deploy to
which namespaces it may deploy into
which Kubernetes resource kinds are allowed/denied

Think:

Project = deployment boundary

Argo CD RBAC

RBAC controls users/groups/service accounts and their permissions.

For example:

Developer
   ↓
can view Application
can view logs
can sync Dev

Release Engineer
   ↓
can sync Dev/Staging

Platform Admin
   ↓
can manage Projects
can manage Applications

Think:

RBAC = identity + permission

2. Why this matters for GitOps security

Without proper boundaries, imagine someone creates:

kind: Application

pointing to:

Git repository: random-repo
Cluster: production
Namespace: kube-system

If Argo CD accepts everything, the GitOps control plane becomes extremely powerful.

That's why we want multiple layers:

                    Git
                     │
                     ▼
              Argo CD Application
                     │
              ┌──────┴──────┐
              │             │
           Project          RBAC
              │             │
       What is allowed?   Who can act?
              │             │
              └──────┬──────┘
                     ▼
                Kubernetes

This is an important enterprise security model.

3. Our current Everest situation

Our Applications currently use:

project: default

For example:

spec:
  project: default

So both:

everest-demo
everest-demo-staging

belong to the built-in default Project.

That was appropriate while we were learning the mechanics.

Now we're going to understand why an enterprise setup would usually create a dedicated Project.

Conceptually:

default
   │
   ├── everything broadly permitted
   │
   └── learning/demo

everest
   │
   ├── Everest Git repository
   ├── Everest namespaces
   └── Everest Applications

We won't blindly modify the existing Applications yet. First we'll inspect the current configuration.

4. First practical inspection

Run:

kubectl get appproject -n argocd

You should see something similar to:

NAME      AGE
default   ...

Then:

kubectl get appproject default -n argocd -o yaml

This is important because I want you to see what an Argo CD Project actually contains rather than memorizing fields.

Look particularly for:

spec:
  sourceRepos:
  destinations:
  clusterResourceWhitelist:
  namespaceResourceWhitelist:

Don't worry if some are absent.

5. The four important Project controls

Let's understand these before touching anything.

sourceRepos

Controls:

Which Git repositories can Applications in this Project use?

Example:

sourceRepos:
  - https://github.com/company/platform-gitops.git

Conceptually:

Application
    ↓
Project
    ↓
Is this Git repository allowed?
destinations

Controls:

Where can Applications in this Project deploy?

Example:

destinations:
  - server: https://kubernetes.default.svc
    namespace: everest-dev

This prevents an Application in that Project from simply choosing any cluster/namespace.

namespaceResourceWhitelist

Controls which namespaced Kubernetes resources Applications can create.

For example:

Deployment
Service
ConfigMap
Secret
clusterResourceWhitelist

Controls which cluster-scoped resources Applications can create.

Examples:

Namespace
ClusterRole
ClusterRoleBinding
CustomResourceDefinition

This distinction is important:

Namespaced resources
        │
        └── Deployment
        └── Service
        └── ConfigMap

Cluster-scoped resources
        │
        └── Namespace
        └── ClusterRole
        └── CRD
6. Very important: Project ≠ Kubernetes RBAC

This is a common confusion.

Argo CD Project:

"Can this Application deploy this resource
to this destination from this repository?"

Kubernetes RBAC:

"Can this Kubernetes identity perform this API action?"

Argo CD RBAC:

"Can this Argo CD user/group perform this Argo CD action?"

So there are potentially three authorization layers:

User
 │
 ▼
Argo CD RBAC
 │
 ▼
Argo CD Project
 │
 ▼
Kubernetes RBAC / API
 │
 ▼
Cluster

They solve different problems.

7. Our practical lab today

We'll build a dedicated Project:

everest-project

and eventually configure it to allow:

Git:
https://github.com/Xprakasho/DevOps_Automation.git

Cluster:
in-cluster

Namespaces:
everest-dev
everest-staging

Conceptually:

everest-project
│
├── allowed Git
│     └── DevOps_Automation
│
├── allowed cluster
│     └── in-cluster
│
└── allowed namespaces
      ├── everest-dev
      └── everest-staging

Then we'll move the Everest Applications from:

project: default

to:

project: everest-project

But we won't do that yet.

First, inspect the existing Project.

Run these two commands:
kubectl get appproject -n argocd

and:

kubectl get appproject default -n argocd -o yaml

=================================================================

Excellent. This output gives us exactly what we need.

First, your Everest application is healthy:

Project:       default
Sync Status:   Synced
Health Status: Healthy
Namespace:     everest-dev

And the Kubernetes resources are present.

The temporary:

Unable to connect to the server: net/http: TLS handshake timeout

is a cluster/API connectivity hiccup, not an Argo CD Project problem, because argocd app get successfully queried the application immediately before it.

1. Now look at the default Project

Your actual configuration is:

spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'

  destinations:
  - namespace: '*'
    server: '*'

  sourceRepos:
  - '*'

This is intentionally very broad.

Let's translate it.

sourceRepos
sourceRepos:
  - '*'

Means:

Any Git repository
      ↓
allowed by this Project

So the Project isn't restricting the source repository.

destinations
destinations:
  - namespace: '*'
    server: '*'

Means:

Any cluster
   +
Any namespace

is allowed as a destination.

Conceptually:

default Project
       │
       ├── Git repo: ANY
       │
       ├── Cluster:  ANY
       │
       └── Namespace: ANY
clusterResourceWhitelist
clusterResourceWhitelist:
  - group: '*'
    kind: '*'

This allows all cluster-scoped resource kinds.

For example, depending on the Application's manifests:

Namespace
ClusterRole
ClusterRoleBinding
CRD
...

There is no restriction here.

2. This is why we need a dedicated Project

Our Everest Application currently says:

spec:
  project: default

Therefore its deployment boundary is currently the broad default Project.

We want to move toward:

                    Argo CD
                       │
                everest-project
                       │
          ┌────────────┼────────────┐
          │            │            │
       Git repo      Cluster     Namespace
          │            │            │
          ▼            ▼            ▼
 DevOps_Automation   EKS      everest-dev
                                everest-staging

This is least-privilege thinking.

3. But notice something important in our current Application

Our Dev Kustomize overlay contains:

resources:
  - ../../base
  - namespace.yaml

So the Application creates:

Namespace: everest-dev

The namespace itself is cluster-scoped.

Therefore, when we create our restricted Project, we need to decide whether this Project is allowed to create Namespace.

This is a good real-world security discussion.

We could allow:

clusterResourceWhitelist:
  - group: ""
    kind: Namespace

while restricting everything else.

Then namespaced resources can be separately controlled.

4. Our target Project

For this learning lab, I suggest we make the Project deliberately narrow:

apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: everest-project
  namespace: argocd

spec:
  description: Project Everest GitOps boundary

  sourceRepos:
    - https://github.com/Xprakasho/DevOps_Automation.git

  destinations:
    - server: https://kubernetes.default.svc
      namespace: everest-dev

    - server: https://kubernetes.default.svc
      namespace: everest-staging

  clusterResourceWhitelist:
    - group: ""
      kind: Namespace

  namespaceResourceWhitelist:
    - group: ""
      kind: Service

    - group: apps
      kind: Deployment

Notice the difference from default.

Default
Git repositories: *
Clusters:         *
Namespaces:       *
Cluster resources: *
Everest Project
Git repository:
  DevOps_Automation only

Cluster:
  in-cluster only

Namespaces:
  everest-dev
  everest-staging

Cluster resources:
  Namespace only

Namespaced resources:
  Service
  Deployment

This is much more controlled.

5. One important design decision

Our current Everest Application contains only:

Namespace
Service
Deployment

So the restricted Project above is enough for our current lab.

Later, if we add:

ConfigMap
Secret
Ingress
ServiceAccount
Role
RoleBinding

we would need to explicitly decide which ones the Project should permit.

That's exactly the security mindset I want you to develop:

Don't give Argo CD unrestricted permissions simply because the application happens to need more resources today. Define the allowed resource boundary deliberately.

6. Before we create it

I want you to see one more distinction.

The Project controls:

WHAT an Application may deploy

RBAC controls:

WHO may operate Argo CD

So after we create:

everest-project

we will test:

Application
   ↓
Project restriction

Then we'll move to:

User / Group
   ↓
Argo CD RBAC
   ↓
Application permissions

That gives us the complete model:

                 User
                   │
                   ▼
              Argo CD RBAC
                   │
             "Can you act?"
                   │
                   ▼
             Argo CD Project
                   │
       "What are you allowed to
          deploy and where?"
                   │
                   ▼
             Application
                   │
                   ▼
              Kubernetes
Next step

Let's create the Project as a GitOps manifest, not by creating it only imperatively.

Create:

gitops/projects/everest-project.yaml

This is important because we are also practicing the principle:

Argo CD configuration itself should be represented in Git.

==============================================================

Yes. Let's create it cleanly and Git-managed from the beginning.

1. Create the directory

From the repository root:

mkdir -p gitops/projects

Create the Project manifest:

nano gitops/projects/everest-project.yaml

Put this in it:

apiVersion: argoproj.io/v1alpha1
kind: AppProject

metadata:
  name: everest-project
  namespace: argocd

spec:
  description: Project Everest GitOps boundary

  sourceRepos:
    - https://github.com/Xprakasho/DevOps_Automation.git

  destinations:
    - server: https://kubernetes.default.svc
      namespace: everest-dev

    - server: https://kubernetes.default.svc
      namespace: everest-staging

  clusterResourceWhitelist:
    - group: ""
      kind: Namespace

  namespaceResourceWhitelist:
    - group: ""
      kind: Service

    - group: apps
      kind: Deployment

Save and exit.

2. Validate the YAML locally

First:

kubectl apply --dry-run=client -f gitops/projects/everest-project.yaml

Expected:

appproject.argoproj.io/everest-project created (dry run)

Then inspect the staged manifest:

cat gitops/projects/everest-project.yaml

And:

git diff --check
3. Important: don't change the Applications yet

At this point we have:

default Project
    │
    └── everest-demo

and we're creating:

everest-project
    │
    ├── everest-dev
    └── everest-staging

But everest-demo still says:

project: default

Do not change that yet.

First we create and verify the Project itself.

4. Apply it to Argo CD

Once the local validation is clean:

kubectl apply -f gitops/projects/everest-project.yaml

Then verify:

kubectl get appproject -n argocd

You should see:

NAME
default
everest-project

Then inspect exactly what Argo CD accepted:

kubectl get appproject everest-project -n argocd -o yaml
5. One thing we will test

After the Project exists, we'll change:

project: default

to:

project: everest-project

for everest-demo.

Then we'll verify that the existing Dev application remains:

Synced
Healthy

That is an important practical test:

GitOps Application
       ↓
everest-project
       ↓
allowed repo ✓
allowed cluster ✓
allowed namespace ✓
allowed Namespace ✓
allowed Deployment ✓
allowed Service ✓
       ↓
EKS

=====================================================

Perfect. The Project was created correctly, and the live Argo CD configuration matches the Git manifest.

What we have now
Argo CD
│
├── default
│    └── broad/unrestricted learning Project
│
└── everest-project
     ├── Git:
     │    DevOps_Automation.git
     │
     ├── Cluster:
     │    https://kubernetes.default.svc
     │
     ├── Namespaces:
     │    everest-dev
     │    everest-staging
     │
     ├── Cluster resource:
     │    Namespace
     │
     └── Namespaced resources:
          Service
          Deployment

And this is good:

git diff --check

returned nothing, so there are no whitespace errors in the file.

Next: move everest-demo into everest-project

Currently:

project: default

We want:

project: everest-project
1. Edit the Git-managed Application

Open:

nano gitops/applications/everest-demo.yaml

Change only:

spec:
  project: default

to:

spec:
  project: everest-project

Don't change anything else.

Then verify:

git diff -- gitops/applications/everest-demo.yaml

You should see essentially:

-  project: default
+  project: everest-project
2. Validate and commit

Run:

git diff --check

Then:

git add gitops/projects/everest-project.yaml \
        gitops/applications/everest-demo.yaml

Before committing:

git diff --cached --check
git diff --cached --stat

We want only these two GitOps changes staged.

Then:

git commit -m "Add Everest Argo CD project boundary"
git push origin main
3. Apply the Application change

Because the Application itself is now Git-managed, we want Argo CD to eventually see:

everest-demo
     ↓
everest-project

For the lab, apply the Git-managed Application explicitly:

kubectl apply -f gitops/applications/everest-demo.yaml

Then:

argocd app get everest-demo

The important result should be:

Project:            everest-project
Sync Status:        Synced
Health Status:      Healthy

And the existing Deployment should remain running. We are changing the Argo CD authorization boundary, not changing the workload itself.

After that, we'll inspect the Project's behavior and then move into Argo CD RBAC — users, groups, policies, and what sync, get, create, update, and delete actually mean.

=======================================================

Perfect. The Project was created correctly, and the live Argo CD configuration matches the Git manifest.

What we have now
Argo CD
│
├── default
│    └── broad/unrestricted learning Project
│
└── everest-project
     ├── Git:
     │    DevOps_Automation.git
     │
     ├── Cluster:
     │    https://kubernetes.default.svc
     │
     ├── Namespaces:
     │    everest-dev
     │    everest-staging
     │
     ├── Cluster resource:
     │    Namespace
     │
     └── Namespaced resources:
          Service
          Deployment

And this is good:

git diff --check

returned nothing, so there are no whitespace errors in the file.

Next: move everest-demo into everest-project

Currently:

project: default

We want:

project: everest-project
1. Edit the Git-managed Application

Open:

nano gitops/applications/everest-demo.yaml

Change only:

spec:
  project: default

to:

spec:
  project: everest-project

Don't change anything else.

Then verify:

git diff -- gitops/applications/everest-demo.yaml

You should see essentially:

-  project: default
+  project: everest-project
2. Validate and commit

Run:

git diff --check

Then:

git add gitops/projects/everest-project.yaml \
        gitops/applications/everest-demo.yaml

Before committing:

git diff --cached --check
git diff --cached --stat

We want only these two GitOps changes staged.

Then:

git commit -m "Add Everest Argo CD project boundary"
git push origin main
3. Apply the Application change

Because the Application itself is now Git-managed, we want Argo CD to eventually see:

everest-demo
     ↓
everest-project

For the lab, apply the Git-managed Application explicitly:

kubectl apply -f gitops/applications/everest-demo.yaml

Then:

argocd app get everest-demo

The important result should be:

Project:            everest-project
Sync Status:        Synced
Health Status:      Healthy

And the existing Deployment should remain running. We are changing the Argo CD authorization boundary, not changing the workload itself.

=================================================

Perfect. The transition worked exactly as intended.

Your screenshot confirms:

Project:       everest-project
Sync Status:   Synced
Health Status: Healthy

And the important part is that the workload itself was unaffected:

Namespace   everest-dev   Synced
Service     everest-demo  Synced / Healthy
Deployment  everest-demo  Synced / Healthy

So we've now practically demonstrated:

Before
everest-demo
    ↓
default Project

changed to:

After
everest-demo
    ↓
everest-project
    ↓
allowed Git repository
    ↓
allowed EKS cluster
    ↓
allowed everest-dev namespace
    ↓
allowed Namespace / Service / Deployment
One important thing to notice

The Project is not deploying anything itself.

It is an authorization boundary around the Application.

That's the key concept.

Next: test the boundary

Before moving to RBAC, let's deliberately test whether our Project restrictions actually work.

Our Project currently allows:

sourceRepos:
  - https://github.com/Xprakasho/DevOps_Automation.git

and:

destinations:
  - server: https://kubernetes.default.svc
    namespace: everest-dev

  - server: https://kubernetes.default.svc
    namespace: everest-staging

So everest-demo is allowed.

But an Application attempting to deploy into something like:

default

should not be permitted by everest-project.

This is a useful security lab because we're testing the policy rather than simply looking at YAML.

We don't need to create a permanent bad Application. We can use Argo CD's validation behavior.

First inspect the Project

Run:

kubectl describe appproject everest-project -n argocd

Then we'll test the boundary with a temporary Application configuration.

Don't change everest-demo or the Project yet. Send me the describe output first.

After that, we'll finish the Project portion and move into Argo CD RBAC, where we'll answer the next question:

Project:
    "What can be deployed?"

RBAC:
    "Who is allowed to perform the action?"

That distinction is the most important thing to carry forward from today's topic.

========================================================

Exactly. This confirms the Project boundary is configured as intended.

What everest-project currently allows
Source repository
└── https://github.com/Xprakasho/DevOps_Automation.git

Destinations
├── https://kubernetes.default.svc / everest-dev
└── https://kubernetes.default.svc / everest-staging

Cluster-scoped resources
└── Namespace

Namespaced resources
├── Service
└── Deployment

So our Application:

everest-demo
    ↓
everest-project
    ↓
DevOps_Automation.git
    ↓
EKS / everest-dev

fits entirely inside the Project's allowed boundary.

I would stop the Project exercise here

We have already demonstrated the important part:

Created a dedicated AppProject.
Restricted the Git repository.
Restricted cluster destination.
Restricted namespaces.
Restricted resource kinds.
Moved everest-demo from default → everest-project.
Verified the Application remains Synced + Healthy.

The next useful concept is RBAC, not another artificial failure test.

Now the important distinction

Keep this model:

                Argo CD
                   │
        ┌──────────┴──────────┐
        │                     │
     Project                 RBAC
        │                     │
 "WHAT/WHERE?"            "WHO/CAN?"
        │                     │
        └──────────┬──────────┘
                   ▼
              Application
                   │
                   ▼
               Kubernetes
Project

Answers:

Can this Application use this repository and deploy these resources to this destination?

RBAC

Answers:

Can this user/group perform this Argo CD operation?

For example:

Developer
   │
   ├── get Application       ✓
   ├── view status           ✓
   ├── sync Dev              ✓
   └── delete Application    ✗

Platform Admin
   │
   ├── get                   ✓
   ├── sync                  ✓
   ├── create                ✓
   ├── update                ✓
   └── delete                ✓

Those are illustrative permission examples, not a recommendation for your eventual organization.

One thing we'll do before RBAC

We'll inspect the current Argo CD RBAC configuration:

kubectl -n argocd get configmap argocd-rbac-cm -o yaml

This will show us what Argo CD currently uses for authorization.

Then we'll understand:

policy.csv
policy.default
roles
groups
applications

and how an Argo CD policy such as:

p, role:developer, applications, get, everest-project/*, allow

is interpreted.

Run only this for now:

kubectl -n argocd get configmap argocd-rbac-cm -o yaml

=======================================================

Yes — this is useful. The important thing in your output is that argocd-rbac-cm currently has no data: section.

So right now, you effectively have:

kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd

but no custom:

data:
  policy.csv: ...
  policy.default: ...

That means we currently have no custom RBAC policy configured in this ConfigMap.

This is actually a good clean starting point for learning RBAC.

1. Let's understand the RBAC pieces first

Argo CD RBAC mainly revolves around two concepts:

policy.default

What permissions should an authenticated user have by default?

For example, conceptually:

policy.default: role:readonly

would make the default role read-only.

policy.csv

This defines explicit permissions.

A policy looks like:

p, role:developer, applications, get, everest-project/*, allow

Break it apart:

p
│
├── role:developer
│
├── applications
│
├── get
│
├── everest-project/*
│
└── allow

Meaning:

role:developer is allowed to get Applications belonging to everest-project.

2. The important Argo CD RBAC resources

For our learning, we only need these initially:

applications
repositories
projects
clusters
logs
exec

And common actions:

get
create
update
delete
sync
override
action/*

We don't need to memorize every possible permission.

For Project Everest, the important ones initially are:

applications
    get
    sync
    create
    update
    delete
3. Roles

Rather than giving every user permissions individually, we normally create a role:

role:developer

Then assign users/groups to that role.

Conceptually:

User
  │
  ▼
Group
  │
  ▼
role:developer
  │
  ├── applications:get
  ├── applications:sync
  └── ...

This is much easier to manage than:

User A → permissions
User B → permissions
User C → permissions
4. One important distinction

Our AppProject is:

everest-project

Our RBAC role could be:

role:everest-developer

They are different things.

AppProject
    │
    └── Defines deployment boundaries

RBAC Role
    │
    └── Defines user permissions

So:

role:everest-developer
       │
       │ can sync
       ▼
Application: everest-demo
       │
       │ belongs to
       ▼
everest-project
       │
       │ allows
       ▼
everest-dev

That is the complete authorization chain.

5. Before we create RBAC

Let's confirm the ConfigMap's actual data field directly rather than relying only on the screenshot.

Run:

kubectl -n argocd get configmap argocd-rbac-cm \
  -o jsonpath='{.data}{"\n"}'

I expect:

<nil>

or an empty result.

Then run:

kubectl -n argocd get configmap argocd-rbac-cm \
  -o jsonpath='{.data.policy\.default}{"\n"}'

This will tell us whether a default policy is explicitly configured.

===========================================================

Exactly. Both commands returned no value, which confirms:

argocd-rbac-cm
└── data: not configured
    ├── policy.csv       absent
    └── policy.default   absent

So we're starting RBAC from a clean state.

One subtle point: absence of a custom policy.default does not mean "no access at all." Argo CD has built-in/default RBAC behavior. We're simply confirming that we haven't configured our own policy in argocd-rbac-cm.

Let's create our first RBAC role

We'll keep the first role deliberately small.

Goal:

role:everest-viewer
        │
        └── can view Everest Applications

We want this permission:

p, role:everest-viewer, applications, get, everest-project/*, allow

Read it as:

p
│
role:everest-viewer
│
applications
│
get
│
everest-project/*
│
allow

Meaning:

The everest-viewer role can read Applications in the everest-project Argo CD Project.

It cannot sync, delete, or modify them through this rule.

1. Create the RBAC manifest

Since we're practicing GitOps, let's keep this configuration in Git too.

Create:

mkdir -p gitops/argocd
nano gitops/argocd/rbac-cm.yaml

Put:

apiVersion: v1
kind: ConfigMap

metadata:
  name: argocd-rbac-cm
  namespace: argocd

data:
  policy.csv: |
    p, role:everest-viewer, applications, get, everest-project/*, allow

Notice what we are not doing yet:

no sync
no delete
no update
no create
no admin

We're learning least privilege one step at a time.

2. Validate it

Run:

kubectl apply --dry-run=client -f gitops/argocd/rbac-cm.yaml

Then:

git diff --check

And inspect:

cat gitops/argocd/rbac-cm.yaml

Don't apply it to Argo CD yet.

============================================================

Perfect. The manifest is correct for the first RBAC rule, and the dry-run succeeded.

The warning is expected because this ConfigMap already existed and was originally created by the Argo CD installation rather than by kubectl apply. Since this was only a --dry-run, nothing was changed.

Our rule is:

p, role:everest-viewer, applications, get, everest-project/*, allow

Meaning:

Role:       everest-viewer
Resource:   Argo CD applications
Action:     get
Scope:      Applications in everest-project
Effect:     allow

So conceptually:

everest-viewer
      │
      └── get
           │
           ▼
    everest-project/*
           │
           ├── everest-demo
           └── everest-demo-staging

But there is a critical missing piece.

A role doesn't identify a user

We have created:

role:everest-viewer

but nobody has been assigned to it yet.

Argo CD needs a mapping such as:

group: developers
       ↓
role:everest-viewer

That is represented with a g policy:

g, developers, role:everest-viewer

So the two policy types are:

p = permission
p, role:everest-viewer, applications, get, everest-project/*, allow

What can the role do?

g = grouping/mapping
g, developers, role:everest-viewer

Which group receives that role?

Together:

developers
    │
    ▼
everest-viewer
    │
    ▼
applications: get
    │
    ▼
everest-project/*
But there's one complication in our lab

We currently authenticate to Argo CD with:

admin

and we're using the local Argo CD authentication setup. We don't currently have an external identity provider/group such as:

developers
platform-engineers
release-engineers

So we should not pretend that developers is a real group in our cluster.

Instead, let's first understand the policy syntax and then we'll use the appropriate local identity mechanism for the lab.

One more important security point

We should not apply this ConfigMap blindly yet.

argocd-rbac-cm is a live Argo CD control-plane configuration. A mistake here can affect access to Argo CD.

For learning, we'll:

Create manifest
      ↓
Understand policy
      ↓
Apply carefully
      ↓
Verify
      ↓
Test permission

rather than treating RBAC YAML as just another workload manifest.

Your current checkpoint
AppProject                  ✅
  └── deployment boundary

RBAC ConfigMap              ✅ manifest created
  └── permission rule defined

User/group → role            ⏳
  └── next concept

Permission testing           ⏳

Next, we'll learn local Argo CD users vs external groups, then configure a small role safely.

===================================================================

Yes. This is an important distinction, and we should keep local users, external SSO users/groups, and project roles separate in our mental model.

According to the current Argo CD documentation, the built-in admin account is the initial full-access account; Argo CD recommends using it for initial configuration and then moving to local users or SSO. Local users are intended mainly for small teams or automation; they do not provide group functionality, so SSO is preferred when you need groups.

1. Three different things

Think of it as:

                    Argo CD Authentication
                             │
                ┌────────────┴────────────┐
                │                         │
          Local Accounts               SSO
                │                         │
          alice / ci-bot          Corporate identity
                │                         │
                │                  users + groups
                │                         │
                └────────────┬────────────┘
                             ▼
                       Argo CD RBAC
                             │
                             ▼
                       Project / Role
                             │
                             ▼
                        Application

There are three separate concepts:

A. Local user

Created in:

argocd-cm

For example:

data:
  accounts.alice: login

This creates an Argo CD local account called alice. Local accounts can have login and/or apiKey capabilities.

B. External identity / group

With SSO, Argo CD receives identity and group information from an identity provider.

For example:

Corporate IdP
     │
     ├── om
     ├── alice
     │
     └── groups
           ├── platform-engineers
           └── developers

Argo CD can then map an IdP group to an Argo CD role through RBAC. The group value used in the policy needs to match the group claim supplied by the identity provider.

C. Argo CD role

A role defines what the identity can do.

For example:

role:everest-viewer

with:

applications → get

A user or group can then be associated with that role.

2. Local users vs SSO groups

This is the key comparison.

	Local user	SSO
Identity managed by	Argo CD	External IdP
Example	alice	alice@company.com
Groups	❌ Not a native feature	✅
Central identity management	❌	✅
MFA	Usually handled outside/local limitations	IdP
Good for	Small teams / automation	Enterprise
Our learning lab	Useful	Architecture we should understand

Argo CD explicitly notes that local users don't provide advanced features such as groups and recommends SSO when those capabilities are needed.

3. Our current cluster

Right now we're using:

admin

through:

argocd login localhost:8080 --username admin --insecure

So:

admin
  ↓
local Argo CD account
  ↓
full administrative access

We don't currently have an enterprise IdP configured.

Therefore, we should not pretend to create a fake developers group and call it SSO RBAC.

Instead, we'll understand both models and use a local account for the practical lab.

4. Local user flow

Suppose we create:

alice

in argocd-cm.

Conceptually:

argocd-cm

accounts.alice: login

Then:

alice
  ↓
logs into Argo CD
  ↓
Argo CD authenticates alice
  ↓
RBAC evaluates alice's permissions

But authentication alone doesn't give alice our desired application permissions.

Argo CD documents that local users need appropriate RBAC rules; otherwise their access falls back to the configured policy.default.

5. Where our policy.csv comes in

We currently created:

data:
  policy.csv: |
    p, role:everest-viewer, applications, get, everest-project/*, allow

This says:

role:everest-viewer
        │
        └── can GET
              │
              ▼
       everest-project/*

But we haven't assigned anyone to that role.

For an identity/group-based RBAC configuration, the conceptual mapping is:

identity/group
      │
      ▼
role:everest-viewer
      │
      ▼
applications:get
      │
      ▼
everest-project/*
6. There is another important Argo CD mechanism

For our Everest project, Argo CD also supports Project Roles.

Instead of putting everything into the global:

argocd-rbac-cm

we can define a role directly inside:

AppProject: everest-project

For example, conceptually:

spec:
  roles:
    - name: viewer
      description: Read-only access to Everest applications

      policies:
        - p, proj:everest-project:viewer, applications, get, everest-project/*, allow

      groups:
        - platform-viewers

Argo CD's documentation specifically supports project roles for application-level RBAC scoped to a particular project.

This gives us a useful architecture:

Global RBAC
argocd-rbac-cm
      │
      └── cross-project / global permissions


Project RBAC
everest-project
      │
      └── permissions specific to Everest
7. This is actually useful for our future CI/CD

Remember our eventual architecture:

GitHub Actions
      │
      ▼
Build / Test / Scan
      │
      ▼
GitOps update
      │
      ▼
Argo CD

If CI ever needs to interact with Argo CD directly, we don't want to give CI admin.

Argo CD supports project-role tokens specifically for automation. A project role can be restricted to operations such as syncing applications within its own project.

Conceptually:

GitHub Actions
      │
      ▼
project role token
      │
      ▼
everest-project
      │
      └── sync only what CI needs

That's much better than:

GitHub Actions
      │
      ▼
admin
      │
      └── entire Argo CD
8. Our learning path from here

I would structure the rest of RBAC like this:

                Argo CD RBAC
                     │
       ┌─────────────┼─────────────┐
       │             │             │
   Local Users      SSO       Project Roles
       │             │             │
    alice        IdP groups    CI / team role
       │             │             │
       └─────────────┼─────────────┘
                     ▼
                Permissions
                     │
             ┌───────┼────────┐
             ▼       ▼        ▼
            get     sync    delete

For our practical lab, we'll do:

Lab 1 — Local account

Create a non-admin local account:

everest-viewer
Lab 2 — RBAC

Give it only:

applications:get

for:

everest-project/*
Lab 3 — Test

Login as that user and verify:

view application       ✓
sync application       ✗
delete application     ✗
Lab 4 — Understand SSO

We won't install an IdP just for the sake of a demo. We'll understand:

OIDC/SAML
   ↓
IdP
   ↓
groups claim
   ↓
Argo CD RBAC
   ↓
Project role

That's enough for our Project Everest objective.

One correction to our current manifest

Our current gitops/argocd/rbac-cm.yaml is not yet a complete declarative configuration for the existing argocd-rbac-cm. If we apply it as written, we need to be careful not to accidentally omit other RBAC configuration that may exist later.

Also, Argo CD's declarative setup documentation recommends the Argo CD labels on configuration ConfigMaps, including:

labels:
  app.kubernetes.io/part-of: argocd

for declaratively managed configuration.

So don't apply our RBAC ConfigMap yet.

====================================================

Argo CD Projects + RBAC — practical part

We already have:

GitOps Repository
       │
       ▼
Argo CD Application
       │
       ▼
everest-project
       │
       ├── allowed repo
       ├── allowed namespaces
       └── allowed resource types

That is the Project boundary.

Now we add the identity/access boundary:

User
 │
 ▼
Authentication
 │
 ├── Local user
 └── SSO / external IdP
        │
        ▼
      Groups
        │
        ▼
   Argo CD RBAC
        │
        ▼
   Project / Application

Argo CD supports local users, but local accounts don't provide group-management features; SSO is the normal enterprise approach when you need IdP groups.

What we'll actually build today

We'll use a local user because we don't have an external IdP configured in this lab.

admin
  │
  └── creates
        │
        ▼
everest-viewer
        │
        └── role: everest-viewer
                │
                ├── GET applications in everest-project
                ├── view application state
                │
                └── NO sync
                    NO delete
                    NO modify

This gives us the practical understanding we need.

Step 1 — inspect the current Argo CD configuration

Before changing anything, let's make sure we don't overwrite an existing configuration.

Run:

kubectl -n argocd get configmap argocd-cm -o yaml

And:

kubectl -n argocd get configmap argocd-rbac-cm -o yaml
Why these two?

argocd-cm → who can authenticate

For example:

accounts.everest-viewer: login

argocd-rbac-cm → what that authenticated identity can do

For example:

p, role:everest-viewer, applications, get, everest-project/*, allow
g, everest-viewer, role:everest-viewer

Argo CD's documentation defines local accounts in argocd-cm, while authorization policies are handled through RBAC configuration.

================================================================

Perfect. This is exactly the state we wanted after rebuilding EKS.

Your output confirms:

Argo CD
│
├── AppProject
│   └── everest-project ✅
│
└── Application
    └── everest-demo
         │
         ├── Project: everest-project ✅
         ├── Source: GitHub/main ✅
         ├── Sync: Synced ✅
         ├── Health: Healthy ✅
         │
         └── everest-dev
              ├── Namespace ✅
              ├── Service ✅
              └── Deployment ✅

And importantly, Argo CD has reconciled the application from Git and recreated the workload in the new EKS cluster.

The application is synced to commit:

6e53f7f

So our Git → Argo CD → EKS path is healthy again.

Now RBAC

Let's keep this practical.

Our goal is to create:

admin
  │
  │ manages Argo CD
  ▼
everest-viewer
  │
  │ can VIEW
  ▼
everest-project
  │
  └── everest-demo

But:

everest-viewer
   ✗ sync
   ✗ delete
   ✗ modify

This lets us understand RBAC by actually testing it.

Step 1 — create the local account

First, we need to add the account to argocd-cm.

Your current argocd-cm already contains important Argo CD configuration, so we should not replace the ConfigMap wholesale.

For this lab, use a patch:

kubectl -n argocd patch configmap argocd-cm \
  --type merge \
  -p '{"data":{"accounts.everest-viewer":"login"}}'

Then verify:

kubectl -n argocd get configmap argocd-cm \
  -o jsonpath='{.data.accounts\.everest-viewer}{"\n"}'

Expected:

login
What does login mean?

It means:

everest-viewer
      │
      ▼
can authenticate to Argo CD

It does not yet mean the user can access applications.

That's an important distinction:

Authentication
      ≠
Authorization

The account exists, but RBAC still determines what it can do.

=========================================================================

Perfect. The account is now defined correctly:

accounts.everest-viewer: login

So we have completed authentication setup.

Now let's do the important part: authorization.

Step 2 — create the RBAC policy

We already have this file in Git:

gitops/argocd/rbac-cm.yaml

It currently contains the basic policy we created earlier, but let's update it to include the user-to-role mapping.

Use:

cat > gitops/argocd/rbac-cm.yaml <<'EOF'
apiVersion: v1
kind: ConfigMap

metadata:
  name: argocd-rbac-cm
  namespace: argocd
  labels:
    app.kubernetes.io/part-of: argocd

data:
  policy.csv: |
    p, role:everest-viewer, applications, get, everest-project/*, allow
    g, everest-viewer, role:everest-viewer
EOF

Then inspect it:

cat gitops/argocd/rbac-cm.yaml

You should see:

p, role:everest-viewer, applications, get, everest-project/*, allow
g, everest-viewer, role:everest-viewer
Understand these two lines

This is the most important part of today's RBAC lesson.

1. Permission
p, role:everest-viewer, applications, get, everest-project/*, allow

Read it conceptually as:

role:everest-viewer
        │
        └── may GET
              │
              └── applications
                    │
                    └── inside everest-project

So the role can read applications belonging to everest-project.

It does not grant:

sync
delete
update
create
2. User → role mapping
g, everest-viewer, role:everest-viewer

This means:

user: everest-viewer
        ↓
role: everest-viewer

So together:

everest-viewer
      │
      ▼
role:everest-viewer
      │
      ▼
applications: get
      │
      ▼
everest-project/*

This is the core RBAC pattern.

Step 3 — apply it

Before applying, run:

kubectl apply --dry-run=client -f gitops/argocd/rbac-cm.yaml

If that looks good:

kubectl apply -f gitops/argocd/rbac-cm.yaml

Then verify:

kubectl -n argocd get configmap argocd-rbac-cm \
  -o jsonpath='{.data.policy\.csv}{"\n"}'

Expected:

p, role:everest-viewer, applications, get, everest-project/*, allow
g, everest-viewer, role:everest-viewer

================================================================

Perfect. RBAC policy is loaded successfully. The warning you saw is not a problem here; kubectl apply added the missing last-applied annotation automatically, and the resulting ConfigMap contains exactly our two policies.

We now have:

Authentication
    │
    └── everest-viewer ✅
          │
          ▼
Authorization
    │
    └── role:everest-viewer
          │
          └── applications: get
                    │
                    └── everest-project/*

Argo CD's current documentation confirms that local users are defined in argocd-cm, while RBAC policies are assigned through argocd-rbac-cm; a local user needs an RBAC rule or otherwise falls back to policy.default.

Next: give the user a password

Because everest-viewer has the login capability, it can authenticate once we set its password. Argo CD provides argocd account update-password for this.

First, make sure your current CLI session is still the admin account:

argocd account get --account admin

Then set the viewer password:

argocd account update-password \
  --account everest-viewer \
  --current-password '<YOUR-ADMIN-PASSWORD>' \
  --new-password '<NEW-VIEWER-PASSWORD>'
Important

Don't paste either password here.

Use a strong temporary password for this lab. The command will store the password securely in Argo CD; we are not putting it in Git.

Afterward, verify the account exists:

argocd account get --account everest-viewer

You should see the account and its capabilities.

Then we'll do the most valuable part

We'll log out of the admin session and authenticate as:

everest-viewer

Then test:

argocd app get everest-demo

and:

argocd app sync everest-demo

==============================================================

Perfect. This confirms the local account is fully created:

Name:         everest-viewer
Enabled:      true
Capabilities: login
Tokens:       NONE

So now we have authentication + authorization configured.

One subtle point

Tokens: NONE is completely fine.

We created a user for interactive login, not automation. API tokens are a separate capability/use case. For now:

everest-viewer
    │
    ├── login ✅
    └── API token ❌  ← intentionally not needed

That's actually a useful distinction for your CI/CD learning later.

Now let's prove the RBAC

Your current CLI session is probably still authenticated as admin.

We need to log in as everest-viewer.

First, make sure the Argo CD port-forward is running in another terminal:

kubectl port-forward svc/argocd-server -n argocd 8080:443

Keep that terminal open.

Then in your working terminal:

argocd login localhost:8080 \
  --username everest-viewer \
  --insecure

It will ask for the password you created.

After login

Run:

argocd account get-user-info

You should see:

Username: everest-viewer

Then test our allowed operation:

argocd app get everest-demo

We expect the user to be able to retrieve the application because our policy says:

applications, get, everest-project/*
Then test the intentionally forbidden operation

Run:

argocd app sync everest-demo

We expect this to be denied, because we never granted:

applications, sync

This is the key practical lesson:

                  everest-viewer
                        │
                        ▼
                role:everest-viewer
                        │
              ┌─────────┴─────────┐
              │                   │
           GET ✅              SYNC ❌
              │                   │
              ▼                   ▼
       View application       Modify desired/live

====================================================================

Yes — and this is actually a very good RBAC lesson. Your CLI is working correctly. The failure is authorization, not authentication.

Look closely at the two errors:

logged in successfully

and then:

PermissionDenied:
projects, get, everest-project

That tells us:

Authentication  ✅
     │
     ▼
everest-viewer successfully logged in
     │
     ▼
Authorization   ❌

Your browser login working confirms the same thing: the credentials are valid. The browser can authenticate the user, but that doesn't automatically grant permission to read Argo CD objects.

Why our policy wasn't quite enough

We gave the role:

p, role:everest-viewer, applications, get, everest-project/*, allow

We thought:

"The user can GET the application."

But Argo CD needs to resolve the application's Project as well.

Your CLI tells us exactly what permission is missing:

projects, get, everest-project

So this is excellent because we're learning from the actual authorization decision rather than just memorizing the RBAC syntax.

We need two permissions
everest-viewer
      │
      ▼
role:everest-viewer
      │
      ├── projects, get, everest-project       ✅
      │
      └── applications, get, everest-project/* ✅

We do not give it sync permission.

Step 1 — update the Git-managed RBAC policy

Edit:

nano gitops/argocd/rbac-cm.yaml

Change the policy.csv section to:

data:
  policy.csv: |
    p, role:everest-viewer, projects, get, everest-project, allow
    p, role:everest-viewer, applications, get, everest-project/*, allow
    g, everest-viewer, role:everest-viewer

So now:

Permission 1
projects, get, everest-project

means:

The viewer can read the everest-project AppProject.

Permission 2
applications, get, everest-project/*

means:

The viewer can read Applications belonging to everest-project.

Mapping
g, everest-viewer, role:everest-viewer

means:

Map the local user everest-viewer to our RBAC role.

Step 2 — validate and apply

Run:

kubectl apply --dry-run=client -f gitops/argocd/rbac-cm.yaml

Then:

kubectl apply -f gitops/argocd/rbac-cm.yaml

Verify:

kubectl -n argocd get configmap argocd-rbac-cm \
  -o jsonpath='{.data.policy\.csv}{"\n"}'

You should now see all three lines.

Step 3 — test again as everest-viewer

You are already logged in as the viewer, so simply run:

argocd app get everest-demo

This time we expect the projects, get error to disappear and the application details to be returned.

Then run:

argocd app sync everest-demo

This one should still fail.

And that failure is exactly what we want:

PermissionDenied:
applications, sync, everest-project/everest-demo

That will prove our RBAC boundary:

                    everest-viewer
                          │
                 role:everest-viewer
                          │
             ┌────────────┴────────────┐
             │                         │
        projects:get             applications:get
             │                         │
             ▼                         ▼
    everest-project             everest-demo
                                       │
                                       │
                                    sync ❌
And one important distinction from what you observed

The browser login:

works = authentication works

The CLI:

PermissionDenied = authorization is being enforced

So there is no CLI login problem here. In fact, your CLI test is giving us exactly the RBAC behavior we wanted to observe.

==========================================================

Exactly. RBAC is now behaving correctly. This is the result we wanted.

Your test proves both sides:

1. Read access — ✅ allowed
argocd app get everest-demo

returned the complete application:

Project:       everest-project
Sync Status:   Synced
Health Status: Healthy

So:

everest-viewer
      ↓
role:everest-viewer
      ↓
projects:get             ✅
applications:get        ✅
2. Sync access — ❌ denied
argocd app sync everest-demo

returned:

PermissionDenied:
applications, sync, everest-project/everest-demo

That's exactly what we intended.

Our role has:

applications, get

but does not have:

applications, sync

So we've demonstrated least-privilege RBAC, rather than merely configuring it.

The important architecture

At this point, you should remember RBAC as three separate layers:

                    User
                      │
             Authentication
                      │
          ┌───────────┴───────────┐
          │                       │
     Local User                SSO User
          │                       │
          │                    IdP Groups
          │                       │
          └───────────┬───────────┘
                      ▼
                Argo CD RBAC
                      │
                      ▼
                   Role
                      │
             ┌────────┴────────┐
             ▼                 ▼
        Application          Project
          actions            access

And separately:

Argo CD Project
      │
      ├── Which Git repositories?
      ├── Which clusters?
      ├── Which namespaces?
      └── Which resource types?

So don't mix these two concepts:

AppProject controls the deployment boundary.

RBAC controls the user's permissions within Argo CD.

Local user vs Enterprise SSO

This is the final conceptual piece we need. We don't need to build an IdP lab.

Our lab
Local account
everest-viewer
      │
      ▼
Argo CD RBAC
Enterprise

Typically:

Engineer
   │
   ▼
Corporate IdP
(Entra ID / Okta / Keycloak etc.)
   │
   ├── platform-engineers
   ├── developers
   └── auditors
          │
          ▼
       Argo CD
          │
          ▼
       RBAC mapping

For example, conceptually:

g, platform-engineers, role:platform-admin
g, developers, role:developer
g, auditors, role:readonly

The important thing is that Argo CD doesn't need to maintain every employee's account itself. The identity provider authenticates users and supplies group membership; Argo CD maps those groups to permissions. Argo CD's documentation recommends SSO when group-based access is required.

What we have completed

I'd mark this topic DONE for Project Everest:

Argo CD Projects + RBAC
────────────────────────────

AppProject                         ✅
  ├── source repository            ✅
  ├── destination namespaces      ✅
  └── resource restrictions       ✅

Local Argo CD user                 ✅
RBAC role                          ✅
User → role mapping                ✅
Read-only application access       ✅
Denied sync operation              ✅
Local user vs SSO concept          ✅

We don't need to go deeper into every RBAC verb, JWT/token administration, Dex configuration, or complex enterprise IdP integration. That would be diminishing returns for your goal.

One thing still needs to be handled

We currently changed the live argocd-cm with:

accounts.everest-viewer: login

and the RBAC ConfigMap is represented in Git.

Before we call the lab completely clean, we should put the local-account configuration into our GitOps repository as well, so the configuration isn't lost on the next EKS rebuild.

============================================================================
