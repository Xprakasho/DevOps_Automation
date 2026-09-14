Lab 1 - GitHub Repository Secrets (Real Implementation)

Step 1 - Create the Secret

Go to your repository.

Repository
    ↓
Settings
    ↓
Secrets and variables
    ↓
Actions
    ↓
New repository secret

Create:

Name:
USER_NAME

Value:
Om

Don't tell me "done" yet.

I want you to actually create it.

Step 2 - Modify Our Existing Workflow

We are not creating a new workflow.

We'll modify our existing one.

At the top, you currently have:

env:
  APP_NAME: DevOps_Automation
  APP_ENV: Development
  PYTHON_VERSION: "3.10"

Change it to:

env:
  APP_NAME: DevOps_Automation
  APP_ENV: Development
  PYTHON_VERSION: "3.10"

  USER_NAME: ${{ secrets.USER_NAME }}

Nothing else.

Step 3 - Add One Temporary Step

Inside create-report, after

- name: Display Repository Information

add this temporary step:

- name: Verify Secret Injection
  run: |
    echo "Testing GitHub Secret..."
    echo "User Name: $USER_NAME"

Don't add Python yet.

Don't add AWS.

Don't add another job.

Keep the experiment small.

Step 4 - Commit
git add .

git commit -m "Lab: Add GitHub Repository Secret"

git push origin main
Step 5 - Observe

Go to:

Actions

↓

First CI Pipeline

Open:

create-report

Open:

Verify Secret Injection

=============================================================================================

🧪 Lab 2 – Python Secret Injection
🎯 Objective

Prove that Python receives the same environment variable that Bash received.

Architecture:

GitHub Secret Store
        │
        ▼
Runner
        │
        ▼
Environment Variable
        │
        ├─────────────┐
        ▼             ▼
     Bash          Python

Notice something:

GitHub doesn't know or care whether you're using Bash, Python, Java, Go, or Node.js.

It simply injects an environment variable.

Step 1

Open:

scripts/python/info.py

Let's first see what you already have there.

Please paste the contents of scripts/python/info.py here.

I don't want to overwrite anything you've already written.

Step 2

We'll add only a few lines.

If your file is simple, we'll add something like this:

import os

print("===================================")
print("Python Secret Injection Demo")
print("===================================")

user_name = os.getenv("USER_NAME")

print(f"User Name: {user_name}")

Notice:

We're using

os.getenv()

instead of

os.environ["USER_NAME"]
Why os.getenv()?

Small engineering discussion.

There are two ways.

Method 1
os.getenv("USER_NAME")

If it doesn't exist:

None

No crash.

Method 2
os.environ["USER_NAME"]

If it doesn't exist:

KeyError

Program stops.

Step 4

Push.

git add .

git commit -m "Lab: Python secret injection"

git push origin main
Expected Output

Inside the python-validation job you should see something like:

===================================
Python Secret Injection Demo
===================================

User Name: ***

Again,

Python receives:

Om

GitHub shows:

***

Exactly the same behavior as Bash.

⭐ What We're Proving

After this lab we'll have proven something important.

GitHub Secret
        │
        ▼
Environment Variable
        │
        ├─────────────┐
        ▼             ▼
    Bash Works    Python Works

Which means...

The secret injection mechanism is language independent.

This is why the same GitHub Secrets mechanism works with:

Python
Bash
Java
Go
Node.js
Terraform
AWS CLI
Docker
Kubernetes tools

because they all understand environment variables.

Updated scripts/python/info.py
import os
import platform
import datetime

print("==================================")
print("Hello from Python!")
print(f"Python Version : {platform.python_version()}")
print(f"Platform       : {platform.system()}")
print(f"Machine        : {platform.machine()}")
print(f"Time           : {datetime.datetime.now()}")
print("==================================")

print()
print("===== GitHub Secret Demo =====")

user_name = os.getenv("USER_NAME")

print(f"User Name      : {user_name}")

print("==============================")

Notice:

We only added:

import os

and

user_name = os.getenv("USER_NAME")

Very small change.

Architecture

Now the flow becomes

GitHub Secret Store
        │
        ▼
Runner
        │
        ▼
Environment Variable
        │
        ├────────────┐
        ▼            ▼
      Bash        Python
        │            │
        ▼            ▼
     $USER_NAME  os.getenv()

Same environment variable.

Different language.

Commit
git add .

git commit -m "Lab: Python secret injection"

git push origin main
Observe

Open

python-validation

I expect something like

==================================
Hello from Python!
Python Version : 3.10.x
Platform       : Linux
Machine        : x86_64
Time           : ...
==================================

===== GitHub Secret Demo =====
User Name      : ***
==============================

Notice...

Python receives

Om

GitHub displays

***

Exactly like Bash.

⭐⭐⭐⭐⭐ Engineering Discussion (Very Important)

This lab proves something much bigger than Python.

Imagine tomorrow you use:

AWS CLI
Terraform
Docker
kubectl
Helm
Ansible
Go
Java

They all work the same way.

They don't communicate with GitHub.

They simply read:

Environment Variable

This is why environment variables became the universal interface for secret injection across operating systems and CI/CD platforms.

=============================================================================================================================

🧪 Module 06 — Lab 3: Workflow vs Job vs Step Scope

We've already proven:

Repository Secret → ✅
Secret injection → ✅
Bash → ✅
Python → ✅
Secret masking → ✅

Now we need to understand scope.

This is important because secure CI/CD isn't just:

"Can I use a secret?"

It's:

"Where exactly should this secret be available?"

1. Our Current State

Right now we have this at workflow level:

env:
  APP_NAME: DevOps_Automation
  APP_ENV: Development
  PYTHON_VERSION: "3.10"
  USER_NAME: ${{ secrets.USER_NAME }}

Your workflow has three jobs:

                    Workflow
                       │
             USER_NAME available
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
 create-report   python-validation   read-report

Because USER_NAME is defined at workflow scope, it is available to all three jobs.

Important: each job still runs on its own runner. There is no shared environment between them.

============================================================================================================

Lab 3A — Job Scope

Now we're going to deliberately change the scope.

Step 1

Remove this line from the top-level env::

USER_NAME: ${{ secrets.USER_NAME }}

So the workflow-level environment becomes:

env:
  APP_NAME: DevOps_Automation
  APP_ENV: Development
  PYTHON_VERSION: "3.10"
Step 2

Add the secret specifically to create-report:

create-report:
  runs-on: ubuntu-latest

  env:
    USER_NAME: ${{ secrets.USER_NAME }}

  steps:

So the structure is:

workflow
│
├── env
│
├── create-report
│     │
│     ├── env: USER_NAME
│     │
│     └── steps
│
├── python-validation
│
└── read-report
What Are We Testing?

We already know create-report can access the secret.

The interesting question is:

What happens to python-validation?

It previously had:

USER_NAME

because it inherited the workflow-level variable.

Now we've removed that.

So:

create-report
   │
   └── USER_NAME = Om

python-validation
   │
   └── USER_NAME = ?

read-report
   │
   └── USER_NAME = ?

Step 1 — Move the secret to create-report

Change your workflow from:

env:
  APP_NAME: DevOps_Automation
  APP_ENV: Development
  PYTHON_VERSION: "3.10"
  USER_NAME: ${{ secrets.USER_NAME }}

to:

env:
  APP_NAME: DevOps_Automation
  APP_ENV: Development
  PYTHON_VERSION: "3.10"

Then:

create-report:
  runs-on: ubuntu-latest

  env:
    USER_NAME: ${{ secrets.USER_NAME }}

  steps:
Step 2 — Temporarily add this to python-validation
- name: Check Secret Scope
  run: |
    echo "Python job secret:"
    echo "User Name: $USER_NAME"

So your python-validation job will look roughly like:

python-validation:
  runs-on: ubuntu-latest

  steps:
    - name: Checkout Repository
      uses: actions/checkout@v4

    - name: Setup Python
      uses: actions/setup-python@v5
      with:
        python-version: ${{ env.PYTHON_VERSION }}

    - name: Run Python Script
      if: ${{ github.ref_name == 'main' }}
      run: python scripts/python/info.py

    - name: Check Secret Scope
      run: |
        echo "Python job secret:"
        echo "User Name: $USER_NAME"
Step 3 — Push and observe

We expect:

create-report:

User Name: ***

python-validation:

Python job secret:
User Name:

That's the experiment.

And notice the important distinction:

GitHub Secret still exists
          │
          ▼
${{ secrets.USER_NAME }}
          │
          X
python-validation has no mapping
          │
          ▼
$USER_NAME = empty

The secret hasn't disappeared. Its availability through the environment has been restricted by scope.

Run this experiment and send me the python-validation output. Then we'll do Step Scope, which is the tightest scope of the three.

✅ Experiment confirmed.

Your screenshots prove the behavior we predicted:

create-report — Job scope
User Name: ***

The secret is available because we defined:

create-report:
  env:
    USER_NAME: ${{ secrets.USER_NAME }}
python-validation — No job-level mapping
Python job secret:
User Name:

The environment variable is empty.

What We Just Proved

The repository secret itself did not change.

GitHub Secret Store
       │
       │ USER_NAME = Om
       ▼
   Still exists

What changed was the scope at which we mapped the secret:

Workflow scope
     ↓
Removed

Job scope
     ↓
create-report only

Therefore:

create-report
    │
    └── USER_NAME = Om ✅

python-validation
    │
    └── USER_NAME = empty ❌

