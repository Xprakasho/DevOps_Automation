
# GitHub Actions Cheatsheet

> **Purpose:** A quick reference guide for GitHub Actions syntax, commonly used components, and best practices.

---

# 1. Workflow File Location

All workflow files must be stored in:

```text
.github/workflows/
```

Example:

```text
.github/workflows/first-ci.yml
```

---

# 2. Basic Workflow Structure

```yaml
name: First CI Pipeline

on:
  push:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - run: echo "Hello GitHub Actions"
```

---

# 3. Workflow Components

```
Workflow
    │
    ├── Event
    │
    ├── Job(s)
    │
    ├── Runner
    │
    └── Step(s)
```

---

# 4. Common Events

| Event | Description |
|--------|-------------|
| push | Trigger when code is pushed |
| pull_request | Trigger on Pull Request |
| workflow_dispatch | Manual execution |
| schedule | Run on a schedule (Cron) |
| release | Trigger on Release creation |

Example:

```yaml
on:
  push:
```

---

# 5. Common Runners

```yaml
runs-on: ubuntu-latest
```

Other options:

```yaml
runs-on: windows-latest

runs-on: macos-latest

runs-on: self-hosted
```

---

# 6. Common GitHub Actions

Checkout Repository

```yaml
uses: actions/checkout@v4
```

---

Setup Python

```yaml
uses: actions/setup-python@v5

with:
  python-version: "3.10"
```

---

# 7. run vs uses

## run

Execute shell commands.

```yaml
run: python app.py
```

---

## uses

Execute a reusable GitHub Action.

```yaml
uses: actions/checkout@v4
```

---

# 8. Common Shell Commands

Display Current Directory

```bash
pwd
```

---

Display Files

```bash
ls -l
```

---

Display Hostname

```bash
hostname
```

---

Display Date

```bash
date
```

---

Display OS Information

```bash
uname -a
```

---

Display Disk Usage

```bash
df -h
```

---

# 9. Frequently Used GitHub Context

| Context | Description |
|---------|-------------|
| github.repository | Repository Name |
| github.actor | User triggering workflow |
| github.ref_name | Branch Name |
| github.workflow | Workflow Name |
| github.sha | Commit SHA |
| github.event_name | Trigger Event |

Example:

```yaml
run: echo "${{ github.repository }}"
```

---

# 10. Useful Environment Variables

| Variable | Description |
|-----------|-------------|
| GITHUB_REPOSITORY | Repository Name |
| GITHUB_REF_NAME | Branch |
| GITHUB_WORKSPACE | Workspace Directory |
| GITHUB_SHA | Commit ID |

Example:

```bash
echo $GITHUB_REPOSITORY
```

---

# 11. Workflow Execution Flow

```
Developer
    │
git push
    │
    ▼
GitHub Event
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
Completed
```

---

# 12. Workflow Commands

Commit Changes

```bash
git add .

git commit -m "ci: update workflow"

git push origin main
```

Open:

```
GitHub

↓

Actions

↓

Workflow

↓

Logs
```

---

# 13. Common Workflow Errors

| Error | Possible Cause |
|--------|----------------|
| Workflow not triggered | Incorrect workflow location |
| Permission denied | Script not executable |
| Python not found | setup-python missing |
| File not found | checkout missing |
| YAML syntax error | Incorrect indentation |

---

# 14. Best Practices

✅ Use descriptive workflow names.

✅ Use descriptive step names.

✅ Pin action versions (`@v4`, `@v5`).

✅ Keep workflows modular.

✅ Read logs for debugging.

✅ Never hardcode secrets.

✅ Validate workflows after every change.

---

# 15. Quick Interview Revision

Workflow = Complete automation

Job = Collection of steps

Step = Single task

Runner = Machine executing jobs

Event = Trigger for workflow

run = Execute shell commands

uses = Use reusable GitHub Action

checkout = Download repository

setup-python = Install Python

---

# 16. Common Interview Questions

✔ What is CI?

✔ What is GitHub Actions?

✔ What is a Workflow?

✔ What is a Runner?

✔ Difference between Job and Step?

✔ Difference between run and uses?

✔ Why do we need checkout?

✔ What triggers a workflow?

✔ What is a GitHub-hosted runner?

✔ How do you debug a failed workflow?

---

# 17. Module Progress

| Module | Status |
|----------|--------|
| Fundamentals | ✅ |
| Variables & Context | ⏳ |
| Expressions | ⏳ |
| Jobs & Dependencies | ⏳ |
| Matrix Strategy | ⏳ |
| Artifacts | ⏳ |
| Caching | ⏳ |
| Secrets | ⏳ |
| Reusable Workflows | ⏳ |
| Self-hosted Runners | ⏳ |

---

# Key Commands at a Glance

```yaml
uses: actions/checkout@v4

uses: actions/setup-python@v5

runs-on: ubuntu-latest

run: echo "Hello"

on:
  push:
```

---

# Remember

**Workflow → Job → Runner → Step**

Everything in GitHub Actions follows this execution hierarchy.
