
# Lab 01 - First CI Pipeline

## Objective

The objective of this lab is to build and execute the first GitHub Actions Continuous Integration (CI) pipeline.

By the end of this lab, you will be able to:

- Understand the basic structure of a GitHub Actions workflow.
- Create and execute a workflow using GitHub-hosted runners.
- Execute Bash and Python scripts from a workflow.
- Analyze workflow execution logs.
- Understand the difference between execution on a local machine and a GitHub-hosted runner.

---

# Lab Architecture

```
Developer
    │
    │ git push
    ▼
GitHub Repository
    │
    ▼
GitHub Actions
    │
    ▼
Workflow
    │
    ▼
GitHub Runner (Ubuntu VM)
    │
    ├── Checkout Repository
    ├── Run Bash Script
    ├── Run Python Script
    ▼
Workflow Result
```

---

# Prerequisites

Before starting this lab, ensure the following:

- Git installed
- GitHub account
- Repository created
- Basic knowledge of Git commands
- Basic knowledge of YAML syntax

Repository used in this lab:

```
DevOps_Automation
```

---

# Repository Structure

The repository structure should look similar to the following:

```text
DevOps_Automation/
│
├── .github/
│   └── workflows/
│       └── first-ci.yml
│
├── scripts/
│   ├── bash/
│   │   └── hello.sh
│   │
│   └── python/
│       └── info.py
│
├── docs/
│
└── labs/
```

---

# Step 1 - Create a Bash Script

Navigate to the Bash scripts directory.

```bash
mkdir -p scripts/bash
```

Create the script.

```bash
nano scripts/bash/hello.sh
```

Example content:

```bash
#!/bin/bash

echo "Hello from GitHub Actions"

echo "Repository: $GITHUB_REPOSITORY"
echo "Branch: $GITHUB_REF_NAME"
echo "User: $USER"
echo "Hostname: $(hostname)"
echo "Date: $(date)"
```

Make the script executable.

```bash
chmod +x scripts/bash/hello.sh
```

---

# Step 2 - Create a Python Script

Navigate to the Python directory.

```bash
mkdir -p scripts/python
```

Create the script.

```bash
nano scripts/python/info.py
```

Example:

```python
import platform
import datetime

print("Python Version:", platform.python_version())
print("Platform:", platform.system())
print("Machine:", platform.machine())
print("Time:", datetime.datetime.now())
```

---

# Step 3 - Create the Workflow

Navigate to:

```text
.github/workflows/
```

Create:

```
first-ci.yml
```

Workflow:

```yaml
name: First CI Pipeline

on:
  push:

jobs:
  first-job:
    runs-on: ubuntu-latest

    steps:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Display Repository Information
        run: |
          echo "Repository: ${{ github.repository }}"
          echo "Branch: ${{ github.ref_name }}"
          echo "Triggered By: ${{ github.actor }}"

      - name: Make Bash Script Executable
        run: chmod +x scripts/bash/hello.sh

      - name: Run Bash Script
        run: ./scripts/bash/hello.sh

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.10"

      - name: Run Python Script
        run: python scripts/python/info.py
```

---

# Step 4 - Commit the Changes

```bash
git add .

git commit -m "ci: add first GitHub Actions workflow"
```

---

# Step 5 - Push to GitHub

```bash
git push origin main
```

This push event automatically triggers the workflow.

---

# Step 6 - Verify Workflow Execution

Open your repository on GitHub.

Navigate to:

```
Actions
```

Select:

```
First CI Pipeline
```

Verify:

- Workflow completed successfully
- All steps executed
- Green check mark displayed

---

# Step 7 - Analyze Workflow Logs

Expand each workflow step.

Observe:

- Repository information
- Bash script output
- Python script output
- Execution time
- Runner details

Example output:

```
Repository:
Xprakasho/DevOps_Automation

Branch:
main

Triggered By:
Xprakasho
```

---

# Step 8 - Compare Local Machine vs GitHub Runner

| Local Machine | GitHub Runner |
|---------------|---------------|
| Your laptop | Temporary Ubuntu VM |
| Local user | runner |
| Local hostname | Random GitHub VM hostname |
| Local Python | Installed during workflow |
| Local timezone | UTC on runner |

Observation:

The workflow executes in a clean, temporary environment provided by GitHub. It does not use your local machine.

---

# Troubleshooting

### Workflow not triggered

Check:

- Workflow file is inside `.github/workflows/`
- YAML syntax is correct
- Changes were pushed to GitHub

---

### Bash script permission denied

Run:

```bash
chmod +x scripts/bash/hello.sh
```

---

### Python not found

Ensure the workflow includes:

```yaml
uses: actions/setup-python@v5
```

---

### Checkout failed

Ensure:

```yaml
uses: actions/checkout@v4
```

is included before accessing repository files.

---

# Learning Outcomes

After completing this lab, you should be able to:

- Explain the purpose of CI.
- Create a basic GitHub Actions workflow.
- Execute Bash and Python scripts in CI.
- Read workflow logs.
- Differentiate between local execution and GitHub-hosted runner execution.
- Understand the lifecycle of a workflow.

---

# Self-Assessment Quiz

1. What event triggered the workflow in this lab?

2. Why is `actions/checkout` required?

3. What is the purpose of `runs-on`?

4. What is the difference between `run` and `uses`?

5. Why does the workflow run on a temporary virtual machine?

6. Where are workflow files stored?

7. How can you debug a failed workflow?

---

# Challenge Exercise

Extend the workflow by adding a new step that displays:

- Operating System
- Current Working Directory
- Available Disk Space

Hint:

Use shell commands such as:

```bash
pwd
uname -a
df -h
```

Commit the changes and verify the new step executes successfully.

---

# Conclusion

In this lab, you successfully created and executed your first GitHub Actions CI pipeline. You learned how workflows are structured, how GitHub-hosted runners execute jobs, and how to inspect workflow logs for validation and troubleshooting.

This lab forms the foundation for all future GitHub Actions topics, including variables, expressions, artifacts, caching, secrets, reusable workflows, and deployment automation.