read-report
    │
    └── USER_NAME = empty ❌

And GitHub doesn't need to "share" the secret between runners.

Each job gets its own environment based on its configuration.

==============================================================================================================

⭐ Now the Most Restrictive Scope: Step Scope

This is our final scope experiment.

We'll move the secret from:

Job scope

to:

Step scope
Step 1 — Remove from create-report

Remove:

env:
  USER_NAME: ${{ secrets.USER_NAME }}

from the job.

So:

create-report:
  runs-on: ubuntu-latest

  steps:
Step 2 — Add it ONLY to Verify Secret Injection

Change this:

- name: Verify Secret Injection
  run: |
    echo "Testing secret injection..."
    echo "User Name: $USER_NAME"

to:

- name: Verify Secret Injection
  env:
    USER_NAME: ${{ secrets.USER_NAME }}
  run: |
    echo "Testing secret injection..."
    echo "User Name: $USER_NAME"

Now the secret exists only for that particular step.

Step 3 — Add a Second Step

Immediately after it:

- name: Check Secret After Injection Step
  run: |
    echo "Checking secret after previous step..."
    echo "User Name: $USER_NAME"

Now our experiment looks like:

Step A
│
├── USER_NAME injected
│
└── prints ****
       │
       ▼
Step B
│
└── USER_NAME not injected


✅ The experiment worked exactly as expected.

Your screenshot proves:

Verify Secret Injection
    USER_NAME = ***

        ↓ step ends

Check Secret After Injection Step
    USER_NAME = empty

So we've now completed all three scope experiments.

GitHub Secrets — Practical Understanding
Scope	Available to
Workflow	All jobs/steps
Job	All steps in that job
Step	Only that step

And the security rule:

Use the narrowest practical scope for sensitive information.

=====================================================================================================================

🔄 Restore Our CI First

Yes—before moving to AWS, let's restore the original CI so our learning repository is left in a clean, working state.

We want to remove the temporary experimentation.

1. Remove the temporary Check Secret Scope step

From python-validation, remove:

- name: Check Secret Scope
  run: |
    echo "Python job secret:"
    echo "User Name: $USER_NAME"
2. Remove the temporary Check Secret After Injection Step

From create-report, remove:

- name: Check Secret After Injection Step
  run: |
    echo "Checking secret after previous step..."
    echo "User Name: $USER_NAME"
3. Decide what to do with Verify Secret Injection

Since we've completed the experiment, I recommend removing it as well from the permanent CI.

We already proved secret injection.

Our normal CI should go back to doing its original job:

create-report
     │
     └── report artifact

python-validation
     │
     └── Python validation

read-report
     │
     └── download artifact

Keep the repository secret USER_NAME for now—we can reuse it later if needed.

🧪 Final Validation

After restoring the workflow:

git add .
git commit -m "Restore CI after secrets scope lab"
git push origin main

Then verify:

create-report       ✅
python-validation   ✅
read-report         ✅

============================================================================================================================

🚀 Next: Traditional AWS Credentials

Now we move into the important architectural transition.

We'll first understand the traditional model:

GitHub Actions
      │
      ▼
GitHub Secret
      │
      ├── AWS_ACCESS_KEY_ID
      └── AWS_SECRET_ACCESS_KEY
      │
      ▼
Runner
      │
      ▼
AWS CLI / Terraform
      │
      ▼
AWS

We'll implement enough of it to understand the mechanics.

Then we'll deliberately ask:

What is wrong with this model?

That leads directly to:

Long-lived credentials
        ↓
Rotation
        ↓
Exposure risk
        ↓
Credential management
        ↓
Why do we need something better?
        ↓
OIDC

And then we'll implement the modern architecture:

GitHub Actions
      │
      ▼
OIDC Identity Token (JWT)
      │
      ▼
AWS IAM Trust Policy
      │
      ▼
AWS STS
      │
      ▼
Temporary Credentials
      │
      ▼
Terraform / AWS CLI
      │
      ▼
AWS

One important boundary: for the traditional AWS lab, we'll never paste a real AWS access key or secret into the chat. We'll create/manage any credential only inside the appropriate GitHub/AWS interfaces.

==========================================================================================================================

🔐 Module 06 — Phase 2: AWS Authentication
Lab 4 — Traditional AWS Credentials

Our target architecture today is:

GitHub Actions
      │
      ▼
GitHub Secrets
      │
      ├── AWS_ACCESS_KEY_ID
      └── AWS_SECRET_ACCESS_KEY
      │
      ▼
GitHub Runner
      │
      ▼
AWS CLI / Terraform
      │
      ▼
AWS

Before we implement it, there is one important distinction.

GitHub Secret ≠ AWS Credential

GitHub provides the secure storage and injection mechanism.

AWS provides the identity and authorization system.

So:

GitHub Secret
     │
     │ stores
     ▼
AWS credential
     │
     │ authenticates
     ▼
AWS IAM
Step 1 — Understand the AWS Credential

The traditional IAM user access-key model normally has two values:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

Think of them conceptually as:

Access Key ID
    ↓
"Which credential/identity is this?"

Secret Access Key
    ↓
"Can you prove you possess the secret?"

The actual authorization still comes from AWS IAM policies.

So having an access key does not automatically mean full AWS access.

The IAM identity determines what it can do.

Step 2 — Why We're NOT Creating a Real Credential Yet

I don't want you to create an unnecessarily powerful AWS credential just for a learning experiment.

For this lab, our first objective is to understand the mechanism.

If we later need a real AWS credential to validate the flow, we'll use:

a dedicated identity,
minimal permissions,
short practical exposure,
and revoke/delete it after the lab.

Never use your AWS root credentials for CI/CD.

Step 3 — The Important Question

Suppose we have:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

stored as GitHub repository secrets.

Our workflow could conceptually do:

env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

Then the runner has:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

as environment variables.

Now something like:

aws sts get-caller-identity

can use those credentials.

The AWS CLI reads the credentials from the environment.

⭐ Important Connection

Notice how this builds directly on today's previous labs.

We already proved:

GitHub Secret
      ↓
Environment Variable
      ↓
Bash/Python

Now we're simply changing the consumer:

GitHub Secret
      ↓
Environment Variable
      ↓
AWS CLI
      ↓
AWS

The secret-injection mechanism hasn't changed.

The application consuming the credential has changed.

But Here's the Problem

Imagine you configure this today:

GitHub
   ↓
AWS Access Key
   ↓
AWS

The access key might remain valid for:

weeks
months
potentially much longer

unless someone rotates/revokes it.

That creates a security problem.

The Traditional Model's Weaknesses
1. Long-lived credentials
Credential
   │
   └───────────────► remains valid

If compromised, the attacker may have access until the credential is revoked or expires.

2. Rotation

Someone has to:

Create new credential
       ↓
Update GitHub Secret
       ↓
Deploy/test
       ↓
Revoke old credential

Operational overhead.

3. Secret exposure risk

Even if GitHub protects the secret:

GitHub Secret
     ↓
Runner
     ↓
Environment

the credential ultimately exists inside the runner while the job is executing.

A compromised workflow or malicious dependency could potentially attempt to access credentials available to that job.

4. Credential scope becomes critical

If the AWS identity has:

AdministratorAccess

and the runner is compromised...

That's a very large blast radius.

Hence:

Least privilege becomes extremely important.

And This Leads Directly to OIDC

Instead of:

GitHub
   │
   ▼
Permanent AWS Credential
   │
   ▼
AWS

we want:

GitHub
   │
   ▼
OIDC Identity Token
   │
   ▼
AWS verifies identity
   │
   ▼
STS
   │
   ▼
Temporary AWS Credentials

Now the credential lifetime can be tied to the job/session.

For example, conceptually:

Job starts
   ↓
Get identity token
   ↓
Authenticate to AWS
   ↓
STS issues temporary credentials
   ↓
Use AWS
   ↓
Job ends
   ↓
Credentials expire

That's a fundamentally better security model.

===========================================================================

OIDC + STS gives us several controls simultaneously

GitHub Workflow
      │
      ▼
OIDC Identity Token
      │
      │ authenticate identity
      ▼
AWS IAM Trust Policy
      │
      │ authorize this specific identity
      ▼
STS
      │
      │ issue temporary credentials
      ▼
AWS

If something goes wrong:

Control	                        Protection

Short credential lifetime	Smaller attack window
IAM least privilege	        Smaller blast radius
Trust policy	                Only trusted workflows/identities can assume the role
OIDC	                        No long-lived AWS secret stored in GitHub
STS	                        Temporary credentials instead of permanent keys
Job isolation	                Limits where credentials exist

So you're thinking about security in the right order:

Prevent → Minimize → Detect → Limit → Recover

Not simply:

"Make it impossible to breach."

One Very Important Correction

There's one subtle point I want you to keep straight:

OIDC itself does not issue AWS credentials.

OIDC provides the identity token.

AWS STS exchanges that trusted identity for temporary AWS credentials.

So:

OIDC
  =
Identity / Authentication

while:

STS
  =
Temporary AWS Credential Issuance

And:

IAM Trust Policy
  =
Authorization / "Are you allowed to assume this role?"

This three-part distinction is fundamental.

