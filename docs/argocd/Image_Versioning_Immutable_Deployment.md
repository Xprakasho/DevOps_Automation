Image Versioning & Immutable Deployments

Image Versioning & Immutable Deployments

This is the next important piece because our promotion exercise used:

nginx:1.27
→
nginx:1.28

Now we need to understand what exactly that version reference means and why production systems often go beyond a simple tag.

1. Image tag

When we write:

image: nginx:1.28

we are referring to an image by:

repository = nginx
tag        = 1.28

The important property is:

A tag is a human-readable reference, not a permanent identity for an image.

A registry can theoretically move a tag to another image.

For example:

Today:

nginx:1.28
    ↓
Image A

Later:

nginx:1.28
    ↓
Image B

So if Kubernetes says:

image: nginx:1.28

we know the requested tag, but the tag itself does not provide the strongest guarantee that we're referring to one immutable artifact forever.

2. Image digest

A container image also has a content-addressed digest:

nginx@sha256:abc123...

Conceptually:

nginx:1.28
      │
      ▼
   Image
      │
      ▼
sha256:ABC...

The digest identifies the image content.

So:

image: nginx@sha256:ABC...

means:

Run the exact image identified by this digest.

If the tag later moves:

nginx:1.28
    ↓
another image

the digest:

sha256:ABC...

still refers to the original image.

3. Tag vs digest

Think of them this way:

Reference	Meaning
nginx:1.28	Human-friendly version/tag
nginx@sha256:...	Exact image identity

A useful mental model:

Tag
 ↓
"Give me version 1.28"

Digest
 ↓
"Give me this exact image"
4. Why this matters for GitOps

Remember our promotion:

Dev
nginx:1.28
   ↓
Staging
nginx:1.28

That's good because we deliberately promoted the same version.

But imagine CI builds:

customer-api:1.28

and pushes it.

GitOps initially records:

image: customer-api:1.28

Now we have a potential ambiguity if that tag is ever overwritten.

A stronger model is:

image: registry.example.com/customer-api@sha256:ABC123...

Now:

Build
  ↓
Image
  ↓
Digest
  ↓
GitOps
  ↓
Dev
  ↓
Staging
  ↓
Production

The exact same artifact is being promoted.

5. Build once, promote many times

This is one of the most important CI/CD principles for Project Everest.

We want:

Source
  ↓
CI build
  ↓
ONE image
  ↓
Registry
  │
  ├── Dev
  │
  ├── Staging
  │
  └── Production

Not:

Source
 ├── build Dev image
 ├── build Staging image
 └── build Production image

Why?

Because rebuilding can produce a different artifact even if the source appears unchanged.

We want the artifact that passed validation in Dev to be the artifact that reaches Staging and eventually Production.

6. Rollback becomes very clean

Suppose we have:

Production
customer-api@sha256:AAA

Then we promote:

customer-api@sha256:BBB

and something doesn't work.

Git rollback simply changes:

BBB

back to:

AAA

Argo CD sees the Git change and reconciles:

Git
 ↓
AAA
 ↓
Argo CD
 ↓
Kubernetes

So Git records which exact artifact should be running.

7. Tags are still useful

This does not mean tags are bad.

Tags are extremely useful for:

humans
release naming
development
debugging
communicating versions

For example:

customer-api:2.4.1

is much easier to understand than:

customer-api@sha256:8e1c...

A common enterprise pattern is therefore to maintain both pieces of information:

Version:
2.4.1

Digest:
sha256:8e1c...

and use the digest as the immutable deployment identity.

8. Where does the digest come from?

CI builds and pushes the image:

GitHub Actions
      ↓
docker build
      ↓
image
      ↓
docker push
      ↓
Container Registry

The registry assigns/records the image digest.

Conceptually:

customer-api:2.4.1
        ↓
sha256:8e1c...

CI can then update GitOps desired state with the exact digest.

9. Connect this to security

This becomes especially important for supply-chain security.

Eventually our pipeline will look like:

Source
  ↓
Test
  ↓
