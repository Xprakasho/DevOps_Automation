GitHub Internal Architecture

Imagine you click:

git push origin main

GitHub receives the push.

Step 1

GitHub detects:

Push Event
        │
        ▼
Workflow Triggered

At this point:

❌ No runner exists yet.

❌ No environment variables exist yet.

❌ No secret has been injected.

The secret is still safely stored inside GitHub.

Step 2

GitHub provisions a runner.

GitHub
      │
      ▼
Start Ubuntu Runner

Now the runner is booting.

Still...

No Bash script.

No Python.

Step 3 ⭐⭐⭐⭐⭐

This is the important part.

GitHub prepares the runner.

Repository Checked Out

↓

Environment Variables Prepared

↓

Secrets Injected

↓

Runner Ready

Now GitHub replaces

${{ secrets.USER_NAME }}

with the actual value.

Conceptually, it becomes:

export USER_NAME=Om

inside the runner environment.

Notice:

GitHub injects it.

You never write

export USER_NAME=Om

yourself.

Step 4

Now your Bash script starts.

echo "$USER_NAME"

The shell simply reads an environment variable.

It has no idea it originally came from GitHub Secrets.

To Bash it is just:

USER_NAME
Complete Flow
Git Push
     │
     ▼
GitHub Workflow
     │
     ▼
Create Runner
     │
     ▼
Inject Secrets
     │
     ▼
Create Environment Variables
     │
     ▼
Execute Bash
     │
     ▼
Execute Python

Now notice something beautiful.

Neither Bash nor Python knows anything about GitHub.

They simply receive environment variables.

Engineering Principle ⭐⭐⭐⭐⭐

This is why your scripts are portable.

Your Python code:

import os

print(os.getenv("USER_NAME"))

doesn't know whether the environment variable came from:

GitHub Actions
Jenkins
GitLab CI
Docker
Kubernetes
Linux
Azure DevOps

It simply reads:

Environment Variable

That's why we focused on principles instead of platforms.

This Is Why Environment Variables Became the Standard

Imagine every CI/CD platform had its own API.

Your script would have to contain:

if github:
    ...
elif gitlab:
    ...
elif jenkins:
    ...

That would be a nightmare.

Instead, everyone agreed on a universal interface:

Environment Variables

It's one of the oldest and most portable mechanisms in computing.

Security Flow
GitHub Secret Store
         │
Encrypted at Rest
         │
Workflow Starts
         │
Runner Created
         │
Secret Injected
         │
Environment Variable Created
         │
Bash / Python Uses It
         │
Runner Destroyed

Notice the last step.

When the job finishes:

Runner Destroyed

The environment variable disappears with it.

This is another security advantage of ephemeral runners.

=================================================================================================

Secret Scope in CI/CD

Engineering Principle #10 - Secrets are injected per job into the runner that requests them.

This is another principle I want you to remember.

Secrets should exist only where they are needed, and only for as long as they are needed.

Notice how this combines everything we've learned:

✅ Least Privilege
✅ Minimum Lifetime
✅ Temporary Runners
✅ Secret Injection
✅ Isolation

These aren't separate ideas—they reinforce each other.

⭐ Universal CI/CD Principle

Whether you're using:

GitHub Actions
GitLab CI
Jenkins
Azure DevOps
CircleCI

The recommended pattern is the same:

Smallest Permission

+

Smallest Secret Scope

+

Shortest Lifetime

This is platform-independent security architecture.