The Complete Mental Model
                GitHub
                  │
                  │ OIDC JWT
                  ▼
          ┌─────────────────┐
          │   AWS IAM       │
          │ Trust Policy    │
          └────────┬────────┘
                   │
              Policy matches?
                   │
                  YES
                   │
                   ▼
                AWS STS
                   │
                   │ AssumeRoleWithWebIdentity
                   ▼
        Temporary Credentials
                   │
          ┌────────┼────────┐
          ▼        ▼        ▼
       AWS CLI  Terraform  SDK

This is the architecture we're going to implement.

And This Is Why We're Doing the Traditional Model First

If we had jumped directly to:

GitHub → OIDC → STS

you would know how to configure it.

But now you've seen the problem:

GitHub
   │
   ▼
Long-lived AWS credentials
   │
   ├── Storage
   ├── Rotation
   ├── Exposure
   ├── Lifetime
   └── Blast radius

Therefore the architectural question becomes:

Can GitHub prove who/what the workflow is without possessing a permanent AWS credential?

Yes.

That's where OIDC enters.

Next Practical Step

Now we'll move from the conceptual traditional model to the AWS side of OIDC.

Before touching GitHub, we need to establish three AWS components:

1. IAM OIDC Identity Provider
          ↓
2. IAM Role
          ↓
3. Trust Policy

Then GitHub will be allowed to obtain the OIDC token and AWS will validate it against the trust relationship.

We have already established the architecture:

GitHub Actions
     │
     │  OIDC JWT
     ▼
AWS IAM OIDC Provider
     │
     ▼
IAM Role + Trust Policy
     │
     ▼
AWS STS
     │
     ▼
Temporary Credentials
     │
     ▼
AWS CLI / Terraform
===========================================================================================================

🧪 OIDC Lab 1 — Create/Verify AWS OIDC Provider

We will not touch the GitHub workflow yet.

First, AWS needs to know:

"I trust GitHub's OIDC identity provider."

Step 1 — Open AWS IAM

In your AWS console:

AWS Console
   ↓
IAM
   ↓
Identity providers

Look for:

token.actions.githubusercontent.com
First check:

Do you already have an OIDC provider for GitHub?

There are two possibilities.

A — Already exists

Something like:

OpenID Connect
token.actions.githubusercontent.com

Then don't create another one.

Tell me it exists and we'll inspect it.

B — Doesn't exist

Create one with:

Provider URL

https://token.actions.githubusercontent.com

Audience

sts.amazonaws.com

These are the values GitHub documents for AWS OIDC, and AWS uses the OIDC provider to establish trust with the external identity provider.

⭐ Important Concept

Don't confuse this with the IAM role.

We are creating:

IAM
 │
 ├── OIDC Identity Provider
 │       │
 │       └── "I recognize GitHub as an identity provider"
 │
 └── IAM Role
         │
         └── "I allow THIS GitHub identity to assume me"

The provider establishes who can present identities.

The role's trust policy determines which identity is actually trusted.

That's why we need both.

Security Warning

When we create the role in the next step, we will NOT use a broad trust policy such as:

repo:*

or trust every GitHub repository.

AWS specifically recommends restricting the sub condition in the trust policy to the appropriate GitHub organization/repository/branch or environment. Otherwise, other repositories could potentially assume the role.

🧪 OIDC Lab 1 — Create GitHub OIDC Provider

Click:

Add provider

You should get a provider configuration screen.

1. Provider type

Select:

OpenID Connect
2. Provider URL

Enter exactly:

https://token.actions.githubusercontent.com
3. Audience

Enter:

sts.amazonaws.com

These are the values GitHub documents for configuring AWS OIDC.

⚠️ Before You Click "Add Provider"

Let's understand what we're actually creating.

We're not creating credentials.

We're not creating an IAM user.

We're not creating an IAM role yet.

We're telling AWS:

AWS IAM
   │
   ▼
"I recognize this external identity provider."
   
https://token.actions.githubusercontent.com

Conceptually:

GitHub
   │
   │ issues JWT
   ▼
token.actions.githubusercontent.com
   │
   ▼
AWS IAM OIDC Provider

AWS now has the ability to establish a trust relationship with identities issued by GitHub.

Very Important: Provider ≠ Trust

Don't think:

"Once I create this provider, GitHub can access AWS."

No.

We're only at:

                 AWS
                  │
        OIDC Provider registered
                  │
                  X
           No role access yet

We still need:

OIDC Provider
      │
      ▼
IAM Role
      │
      ▼
Trust Policy

The trust policy is where we'll say something much more precise:

"I trust this particular GitHub repository, and eventually this particular branch/workflow identity, to assume this role."

AWS specifically recommends restricting the GitHub sub claim in the trust policy so that arbitrary repositories cannot assume the role.

Your Action

Enter:

Provider type:
OpenID Connect

Provider URL:
https://token.actions.githubusercontent.com

Audience:
sts.amazonaws.com

Then click Add provider.

🧪 OIDC Lab 2 — IAM Role + Trust Policy

Now we're at the most important security part.

The OIDC provider says:

"I recognize GitHub as an identity provider."

The IAM role will say:

"Which GitHub identities am I willing to trust?"

This is where our sub claim becomes critical. GitHub documents aud and sub as the primary claims used to scope cloud-role trust, and AWS recommends restricting the sub condition to a specific repository/branch rather than trusting GitHub broadly.

Step 1 — Create Role

In IAM:

IAM
 ↓
Roles
 ↓
Create role

For Trusted entity type, select:

Custom trust policy

We're going to write the trust relationship ourselves.

Do not use a broad "trust GitHub" configuration.

Step 2 — Understand the Trust Policy Before We Enter It

The important structure is:

Principal
   ↓
GitHub OIDC Provider

Condition
   ↓
aud = sts.amazonaws.com
   ↓
sub = OUR SPECIFIC GITHUB IDENTITY

Conceptually:

GitHub
  │
  │ JWT
  ▼
AWS
  │
  ├── iss = GitHub              ✅
  ├── aud = sts.amazonaws.com   ✅
  └── sub = our repo/main      ✅
             │
             ▼
        AssumeRole allowed

If any required condition doesn't match:

❌ AssumeRole denied
Step 3 — One Important 2026 Change

There is a current GitHub change we need to account for.

GitHub now supports immutable OIDC subject claims. Repositories created after July 15, 2026, or repositories that opt into the immutable format, can have a sub containing the owner and repository IDs rather than only the owner/repository names.

Therefore, don't enter a trust policy yet.

First we need to determine which sub format your repository actually uses.

This is important because I don't want us to blindly copy an old tutorial.

🧪 Step 4 — Let's Ask GitHub What sub Is

We'll temporarily add a diagnostic step to our workflow.

GitHub provides an OIDC token only when the workflow has the appropriate permission:

permissions:
  id-token: write

GitHub's documentation confirms that each job can request a short-lived OIDC JWT and that the token contains claims such as iss, aud, sub, repository, ref, and workflow.

We'll not print the entire JWT because that would be unnecessary exposure.

Instead, we'll use GitHub's supported OIDC mechanism to inspect the claims safely.

🧪 OIDC Lab 2A — Inspect the Real JWT Claims

We're going to temporarily request an OIDC token.

Step 1 — Add OIDC permission

At the workflow level, add:

permissions:
  id-token: write
  contents: read

So the beginning becomes:

name: First CI Pipeline

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

env:
  APP_NAME: DevOps_Automation
  APP_ENV: Development
  PYTHON_VERSION: "3.10"
Why id-token: write?

This does not mean GitHub is giving AWS access.

It means:

This workflow is permitted to request an OIDC identity token.

GitHub specifically requires id-token: write for a workflow/job that requests an OIDC token.

Step 2 — Temporary diagnostic step

For now, add this to create-report, preferably after checkout:

- name: Inspect OIDC Claims
  env:
    ACTIONS_ID_TOKEN_REQUEST_URL: ${{ env.ACTIONS_ID_TOKEN_REQUEST_URL }}
    ACTIONS_ID_TOKEN_REQUEST_TOKEN: ${{ env.ACTIONS_ID_TOKEN_REQUEST_TOKEN }}
  run: |
    set -euo pipefail

    TOKEN=$(curl -sS \
      -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
      "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=sts.amazonaws.com" \
      | jq -r '.value')

    PAYLOAD=$(echo "$TOKEN" | cut -d '.' -f2 | base64 -d 2>/dev/null)

    echo "$PAYLOAD" | jq '{
      iss,
      sub,
      aud,
      repository,
      repository_owner,
      ref,
      sha,
      actor
    }'
Important security point

We are not printing TOKEN.

The JWT itself remains hidden.

We're only decoding and displaying selected claims:

iss
sub
aud
repository
repository_owner
ref
sha
actor

That's exactly what we need for our trust policy.

What We're Looking For

I expect something along these lines:

Traditional subject
"sub": "repo:Xprakasho/DevOps_Automation:ref:refs/heads/main"

or potentially the new immutable format:

"sub": "repo:Xprakasho@OWNER_ID/DevOps_Automation@REPO_ID:ref:refs/heads/main"

GitHub's current documentation confirms both formats exist depending on repository age/immutable-subject configuration.

And we deliberately requested:

audience=sts.amazonaws.com

so we expect:

"aud": "sts.amazonaws.com"
Why This Experiment Matters

We're following the exact security chain:

GitHub Workflow
      │
      │ requests OIDC token
      ▼
GitHub OIDC Provider
      │
      ▼
JWT
 ┌────────────────────┐
 │ iss                 │
 │ aud                 │
 │ sub                 │  ← MOST IMPORTANT FOR OUR TRUST
 │ repository          │
 │ ref                 │
 └────────────────────┘
      │
      ▼