SAST / dependency scan
  ↓
Build
  ↓
Image scan
  ↓
Sign / attest
  ↓
Registry
  ↓
Immutable digest
  ↓
GitOps
  ↓
Argo CD

We don't need to learn image signing yet. That comes later when we cover the GitOps security model.

For now, remember:

Tag       → convenient version reference
Digest    → immutable image identity
10. Our Everest example

Currently our Kustomize Base has:

image: nginx:1.27

Dev overrides it:

images:
  - name: nginx
    newTag: "1.28"

Staging now also has:

images:
  - name: nginx
    newTag: "1.28"

So our current practical exercise demonstrated version promotion using tags.

We do not need to change the live cluster to digest-based deployment right now. The purpose here is to understand the architecture before we introduce it into the CI pipeline.

The model to remember
                 APPLICATION SOURCE
                        │
                        ▼
                       CI
              ┌─────────┼─────────┐
              │         │         │
             test     scan      build
                                  │
                                  ▼
                         Container Registry
                                  │
                         image + digest
                                  │
                                  ▼
                           GitOps Repository
                                  │
                       exact desired version
                                  │
                                  ▼
                              Argo CD
                                  │
                                  ▼
                                 EKS

And promotion:

             SAME ARTIFACT
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
       DEV     STAGING      PROD

That is the core concept.

One important next step

Before we move on to Argo CD Projects/RBAC, I recommend we do one small practical exercise with our existing Everest setup: inspect an actual running container's image ID/digest and compare it with the image tag.

========================================================

Yes. The EKS cluster and Argo CD are back, so we can continue the practical exercise.

Your screenshot confirms:

Argo CD
├── argocd-server              Running
├── argocd-repo-server         Running
├── application-controller     Running
├── applicationset-controller  Running
├── redis                      Running
└── dex                        Running

One thing: because this is a newly recreated cluster, the Argo CD runtime is back, but our Everest applications may not yet be recreated. That's fine.

Practical: Tag vs Image Digest

We'll use the actual Everest workload rather than an Argo CD system image.

Step 1 — Check whether the Dev application exists

Run:

kubectl get application everest-demo -n argocd

If it exists, check:

argocd app get everest-demo

If it doesn't exist, restore it from our Git-managed Application definition:

kubectl apply -f ~/DevOps_Automation/DevOps_Automation/gitops/applications/everest-demo.yaml

Then:

argocd app get everest-demo

We want:

Sync Status:   Synced
Health Status: Healthy
Step 2 — Check the running image tag

Once Dev is running:

kubectl get pods -n everest-dev

Then:

kubectl get deployment everest-demo -n everest-dev \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

We should have:

nginx:1.28

That is the requested image reference from our Kubernetes desired state.

Step 3 — Now inspect the actual image ID

This is the interesting part.

Run:

kubectl get pods -n everest-dev \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{.status.containerStatuses[0].image}{"\n"}{.status.containerStatuses[0].imageID}{"\n\n"}{end}'

You should see something conceptually like:

everest-demo-xxxxx
nginx:1.28
docker-pullable://nginx@sha256:XXXXXXXXXXXXXXXX

everest-demo-yyyyy
nginx:1.28
docker-pullable://nginx@sha256:XXXXXXXXXXXXXXXX

The exact digest will be different.

This is the important distinction

Kubernetes has:

.spec.template.spec.containers[].image

which tells us:

nginx:1.28

But the running container status has:

.status.containerStatuses[].imageID

which tells us the actual pulled image identity:

nginx@sha256:...

So we can visualize:

Desired state
     │
     ▼
nginx:1.28
     │
     │ registry resolves tag
     ▼
Exact image
     │
     ▼
sha256:ABC...
     │
     ▼
Running container

That's a very useful Kubernetes/GitOps distinction:

Tag = what we requested.

Digest/ImageID = what actually got pulled and is running.

One more useful check

After we get the digest, we'll compare the three things:

Git/Kustomize
    ↓
nginx:1.28

Kubernetes Deployment
    ↓
