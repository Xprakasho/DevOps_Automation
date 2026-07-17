
# GitHub Actions Fundamentals

## Objective

Understand the core concepts of Continuous Integration (CI) and GitHub Actions. Learn how workflows are triggered, executed, and monitored before moving to advanced topics.

---

# 1. What is Continuous Integration (CI)?

Continuous Integration (CI) is the practice of automatically building, validating, and testing code whenever developers push or merge changes into a shared repository.

Instead of manually executing repetitive tasks, CI automatically performs them whenever code changes occur.

## Benefits

- Early detection of bugs
- Automated testing
- Consistent build environment
- Faster developer feedback
- Improved software quality
- Reduced manual effort

---

# 2. Continuous Delivery vs Continuous Deployment

## Continuous Delivery

The application is automatically built and tested, then prepared for deployment. Deployment still requires manual approval.

```
Build
    ↓
Test
    ↓
Ready for Deployment
```

---

## Continuous Deployment

The application is automatically built, tested, and deployed without manual intervention.

```
Build
    ↓
Test
    ↓
Deploy Automatically
```

---

# 3. What is GitHub Actions?

GitHub Actions is GitHub's built-in CI/CD platform that automates software workflows using YAML files.

A workflow can automatically:

- Build applications
- Execute scripts
- Run tests
- Validate Kubernetes manifests
- Build Docker images
- Execute Terraform
- Deploy applications

---

# 4. GitHub Actions Architecture

```
Developer
    │
git push
    │
    ▼
GitHub Repository
    │
Event (Push / PR / Schedule)
    │
    ▼
Workflow
    │
    ▼
Job
    │
    ▼
Runner
    │
    ▼
Steps
    │
    ▼
Result
```

---

# 5. GitHub Actions Components

## Workflow

A workflow is the complete automation process.

Example:

```
CI Pipeline
```

Workflow files are stored inside:

```
.github/workflows/
```

---

## Event

Events trigger workflows.

Examples:

- push
- pull_request
- workflow_dispatch
- schedule

---

## Job

A workflow consists of one or more jobs.

Example:

```
Build

Test

Deploy
```

Jobs execute independently unless dependencies are defined.

---

## Step

Each job contains multiple steps.

Example:

```
Checkout Repository

Setup Python

Run Bash Script

Run Tests
```

Steps execute sequentially inside the same job.

---

## Runner

A Runner is the machine that executes workflow jobs.

Types:

- GitHub-hosted Runner
- Self-hosted Runner

We used:

```
runs-on: ubuntu-latest
```

GitHub automatically provisioned an Ubuntu Virtual Machine.

---

# 6. Workflow Execution Flow

```
git push
      │
      ▼
GitHub detects event
      │
      ▼
Runner Starts
      │
      ▼
Checkout Repository
      │
      ▼
Execute Workflow Steps
      │
      ▼
Cleanup
      │
      ▼
Workflow Complete
```

---

# 7. GitHub-hosted Runner

Characteristics:

- Temporary Virtual Machine
- Clean Environment
- Automatically Provisioned
- Automatically Destroyed After Workflow Completion

Advantages:

- No infrastructure maintenance
- Consistent execution
- Fast setup

---

# 8. Workflow File Location

```
.github/workflows/
```

Example:

```
.github/workflows/first-ci.yml
```

---

# 9. run vs uses

## run

Executes shell commands on the runner.

Example:

```yaml
run: python scripts/python/info.py
```

---

## uses

Uses an existing GitHub Action.

Example:

```yaml
uses: actions/checkout@v4
```

Common Actions:

- actions/checkout
- actions/setup-python
- docker/login-action
- upload-artifact

---

# 10. actions/checkout

Purpose:

Downloads (checks out) the repository into the runner.

Without checkout:

```
Repository files do not exist.

Scripts cannot execute.
```

---

# 11. actions/setup-python

Purpose:

Installs Python on the GitHub-hosted runner.

Example:

```yaml
uses: actions/setup-python@v5

with:
    python-version: "3.10"
```

---

# 12. Understanding Workflow Logs

Every workflow contains detailed logs.

Example:

```
Setup Job

Checkout Repository

Run Bash Script

Run Python Script

Complete Job
```

Expanding a step displays:

- Executed command
- Standard Output
- Errors
- Execution Time

Logs are the primary debugging tool in CI/CD.

---

# 13. Local Machine vs GitHub Runner

| Local Machine | GitHub Runner |
|---------------|---------------|
| User: om | User: runner |
| Hostname: C-5CG4400Z7Y | Temporary VM |
| IST Time | UTC Time |
| Local Python | Installed by setup-python |

A CI pipeline should never depend on the developer's local machine.

---

# 14. Best Practices

- Use meaningful workflow names.
- Use descriptive step names.
- Pin action versions.
- Never hardcode secrets.
- Keep workflows small and readable.
- Read workflow logs for debugging.

---

# Key Takeaways

✔ CI automates validation after code changes.

✔ GitHub Actions is an event-driven automation platform.

✔ Workflows consist of Jobs.

✔ Jobs consist of Steps.

✔ Steps execute on a Runner.

✔ `run` executes commands.

✔ `uses` invokes reusable GitHub Actions.

✔ Workflow logs are essential for troubleshooting.