AWS IAM Trust Policy

We are not going to write:

repo:*

or some copied example.

We're going to build the trust policy around the actual identity issued to your workflow.

That's the security-first approach.

One more important thing

The sub is not simply:

Xprakasho/DevOps_Automation

It contains context that lets AWS distinguish things such as:

repository
branch
environment

GitHub and AWS specifically use the sub and aud claims to constrain which workflows can assume the AWS role.

So don't create the IAM role yet.

Your next action

Add the temporary permission + diagnostic step, push to main, and send me the OIDC Claims output.

From that output we'll identify:

iss → aud → sub

🛠️ Fix the OIDC Diagnostic Step

Replace your entire Inspect OIDC Claims step with this:

  - name: Inspect OIDC Claims
    run: |
      set -euo pipefail

      TOKEN=$(curl -sS \
        -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
        "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=sts.amazonaws.com" \
        | jq -r '.value')

      PAYLOAD=$(python3 -c '
      import sys
      import json
      import base64

      token = sys.stdin.read().strip()
      payload = token.split(".")[1]
      payload += "=" * (-len(payload) % 4)

      decoded = base64.urlsafe_b64decode(payload)
      data = json.loads(decoded)

      selected = {
          "iss": data.get("iss"),
          "sub": data.get("sub"),
          "aud": data.get("aud"),
          "repository": data.get("repository"),
          "repository_owner": data.get("repository_owner"),
          "ref": data.get("ref"),
          "sha": data.get("sha"),
          "actor": data.get("actor")
      }

      print(json.dumps(selected, indent=2))
      ' <<< "$TOKEN")

      echo "$PAYLOAD"
Important

We are not printing:

TOKEN

We're only decoding selected claims.

So the JWT itself remains out of the logs.

Why This Version Is Better

The actual flow is now:

GitHub Runner
    │
    ├── ACTIONS_ID_TOKEN_REQUEST_URL
    │
    └── ACTIONS_ID_TOKEN_REQUEST_TOKEN
              │
              ▼
           GitHub
              │
              ▼
         OIDC JWT
              │
              ▼
       Python decodes JWT
              │
              ▼
       Display selected claims

And notice:

We don't manually create the OIDC token.

GitHub provides the mechanism.

We request it.

What We Expect to See

After you push, the step should produce something similar to:

{
  "iss": "https://token.actions.githubusercontent.com",
  "sub": "repo:Xprakasho/DevOps_Automation:ref:refs/heads/main",
  "aud": "sts.amazonaws.com",
  "repository": "Xprakasho/DevOps_Automation",
  "repository_owner": "Xprakasho",
  "ref": "refs/heads/main",
  "sha": "...",
  "actor": "Xprakasho"
}

Do not worry if your sub looks different.

That's actually what we're trying to discover.

⭐ The Most Important Field

When the run succeeds, look specifically at:

"iss": "...",
"aud": "...",
"sub": "..."

We're particularly interested in:

sub

because our AWS trust policy will eventually say something equivalent to:

Only this subject
       ↓
can assume this IAM role
And This Is Our Security Boundary

We're going to build:

GitHub
   │
   │ JWT
   ▼
AWS OIDC Provider
   │
   ▼
IAM Role
   │
   └── Trust Policy
          │
          ├── iss/provider
          ├── aud = sts.amazonaws.com
          └── sub = YOUR ACTUAL WORKFLOW IDENTITY

If someone from another repository presents a GitHub JWT:

sub = repo:SomeoneElse/OtherRepo:...

our policy should reject it.

That's the least-privilege identity model we've been discussing.

One more thing

Your current failed run will show:

create-report ❌

and therefore read-report won't run because it depends on:

needs: create-report

That's expected. Don't modify needs.

Once we fix the diagnostic step, the normal pipeline should return to:

create-report       ✅
python-validation   ✅
read-report         ✅

with the OIDC diagnostic step executing inside create-report.

Do this one change, push it, and send me the output of Inspect OIDC Claims.

===================================================================================================

Complete first-ci.yml

Replace the whole file with this:

name: First CI Pipeline

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

env:
  APP_NAME: DevOps_Automation
  APP_ENV: Development
  PYTHON_VERSION: "3.10"

jobs:

  create-report:
    runs-on: ubuntu-latest

    steps:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Inspect OIDC Claims
        run: |
          set -euo pipefail

          TOKEN=$(curl -sS \
            -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
            "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=sts.amazonaws.com" \
            | jq -r '.value')

          export TOKEN

          python3 -c 'import os,json,base64; t=os.environ["TOKEN"]; p=t.split(".")[1]; p+="="*(-len(p)%4); d=json.loads(base64.urlsafe_b64decode(p)); print(json.dumps({"iss":d.get("iss"),"sub":d.get("sub"),"aud":d.get("aud"),"repository":d.get("repository"),"repository_owner":d.get("repository_owner"),"ref":d.get("ref"),"sha":d.get("sha"),"actor":d.get("actor")},indent=2))'

      - name: Display Repository Information
        run: |
          echo "========================================"
          echo "      DevOps Automation CI Pipeline"
          echo "========================================"
          echo ""
          echo "Repository: ${{ github.repository }}"
          echo "Branch: ${{ github.ref_name }}"
          echo "Commit SHA : ${{ github.sha }}"
          echo "Triggered by: ${{ github.actor }}"
          echo "Workflow   : ${{ github.workflow }}"
          echo "Run Number : ${{ github.run_number }}"
          echo "Runner OS  : $RUNNER_OS"
          echo ""
          echo "Application: $APP_NAME"
          echo "Environment: $APP_ENV"
          echo "Python     : ${{ env.PYTHON_VERSION }}"
          echo "========================================"

      - name: Make Bash Script Executable
        run: chmod +x scripts/bash/hello.sh

      - name: Run Bash Script
        run: ./scripts/bash/hello.sh

      - name: Create Report
        run: |
          echo "GitHub Actions Artifact Demo" > report.txt
          cat report.txt

      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: demo-report
          path: report.txt

      - name: Success Function Demo
        if: ${{ success() }}
        run: echo "All previous steps succeeded."

  python-validation:
    runs-on: ubuntu-latest

    steps:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}

      - name: Run Python Script
        if: ${{ github.ref_name == 'main' }}
        run: python scripts/python/info.py

  read-report:
    needs: create-report
    runs-on: ubuntu-latest

    steps:

      - name: Download Report
        uses: actions/download-artifact@v4
        with:
          name: demo-report

      - name: Pipeline Completed
        if: ${{ always() }}
        run: echo "✅ Pipeline completed."
What changed?

The important part is now extremely simple:

      - name: Inspect OIDC Claims
        run: |
          set -euo pipefail

          TOKEN=$(curl -sS \
            -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
            "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=sts.amazonaws.com" \
            | jq -r '.value')

          export TOKEN

          python3 -c '...'

There is no:

PAYLOAD=$(python3 <<...)

and no:

python3 <<'PY'
...
PY

So we have eliminated the two sources of syntax/indentation problems we've been fighting.

What I want you to do

Before pushing, save the file and check the YAML locally if you can:

yamllint .github/workflows/first-ci.yml

If you don't have yamllint, that's okay.

You can also use:

git diff --check

Then:

git add .github/workflows/first-ci.yml
git commit -m "Lab: inspect GitHub OIDC claims"
git push origin main
Expected result

The first part should now be:

Set up job                  ✅
Checkout Repository         ✅
Inspect OIDC Claims         ✅
Display Repository Info     ✅
Make Bash Script Executable ✅
Run Bash Script             ✅
Create Report               ✅
Upload Report               ✅
Success Function Demo       ✅

And the OIDC step should show something similar to:

{
  "iss": "https://token.actions.githubusercontent.com",
  "sub": "repo:Xprakasho/DevOps_Automation:ref:refs/heads/main",
  "aud": "sts.amazonaws.com",
  "repository": "Xprakasho/DevOps_Automation",
  "repository_owner": "Xprakasho",
  "ref": "refs/heads/main",
  "sha": "...",
  "actor": "Xprakasho"
}

Don't worry if sub differs. That's the exact value we need to discover.

One thing I want to emphasize

We're now doing this properly:

GitHub workflow
      │
      ▼
OIDC permission
      │
      ▼
Request JWT
      │
      ▼
Read claims
      │
      ├── iss
      ├── aud
      └── sub  ⭐

Once this succeeds, we stop touching the diagnostic code.

====================================================================================================================================

Step 1 — Replace the diagnostic step

In your first-ci.yml, delete the entire current:

- name: Inspect OIDC Claims

section.

Replace it with:

      - name: Inspect OIDC Claims
        uses: github/actions-oidc-debugger@main

That's it.

Your beginning should now look like:

name: First CI Pipeline

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

env:
  APP_NAME: DevOps_Automation
  APP_ENV: Development
  PYTHON_VERSION: "3.10"

jobs:

  create-report:
    runs-on: ubuntu-latest

    steps:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Inspect OIDC Claims
        uses: github/actions-oidc-debugger@main

      - name: Display Repository Information
        run: |
          echo "========================================"
          echo "      DevOps Automation CI Pipeline"
          echo "========================================"
          echo ""
          echo "Repository: ${{ github.repository }}"
          echo "Branch: ${{ github.ref_name }}"
          echo "Commit SHA : ${{ github.sha }}"
          echo "Triggered by: ${{ github.actor }}"
          echo "Workflow   : ${{ github.workflow }}"
          echo "Run Number : ${{ github.run_number }}"
          echo "Runner OS  : $RUNNER_OS"
          echo ""
          echo "Application: $APP_NAME"
          echo "Environment: $APP_ENV"
          echo "Python     : ${{ env.PYTHON_VERSION }}"
          echo "========================================"