nginx:1.28

Running Pod
    ↓
nginx@sha256:...

This will make the immutable artifact concept concrete before we move on to Argo CD Projects/RBAC.

================================================================================================

Perfect — this is exactly what we wanted to see.

Your three Dev Pods are running:

everest-demo-74cd8744dc-h7nhj
everest-demo-74cd8744dc-rks82
everest-demo-74cd8744dc-vqb27

All are:

1/1 Running

And more importantly, we have both references:

Kubernetes desired image
docker.io/library/nginx:1.28
Actual image ID

All three Pods report:

docker.io/library/nginx@sha256:146adea4768b83c607d0bdfa4188464e3da6e0a3ad4475db1d1d8f64f27c29cc

So we can now see the relationship directly:

Git/Kustomize
      │
      ▼
nginx:1.28
      │
      │ registry resolves tag
      ▼
Kubernetes Pod
      │
      ▼
nginx@sha256:146adea4768b83c607d0bdfa4188464e3da6e0a3ad4475db1d1d8f64f27c29cc
This is the key lesson

nginx:1.28 is the tag/reference we put in our desired state.

The SHA256 digest is the specific image content that the node actually pulled and is running.

And all three Pods have the same digest:

146adea4768b83c607d0bdfa4188464e3da6e0a3ad4475db1d1d8f64f27c29cc

That means the three replicas are running the same image content.

Why this matters for promotion

Imagine CI produces:

customer-api:2.4.1

and the registry gives it:

customer-api@sha256:ABC...

We want:

Dev
  ↓
sha256:ABC...

Staging
  ↓
sha256:ABC...

Production
  ↓
sha256:ABC...

Not three separate builds.

That is the stronger form of:

Build once → promote the same artifact.

One more useful Kubernetes command

You can see the image IDs in a cleaner table with:

kubectl get pods -n everest-dev \
  -o custom-columns='POD:.metadata.name,IMAGE:.status.containerStatuses[0].image,IMAGE_ID:.status.containerStatuses[0].imageID'

You'll get something like:

POD                              IMAGE                    IMAGE_ID
everest-demo-...                 nginx:1.28               nginx@sha256:146...
everest-demo-...                 nginx:1.28               nginx@sha256:146...
everest-demo-...                 nginx:1.28               nginx@sha256:146...

This is a useful operational command to remember.

One important distinction before we move on

We do not need to change our Everest manifests to digest references right now.

Our exercise demonstrated the concept:

Tag → resolved digest → running container

In a real CI/CD implementation, we'll eventually decide how our pipeline records immutable image identity in GitOps. That's where we can discuss:

semantic version tags
build IDs
Git SHA tags
image digests
digest pinning
image promotion
rollback
image signing

But we don't need to implement all of those now.

Image Versioning & Immutable Artifacts — checkpoint

I'd mark this concept as understood/practically verified ✅:

Tag
 ↓
Registry
 ↓
Digest
 ↓
Running container

The next essential GitOps topic is:

Argo CD Projects + RBAC

That's where we move from:

"Argo CD can deploy this"

to:

"Who is allowed to deploy what, to which cluster/namespace, from which Git repository?"

This is particularly important for your goal because GitOps security and access control are part of the enterprise operating model.

=====================================================================

Today's completed topics

1. Application Repository vs GitOps Repository ✅

You now have the mental model:

Application/CI
    ↓
Build/Test/Scan
    ↓
Container Registry
    ↓
GitOps desired state
    ↓
Argo CD
    ↓
EKS

And we documented it in:

docs/gitops/application-vs-gitops.md

2. Image Versioning & Immutable Artifacts ✅

We covered:

nginx:1.28
     ↓
registry resolution
     ↓
nginx@sha256:146ade...
     ↓
running container

And practically verified that all three Pods have the same digest.

3. Build Once → Promote the Same Artifact ✅

Connected this back to our previous exercise:

Dev
  1.28
   ↓
validate
   ↓
Staging
  1.28

rather than rebuilding separately for each environment.

============================================================================