Leave the rest of your CI exactly as it is.

Why this is a better lab

GitHub's own documentation says this debugger action:

requests a JWT and prints the claims included within the JWT.

So we're no longer manually doing:

curl
 ↓
JWT
 ↓
base64
 ↓
Python
 ↓
JSON

Instead:

GitHub Actions
      │
      ▼
OIDC Debugger
      │
      ▼
JWT
      │
      ▼
Claims

This lets us focus on what actually matters.

Step 2 — Push
git add .github/workflows/first-ci.yml
git commit -m "Lab: use GitHub OIDC debugger"
git push origin main

Then look at:

Actions
 → First CI Pipeline
 → create-report
 → Inspect OIDC Claims
What we're looking for

The debugger should expose claims including things such as:

iss
sub
aud
repository
repository_owner
ref
sha
actor

GitHub's OIDC documentation confirms these are part of the token claims.

The three most important for our AWS trust policy are:

iss = https://token.actions.githubusercontent.com

aud = sts.amazonaws.com

sub = ???
And sub is the key.

We're going to take the actual sub from your workflow and build the AWS IAM trust condition around it.

One important security point

The debugger action is only for this learning exercise.

Once we understand the claims and create the IAM role, we'll remove the debugger from the permanent CI.

========================================================================================================================

🔐 Now We Build the Trust Policy

This is the most important part of today's lab.

We want AWS to say:

"I trust GitHub, but I don't trust every GitHub workflow."

Our intended policy is:

GitHub OIDC Provider
        │
        ▼
     JWT
        │
        ├── iss → GitHub ✅
        │
        ├── aud → sts.amazonaws.com ✅
        │
        └── sub → Xprakasho/DevOps_Automation/main ✅
                         │
                         ▼
                    IAM Role

Anything else should be rejected.

🧪 OIDC Lab 2B — Create IAM Role

Go to:

AWS Console → IAM → Roles → Create role

Select:

Trusted entity type

Choose:

Custom trust policy

Now AWS will show the trust-policy editor.

Use this:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::587748224379:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:Xprakasho/DevOps_Automation:ref:refs/heads/main"
        }
      }
    }
  ]
}
Important

Your screenshot shows the AWS account ID:

587748224379

So I've used that in the provider ARN.

The critical part is:

"Action": "sts:AssumeRoleWithWebIdentity"

This tells AWS:

This role can be assumed using a web identity token.

And:

"token.actions.githubusercontent.com:aud": "sts.amazonaws.com"

restricts the intended audience.

And most importantly:

"token.actions.githubusercontent.com:sub":
    "repo:Xprakasho/DevOps_Automation:ref:refs/heads/main"

restricts which GitHub identity can assume this role.

⭐ This Is the Security Boundary

Suppose someone from another repository generates a perfectly valid GitHub JWT:

sub =
repo:Attacker/BadRepo:ref:refs/heads/main

The JWT could be:

correctly signed ✅
issued by GitHub ✅
valid and unexpired ✅
intended for AWS STS ✅

But:

sub ≠ trusted sub

Therefore:

AWS IAM Trust Policy
        │
        ▼
      DENY ❌

This connects directly to what you learned earlier about JWT:

Authentication of the token is not the same as authorization to perform an action.

The JWT proves:

"GitHub issued this identity."

The IAM trust policy decides:

"Do I authorize this identity to assume this role?"

That's the distinction we've been building toward.

What Happens After the Trust Policy?

We're not done yet.

The role also needs a permissions policy.

Think of two completely separate questions:

Trust Policy
WHO can assume this role?
Permissions Policy
WHAT can this role do after it is assumed?

So:

GitHub JWT
    │
    ▼
Trust Policy
    │
    │ "Yes, this GitHub workflow is trusted."
    ▼
STS
    │
    ▼
Temporary Credentials
    │
    ▼
Permissions Policy
    │
    │ "These are the AWS actions you're allowed to perform."
    ▼
AWS Resources

This distinction is extremely important for IAM.

For today's first test

Don't give the role AdministratorAccess.

We'll eventually give it only the minimum permissions needed for our CI experiment.

For now, create the role with the trust policy above, and use a simple, restricted permission policy when we get to that stage.

Stop after the role is created.

Don't configure GitHub's AWS credentials action yet.

For our learning project, I recommend:

GitHubActions-OIDC-Role
Description

You can put:

OIDC role for GitHub Actions CI/CD with least-privilege AWS access

=====================================================================================================================

Now the exciting part: STS

We have completed the authentication/trust configuration.

Now we need to actually make the exchange:

GitHub
   │
   │ OIDC JWT
   ▼
AWS STS
   │
   │ AssumeRoleWithWebIdentity
   ▼
GitHubActions-OIDC-Role
   │
   ▼
Temporary AWS credentials

GitHub's current recommended AWS pattern is to use aws-actions/configure-aws-credentials; it exchanges the GitHub OIDC JWT for short-lived AWS credentials.

Next lab: OIDC → STS

We'll add one step to your CI:

- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v6
  with:
    role-to-assume: arn:aws:iam::587748224379:role/GitHubActions-OIDC-Role
    aws-region: us-east-1

Then immediately:

- name: Verify AWS Identity
  run: |
    aws sts get-caller-identity

Notice what we are not providing:

AWS_ACCESS_KEY_ID       ❌
AWS_SECRET_ACCESS_KEY   ❌
GitHub AWS secret       ❌

Instead:

id-token: write
       ↓
GitHub JWT
       ↓
AWS STS
       ↓
Temporary credentials

The AWS action documentation confirms that with OIDC, role-to-assume plus id-token: write is sufficient; no long-lived AWS access keys are required.

And this is exactly the concept you wanted to learn:

OIDC does not directly become an AWS access key.

It is:

OIDC JWT → STS validates/trusts identity → STS issues temporary AWS credentials → AWS APIs use those credentials.

========================================================================================================================

🧪 Lab 3 — OIDC → STS

We will not give the role S3/EC2 permissions yet.

Our only question is:

Can GitHub successfully exchange its OIDC identity for an AWS STS session?

Step 1 — Keep this permission

You already have:

permissions:
  id-token: write
  contents: read

Keep it.

id-token: write only permits the workflow to request an OIDC token; it does not give the workflow AWS permissions.

Step 2 — Add AWS credentials action

In create-report, immediately after the OIDC diagnostic, add:

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6.2.3
        with:
          role-to-assume: arn:aws:iam::587748224379:role/GitHubActions-OIDC-Role
          aws-region: us-east-1

So this part becomes:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Inspect OIDC Claims
        uses: github/actions-oidc-debugger@main

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6.2.3
        with:
          role-to-assume: arn:aws:iam::587748224379:role/GitHubActions-OIDC-Role
          aws-region: us-east-1

The action knows to use GitHub's OIDC token because id-token: write is enabled and no static AWS credentials are supplied.

Step 3 — Immediately verify the STS identity

Add another step:

      - name: Verify AWS STS Identity
        run: |
          aws sts get-caller-identity

So the complete important sequence is:

GitHub Actions
      │
      ▼
OIDC Debugger
      │
      │ JWT
      ▼
Configure AWS Credentials
      │
      │ AssumeRoleWithWebIdentity
      ▼
AWS STS
      │
      │ temporary credentials
      ▼
AWS CLI
      │
      ▼
sts get-caller-identity

The AWS action's documented OIDC example uses this same pattern: configure the role, then run aws sts get-caller-identity.

What should happen internally?

This is the part I want you to understand, not just execute.

1. GitHub creates the JWT

We already proved this:

iss = GitHub
aud = sts.amazonaws.com
sub = repo:Xprakasho/DevOps_Automation:ref:refs/heads/main
2. The AWS action obtains that JWT

No AWS password.

No AWS access key.

No AWS secret key.

3. The action calls STS

Conceptually:

AssumeRoleWithWebIdentity(
    RoleArn,
    WebIdentityToken
)
4. STS validates the trust

AWS checks the identity against the IAM role:

OIDC Provider       ✓
aud                 ✓
sub                 ✓

Your trust policy says this exact GitHub identity is allowed.

5. STS issues temporary credentials

Conceptually:

AccessKeyId
SecretAccessKey
SessionToken
Expiration

These are temporary session credentials, not permanent IAM user credentials.

6. AWS CLI uses them

Therefore:

aws sts get-caller-identity

should return something like:

{
    "UserId": "...:GitHubActions",
    "Account": "587748224379",
    "Arn": "arn:aws:sts::587748224379:assumed-role/GitHubActions-OIDC-Role/GitHubActions"
}

The exact UserId/session details can differ.

⭐ This is the key concept

Remember our earlier discussion:

OIDC itself doesn't manufacture AWS credentials.

Now we're proving it experimentally.

                 AUTHENTICATION
GitHub ────────────────► AWS
       OIDC JWT
                         │
                         ▼
                       STS
                         │
                 CREDENTIAL ISSUANCE
                         │
                         ▼
              Temporary AWS credentials
                         │
                         ▼
                    AWS APIs

So:

OIDC = identity assertion

STS = credential exchange / temporary credential issuance

IAM Role = permissions identity + trust boundary

That's the architecture we wanted to understand.

One deliberate limitation

Right now your IAM role has no meaningful AWS resource permissions.

That's intentional.

First prove:

OIDC → Trust Policy → STS → Temporary Credentials

Then we'll add a tiny permission such as a read-only sts:GetCallerIdentity test—which the action itself can validate—and subsequently give the role a narrowly scoped S3 permission.

This lets us distinguish:

❌ Authentication/trust failure
vs
❌ Authorization/permission failure

That distinction will become extremely useful when we later do Terraform, Docker, Kubernetes and GitOps.

Add those two steps, push the workflow, and send me the Configure AWS Credentials + Verify AWS STS Identity output.

============================================================================================================================

Yes — now the problem is clear, and we should simplify the workflow before proceeding.

Your screenshot shows:

Build github/actions-oidc-debugger@main
❌ Docker build failed

This is not an AWS/STS failure. The debugger action itself failed while trying to build its Docker container.

More importantly, we don't need the debugger anymore. We already successfully extracted the real claims from your workflow:

iss = https://token.actions.githubusercontent.com
aud = sts.amazonaws.com
sub = repo:Xprakasho/DevOps_Automation:ref:refs/heads/main

So let's remove all diagnostic code and test the actual OIDC → STS path.

1. Remove BOTH OIDC diagnostic steps

You currently have two steps named Inspect OIDC Claims:

Remove this one:
- name: Inspect OIDC Claims
  uses: github/actions-oidc-debugger@main
And remove this entire old block:
- name: Inspect OIDC Claims
  run: |
    set -euo pipefail

    TOKEN=$(curl -sS \
      -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
      "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=sts.amazonaws.com" \
      | jq -r '.value')

    export TOKEN

    python3 -c '...'

We are done with OIDC claim inspection.

2. Keep the actual STS steps

Your important section should now simply be:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6.2.3
        with:
          role-to-assume: arn:aws:iam::587748224379:role/GitHubActions-OIDC-Role
          aws-region: us-east-1

      - name: Verify AWS STS Identity
        run: |
          aws sts get-caller-identity

This is actually the official OIDC pattern for GitHub → AWS. The AWS credentials action uses the GitHub OIDC token and assumes the IAM role with short-lived credentials.

3. Your complete create-report section

To avoid another indentation problem, use this:

  create-report:
    runs-on: ubuntu-latest

    steps:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6.2.3
        with:
          role-to-assume: arn:aws:iam::587748224379:role/GitHubActions-OIDC-Role
          aws-region: us-east-1

      - name: Verify AWS STS Identity
        run: |
          aws sts get-caller-identity

      - name: Display Repository Information
        run: |
          echo "========================================"
          echo "      DevOps Automation CI Pipeline"
          echo "========================================"
          echo ""
          echo "Repository: ${{ github.repository }}"
          echo "Branch: ${{ github.ref_name }}"
          echo "Commit SHA : ${{ github.sha }}"
          echo "Triggered by: ${{ github.actor }}"
          echo "Workflow   : ${{ github.workflow }}"
          echo "Run Number : ${{ github.run_number }}"
          echo "Runner OS  : $RUNNER_OS"
          echo ""
          echo "Application: $APP_NAME"
          echo "Environment: $APP_ENV"
          echo "Python     : ${{ env.PYTHON_VERSION }}"
          echo "========================================"

      - name: Make Bash Script Executable
        run: chmod +x scripts/bash/hello.sh

      - name: Run Bash Script
        run: ./scripts/bash/hello.sh

      - name: Create Report
        run: |
          echo "GitHub Actions Artifact Demo" > report.txt
          cat report.txt

      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: demo-report
          path: report.txt

      - name: Success Function Demo
        if: ${{ success() }}
        run: echo "All previous steps succeeded."

Everything else — python-validation and read-report — stays unchanged.

4. What should happen now

The workflow should reach:

Set up job
     ↓
Checkout Repository             ✅
     ↓
Configure AWS Credentials       ⭐
     ↓
Verify AWS STS Identity         ⭐
     ↓
Display Repository Information  ✅
     ↓
Bash
     ↓
Report
     ↓
Artifact

The critical step is:

Configure AWS Credentials

If it succeeds, we have proven:

GitHub OIDC JWT
      ↓
AWS OIDC Provider
      ↓
IAM Trust Policy
      ↓
STS AssumeRoleWithWebIdentity
      ↓
Temporary AWS credentials

The AWS action's documentation confirms that role-to-assume + id-token: write is the OIDC authentication path and that aws sts get-caller-identity can then verify the resulting identity.

5. What we expect from STS

You should see something similar to:

{
    "UserId": "....:GitHubActions",
    "Account": "587748224379",
    "Arn": "arn:aws:sts::587748224379:assumed-role/GitHubActions-OIDC-Role/..."
}

The important line is:

Arn:
arn:aws:sts::587748224379:assumed-role/GitHubActions-OIDC-Role/...

That proves we are no longer an IAM user.

We are an assumed role session.

And that role session was created through STS.

⭐ This is the milestone

We've now built:

                    IDENTITY
                       │
GitHub ────────────────┤
       OIDC JWT        │
                       ▼
                AWS IAM Provider
                       │
                       ▼
                 Trust Policy
                       │
                       ▼
                      STS
                       │
             TEMPORARY CREDENTIALS
                       │
                       ▼
                 AWS API calls

This is exactly the technology-independent concept you wanted to learn.

After this succeeds, we'll deliberately break the permission side and see the difference between:

"I authenticated successfully" vs "I am authorized to perform this AWS operation."

======================================================================================================================================

This is the milestone we wanted. 🎯

Your screenshot proves the complete chain worked:

GitHub Actions
      │
      │ OIDC JWT
      ▼
AWS OIDC Provider
      │
      ▼
IAM Trust Policy
      │
      ▼
STS AssumeRoleWithWebIdentity
      │
      ▼
Temporary AWS credentials
      │
      ▼
aws sts get-caller-identity

The most important output is:

Authenticated as assumedRoleId ...:GitHubActions

and:

{
  "UserId": "...:GitHubActions",
  "Account": "587748224379",
  "Arn": "arn:aws:sts::587748224379:assumed-role/GitHubActions-OIDC-Role/GitHubActions"
}
What this proves
1. GitHub authenticated itself

Earlier we verified:

iss = https://token.actions.githubusercontent.com
aud = sts.amazonaws.com
sub = repo:Xprakasho/DevOps_Automation:ref:refs/heads/main
2. AWS trusted that identity

Your IAM trust policy matched:

aud ✅
sub ✅

Therefore AWS allowed:

sts:AssumeRoleWithWebIdentity
3. STS issued temporary credentials

This is the critical part.

Your workflow did not have:

AWS_ACCESS_KEY_ID       ❌
AWS_SECRET_ACCESS_KEY   ❌

Instead, STS created an assumed-role session:

arn:aws:sts::587748224379:assumed-role/GitHubActions-OIDC-Role/GitHubActions
4. AWS CLI used those temporary credentials

Then:

aws sts get-caller-identity

successfully authenticated against AWS.

⭐ The concept you should remember

This is the complete distinction:

OIDC
 │
 │ "Here is my signed identity."
 ▼
AWS
 │
 │ IAM Trust Policy
 │ "Do I trust this identity?"
 ▼
STS
 │
 │ "Here are temporary credentials."
 ▼
AWS API
 │
 │ IAM Permissions
 │ "What are you allowed to do?"
 ▼
Resource

There are therefore two different authorization decisions:

Trust policy
WHO can become this role?

Your answer:

Xprakasho/DevOps_Automation
main branch
Permissions policy
WHAT can this role do?

Currently, essentially nothing useful beyond the identity check.

And this distinction is extremely important.

=================================================================================

🧪 Next Lab — Prove Authentication ≠ Authorization

I recommend we do one small experiment before S3.

We'll make the role perform an AWS API operation that requires permission.

For example:

aws s3 ls

Currently the role has no S3 permission.

So we expect:

OIDC authentication      ✅
STS credential exchange  ✅
AWS API authorization    ❌

That failure is good for the lab.

Then we'll add a narrowly scoped S3 permission and run the exact same command again:

OIDC authentication      ✅
STS credential exchange  ✅
S3 authorization         ✅
S3 API call              ✅

That will make the difference between authentication, trust, and authorization very concrete.

After that, we'll connect this directly to Terraform, because that's where your original question comes full circle:

GitHub CI
   ↓
OIDC
   ↓
STS
   ↓
Temporary credentials
   ↓
Terraform
   ↓
AWS APIs

And importantly, Terraform will not need AWS access keys stored in GitHub Secrets.

🧪 Lab 4 — Authentication vs Authorization

We already proved:

OIDC authentication       ✅
IAM trust policy          ✅
STS temporary credentials ✅

Now we'll deliberately test:

AWS API authorization     ?
Step 1 — Add an S3 API call

In create-report, immediately after:

- name: Verify AWS STS Identity
  run: |
    aws sts get-caller-identity

add:

      - name: Test S3 Authorization
        run: |
          aws s3 ls

So the sequence becomes:

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6.2.3
        with:
          role-to-assume: arn:aws:iam::587748224379:role/GitHubActions-OIDC-Role
          aws-region: us-east-1

      - name: Verify AWS STS Identity
        run: |
          aws sts get-caller-identity

      - name: Test S3 Authorization
        run: |
          aws s3 ls

Push it:

git add .github/workflows/first-ci.yml
git commit -m "Lab: test AWS authorization"
git push origin main
What we expect

Configure AWS Credentials:

✅

aws sts get-caller-identity:

✅

Then:

Test S3 Authorization
        ↓
     ❌ AccessDenied

That is the desired result for this experiment.

Why?

Your role currently has the correct trust policy, but it doesn't have permission to list S3 buckets.

So we'll have demonstrated:

                 Authentication
                      ↓
GitHub ────────→ AWS STS
                      ↓
                 Trusted Role
                      ↓
              Temporary Credentials
                      ↓
                 S3 API request
                      ↓
                  IAM Policy
                      ↓
                  ❌ DENIED

This is an extremely important distinction:

Successfully authenticating to AWS does not mean you are authorized to perform every AWS operation.

This is the expected result. We have now proved the second half of the security model.

Your error says:

AccessDenied

and specifically:

s3:ListAllMyBuckets

is not authorized.

What just happened

Look at the sequence:

GitHub OIDC
    ↓
IAM Trust Policy          ✅
    ↓
STS AssumeRole            ✅
    ↓
Temporary credentials     ✅
    ↓
aws sts get-caller-identity  ✅
    ↓
aws s3 ls
    ↓
IAM permissions policy    ❌
    ↓
AccessDenied

This is exactly what we wanted to demonstrate.

Authentication succeeded

AWS accepted the GitHub identity and gave us:

arn:aws:sts::587748224379:assumed-role/GitHubActions-OIDC-Role/GitHubActions

So:

Who are you? → GitHubActions-OIDC-Role

Authorization failed

Then S3 asked:

"Is this role allowed to perform s3:ListAllMyBuckets?"

AWS answered:

No.

Because the role currently has no identity-based policy allowing that action.

Now let's fix authorization

We'll add the minimum permission required for this exact test.

Go to:

IAM → Roles → GitHubActions-OIDC-Role → Permissions

Choose:

Add permissions → Create inline policy

Select the JSON editor.

Use:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "*"
    }
  ]
}

Name the policy:

GitHubActions-S3-List-Test
Why Resource: "*" here?

For this particular API operation, s3:ListAllMyBuckets is not scoped to an individual bucket ARN in the same way that object operations can be. We're intentionally granting only the single action needed for this experiment.

So we're still following least privilege:

Not:
AdministratorAccess ❌

Not:
AmazonS3FullAccess ❌

But:
s3:ListAllMyBuckets ✅
Then rerun the same workflow

We don't need to change the GitHub workflow.

The exact same command:

aws s3 ls

should now succeed.

If you have S3 buckets, you'll see something like:

2026-xx-xx  bucket-one
2026-xx-xx  bucket-two

If you have no S3 buckets, the command can succeed with no bucket output. That's also fine.

The important thing is:

Process completed with exit code 0
⭐ This completes the IAM mental model

We now have:

                  GitHub
                    │
                    │ OIDC JWT
                    ▼
             AWS OIDC Provider
                    │
                    ▼
              Trust Policy
                    │
              "WHO can enter?"
                    │
                    ▼
                   STS
                    │
          Temporary credentials
                    │
                    ▼
              IAM Role
                    │
          "WHAT can it do?"
                    │
                    ▼
                S3 API

And we've experimentally demonstrated both cases:

Trust failure

Would look like:

AssumeRoleWithWebIdentity
        ↓
AccessDenied
Permission failure

What we just got:

AssumeRoleWithWebIdentity   ✅
Temporary credentials       ✅
s3:ListAllMyBuckets         ❌

That's a very important distinction for troubleshooting AWS CI/CD.

After the second run succeeds

Then we'll take the next step:

GitHub Actions → OIDC → STS → Terraform

We'll use the exact same temporary credentials to let Terraform authenticate to AWS.

That will connect everything you've learned:

GitHub Actions
      ↓
OIDC
      ↓
STS
      ↓
Temporary credentials
      ↓
Terraform
      ↓
AWS API

And no AWS access key/secret will be stored in GitHub Secrets.

✅ The authorization test succeeded.

Your workflow now proves the complete chain:

GitHub Actions
     │
     │ OIDC JWT
     ▼
AWS OIDC Provider
     │
     ▼
IAM Trust Policy
     │
     ▼
STS
     │
     ▼
Temporary Credentials
     │
     ▼
IAM Permissions
     │
     ▼
S3 API
     │
     ▼
aws s3 ls
     │
     ▼
om-devops-lab-2026 ✅

The important thing is that the exact same workflow first failed with AccessDenied, then succeeded after we added the S3 permission.

That gives you a very clean mental model:

Layer	What happened
GitHub OIDC	Identity token generated ✅
AWS OIDC Provider	Token issuer recognized ✅
IAM Trust Policy	aud + sub matched ✅
STS	Temporary credentials issued ✅
get-caller-identity	Correct assumed role confirmed ✅
IAM Permissions	s3:ListAllMyBuckets allowed ✅
S3 API	aws s3 ls succeeded ✅
The key lesson

Trust policy and permissions policy are completely different.

Trust Policy
     ↓
"Can this identity assume my role?"

Permissions Policy
     ↓
"Once inside the role, what can it do?"

We actually demonstrated both experimentally rather than just reading about them.

One small cleanup before Terraform

We still have the temporary OIDC diagnostic step:

- name: Inspect OIDC Claims

We don't need it anymore. We already captured:

iss = https://token.actions.githubusercontent.com
aud = sts.amazonaws.com
sub = repo:Xprakasho/DevOps_Automation:ref:refs/heads/main

So remove the diagnostic step from the permanent CI.

Keep:

permissions:
  id-token: write
  contents: read

and:

- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v6.2.3
  with:
    role-to-assume: arn:aws:iam::587748224379:role/GitHubActions-OIDC-Role
    aws-region: us-east-1

=====================================================================================================================================

GitHub Actions → OIDC → STS → Terraform

Lab 5A — Minimal Terraform + OIDC

Let's first prove:

GitHub OIDC
    ↓
STS
    ↓
Temporary credentials
    ↓
Terraform AWS Provider
    ↓
AWS API
Create the directory

From:

~/aws-terraform-learning/labs/terraform-aws-iam-authentication

run:

mkdir oidc-test
cd oidc-test

Then create:

nano provider.tf

with:

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

Then:

nano main.tf

with:

data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_caller_arn" {
  value = data.aws_caller_identity.current.arn
}
What this Terraform does

It doesn't create anything.

It simply asks AWS:

"Who am I?"

Conceptually:

Terraform
   │
   │ AWS Provider
   ▼
AWS STS
   │
   ▼
GetCallerIdentity
   │
   ▼
Account ID
Role ARN

This is almost the Terraform equivalent of what we already tested:

aws sts get-caller-identity

That's perfect for our first test.

Then locally

Run:

terraform init

then:

terraform plan

But local execution and GitHub execution are different authentication environments.

The important test will be in GitHub Actions.

GitHub Actions

Our workflow will eventually contain:

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6.2.3
        with:
          role-to-assume: arn:aws:iam::587748224379:role/GitHubActions-OIDC-Role
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        working-directory: labs/terraform-aws-iam-authentication/oidc-test
        run: terraform init

      - name: Terraform Plan
        working-directory: labs/terraform-aws-iam-authentication/oidc-test
        run: terraform plan

And this should work without adding any AWS access keys or secrets.

This is the clean learning progression

We are going to build it in layers:

Already completed
1. GitHub Secret
        ↓
2. Secret injection
        ↓
3. Secret scope
        ↓
4. OIDC JWT
        ↓
5. IAM OIDC Provider
        ↓
6. IAM Trust Policy
        ↓
7. STS
        ↓
8. Temporary credentials
        ↓
9. AWS CLI
        ↓
10. IAM authorization
Now
11. Terraform + temporary credentials

Then:

12. Terraform plan
13. Terraform permissions
14. Terraform apply
15. Remote Terraform state
16. CI/CD Terraform architecture

=======================================================================================================================

this is actually better and simpler. Your GitHub repository already has the Terraform OIDC lab at:

DevOps_Automation/
└── oidc/
    ├── main.tf
    └── provider.tf

And you've already run terraform init and terraform plan there successfully.

So do not use:

working-directory: labs/terraform-aws-iam-authentication/oidc-test

That was based on your separate Terraform-learning repository.

Use this in first-ci.yml
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        working-directory: oidc
        run: terraform init

      - name: Terraform Plan
        working-directory: oidc
        run: terraform plan

Your AWS authentication + Terraform section should now be:

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v6.2.3
        with:
          role-to-assume: arn:aws:iam::587748224379:role/GitHubActions-OIDC-Role
          aws-region: us-east-1

      - name: Verify AWS STS Identity
        run: |
          aws sts get-caller-identity

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        working-directory: oidc
        run: terraform init

      - name: Terraform Plan
        working-directory: oidc
        run: terraform plan
What we are proving

This is now a very clean lab:

GitHub Actions
      │
      │ OIDC
      ▼
AWS IAM OIDC Provider
      │
      │ Trust Policy
      ▼
GitHubActions-OIDC-Role
      │
      │ STS temporary credentials
      ▼
AWS
      │
      ▼
Terraform
      │
      ├── terraform init
      │
      └── terraform plan

And importantly, no AWS access key or secret access key is stored in GitHub Secrets.

One thing to verify

Before pushing the workflow, from:

~/DevOps_Automation

run:

git status

and:

git ls-files oidc/

We want to see:

oidc/main.tf
oidc/provider.tf

GitHub rejected the push because your Terraform provider binary was accidentally included in the repository:

labs/oidc/.terraform/providers/...
terraform-provider-aws_v6.58.0_x5 is 850.22 MB

GitHub's normal file limit is 100 MB.

Why this happened

When you ran:

terraform init

Terraform downloaded the AWS provider into:

oidc/.terraform/

That directory is local Terraform working data and should never be committed to Git.

We want:

oidc/
├── main.tf
├── provider.tf
└── .terraform.lock.hcl    ← keep this

But not:

oidc/.terraform/
Step 1 — Go to repository root

You're currently in:

~/DevOps_Automation/DevOps_Automation/labs

Run:

cd ..
pwd

You should be at:

/home/om/DevOps_Automation/DevOps_Automation
Step 2 — Add Terraform files to .gitignore

Run:

cat >> .gitignore <<'EOF'

# Terraform
**/.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log
EOF

This is an important engineering practice.

We do not ignore:

*.tf
.terraform.lock.hcl

Those should normally be version controlled.

Step 3 — Remove the downloaded provider from Git tracking

Because it is already inside your local commit, simply adding .gitignore isn't enough.

Run:

git rm -r --cached labs/oidc/.terraform

If it says something like:

rm 'labs/oidc/.terraform/...'

that's exactly what we want.

Then check:

git status
Step 4 — Make sure .terraform is really ignored

Run:

git status --ignored labs/oidc

You should see .terraform under ignored files.

You can also check:

git check-ignore -v labs/oidc/.terraform

It should point to your .gitignore rule.

Step 5 — Amend the existing commit

Your previous commit:

09cef83 Add Terraform OIDC CI lab

has not reached GitHub, because the push was rejected.

So we can safely fix that commit:

git add .gitignore
git add labs/oidc/
git commit --amend --no-edit

This replaces the bad local commit with a clean one.

Step 6 — Verify before pushing

Run:

git status

Then:

git ls-files labs/oidc

We want something similar to:

labs/oidc/main.tf
labs/oidc/provider.tf
labs/oidc/.terraform.lock.hcl

There should be no labs/oidc/.terraform/... entries.

Then:

git log --oneline -2
Step 7 — Push again

Now:

git push origin main

This time the 850 MB provider binary should not be sent.

Important lesson for our Terraform + CI learning

This is actually a very useful real-world issue to encounter.

Terraform has two different categories:

Terraform source/configuration
        │
        ├── main.tf                 ✅ Git
        ├── provider.tf             ✅ Git
        ├── variables.tf            ✅ Git
        └── .terraform.lock.hcl     ✅ Git
           
Terraform local working data
        │
        ├── .terraform/             ❌ Git
        ├── provider binaries        ❌ Git
        └── state files              ❌ normally Git

And this is exactly why .gitignore is part of professional Terraform repository hygiene.

Don't delete anything manually yet. Follow Steps 1–4 and show me the output of:

git status

1. The huge Terraform provider is now staged for deletion

You have:

deleted: labs/oidc/.terraform/.../terraform-provider-aws_v6.58.0_x5

Good. We don't want that binary in Git.

2. .gitignore is modified but not staged yet

You have:

modified: .gitignore

So now we just need to stage .gitignore and amend the existing commit.

Run these commands from your current repository root:

git add .gitignore

Then:

git status

You should see .gitignore under Changes to be committed, together with the deleted .terraform files.

Then run:

git commit --amend --no-edit

This is safe here because the previous commit was never successfully pushed to GitHub.

After that:

git status

Then verify that .terraform is no longer tracked:

git ls-files labs/oidc/.terraform

Expected result: nothing.

Finally:

git push origin main
One important point

Do not run terraform init again before the push. It is fine for .terraform to exist locally; .gitignore will prevent it from being committed.

Your local directory can remain:

labs/oidc/
├── main.tf
├── provider.tf
├── .terraform.lock.hcl
└── .terraform/          ← local only, ignored

That's the professional Terraform pattern we want.

Now we can see why the previous fix didn't solve it.

The key clue is this:

Writing objects: 100% (19/19), 174.63 MiB

and GitHub still sees:

labs/oidc/.terraform/.../terraform-provider-aws_v6.58.0_x5
850.22 MB
What happened

We removed .terraform from the latest commit, but the 850 MB provider is still inside the local commit history.

So Git is still trying to push that old commit/blob.

The cleanest solution is actually very simple because the bad commit was never pushed to GitHub.

We will throw away that local commit and recreate it cleanly.

Step 1 — Reset local main to GitHub's main

From your repository root:

cd ~/DevOps_Automation/DevOps_Automation

Run:

git reset --mixed origin/main

This means:

"Forget my local commit, but keep the actual file changes in my working directory."

Do not use --hard.

Step 2 — Check status
git status

You should see something similar to:

modified: .gitignore
untracked: labs/oidc/

You should NOT see:

labs/oidc/.terraform/...

because .terraform is now ignored.

Step 3 — Confirm the huge provider is ignored

Run:

git check-ignore -v labs/oidc/.terraform/providers/registry.terraform.io/hashicorp/aws/6.58.0/linux_amd64/terraform-provider-aws_v6.58.0_x5

You should get output pointing to .gitignore, something like:

.gitignore:...:**/.terraform/ ...

That confirms Git will not track it.

Step 4 — Add only the correct Terraform files

Run:

git add .gitignore
git add labs/oidc/main.tf
git add labs/oidc/provider.tf
git add labs/oidc/.terraform.lock.hcl

Then:

git status

We want to see:

Changes to be committed:

    modified:   .gitignore
    new file:   labs/oidc/main.tf
    new file:   labs/oidc/provider.tf
    new file:   labs/oidc/.terraform.lock.hcl

There must be NO .terraform/ file in the staged list.

Step 5 — Create a clean commit
git commit -m "Add Terraform OIDC CI lab"

Then:

git log --oneline -3

You should now have something like:

xxxxx Add Terraform OIDC CI lab
476db92 CI Test for S3 Permission Policy
543c8c5 Lab: test AWS authorization

The important difference is that the old 09cef83 commit should no longer be the current HEAD.

Step 6 — Push

Now:

git push origin main

This time the upload should be small.

You should NOT see:

Writing objects: ... 174.63 MiB

Instead, it should be relatively small because we're only pushing:

.gitignore
oidc/main.tf
oidc/provider.tf
oidc/.terraform.lock.hcl
first-ci.yml
Why this works

Before:

origin/main
    │
    ▼
old commit
    │
    └── 850 MB Terraform provider ❌

Even though we deleted the provider in a later commit:

old commit
    │
    ▼
new commit
    │
    └── provider deleted

Git still had to send the old commit and its blob to GitHub.

Now we're doing:

origin/main
    │
    ▼
new clean commit
    │
    ├── first-ci.yml
    ├── .gitignore
    └── oidc/
         ├── main.tf
         ├── provider.tf
         └── .terraform.lock.hcl

No 850 MB provider exists in the history we're pushing.

One important Terraform lesson

Your local directory can still have:

labs/oidc/
├── .terraform/              ← 850 MB provider, LOCAL ONLY
├── .terraform.lock.hcl      ← COMMIT
├── main.tf                  ← COMMIT
└── provider.tf              ← COMMIT

That is exactly correct.

.terraform/ stays on your machine so Terraform can work, but Git ignores it.

What we have successfully built
GitHub Push
    │
    ▼
GitHub Actions Runner
    │
    ▼
GitHub OIDC Token
    │
    ▼
AWS IAM OIDC Provider
    │
    ▼
GitHubActions-OIDC-Role
    │
    ▼
AWS STS
    │
    ▼
Temporary AWS Credentials
    │
    ├── aws sts get-caller-identity       ✅
    │
    ├── Terraform init                    ✅
    │
    ├── Terraform plan                    ✅
    │
    └── aws s3 ls                         ✅

The strongest proof is your Terraform output:

aws_account_id = "587748224379"

aws_caller_arn =
arn:aws:sts::587748224379:assumed-role/
GitHubActions-OIDC-Role/GitHubActions

That proves Terraform itself is operating through the assumed GitHub Actions IAM role, not through your local AWS credentials.

And your S3 test successfully returned:

om-devops-lab-2026

So the role's permissions are also working.

One important learning point

We have now separated the responsibilities correctly:

Terraform

Terraform Init
      ↓
Terraform Plan
      ↓
Read AWS identity

AWS CLI

aws sts get-caller-identity
aws s3 ls

Both are using the same temporary STS credentials established by:

- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v6.2.3

So this is no longer just an OIDC demonstration. We have a real foundation for GitHub Actions → AWS → Terraform.

What I recommend next

Don't add more complexity immediately.

First, let's make this lab production-style and reusable:

Clean the workflow slightly.
Keep OIDC + STS.
Keep Terraform init.
Keep Terraform plan.
Remove unnecessary debugging code.
Add terraform fmt -check and terraform validate.
Then introduce Terraform Apply through GitHub Actions.
Finally, move toward the architecture:
GitHub
  │
  ├── CI: fmt + validate + plan
  │
  └── CD: approved apply
          │
          ▼
     AWS OIDC/STS
          │
          ▼
       Terraform
          │
          ▼
       AWS Infra

===============================================================================================================
