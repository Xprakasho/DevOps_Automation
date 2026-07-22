
# GitHub Actions Interview Questions

> **Purpose:** These questions cover the fundamentals of GitHub Actions and Continuous Integration. The answers are written in an interview-friendly format—clear, concise, and technically accurate.

---

# Q1. What is Continuous Integration (CI)?

### Answer

Continuous Integration (CI) is a software development practice where code changes are automatically built, validated, and tested whenever developers push changes to a shared repository.

The primary goal of CI is to detect issues early, reduce integration problems, and improve software quality by automating repetitive tasks.

---

# Q2. What is the difference between CI and CD?

### Answer

| CI | CD |
|----|----|
| Automates build and testing | Automates deployment |
| Detects issues early | Delivers software faster |
| Triggered by code changes | Triggered after successful CI |

Continuous Delivery requires manual approval before deployment, whereas Continuous Deployment automatically deploys changes after all checks pass.

---

# Q3. What is GitHub Actions?

### Answer

GitHub Actions is GitHub's built-in CI/CD platform that allows developers to automate workflows directly within a GitHub repository using YAML configuration files.

It can automate tasks such as building applications, running tests, validating code, creating Docker images, and deploying applications.

---

# Q4. What is a Workflow?

### Answer

A Workflow is the complete automation process defined in a YAML file.

It contains one or more jobs that execute when a specified event occurs.

Workflow files are stored under:

```
.github/workflows/
```

---

# Q5. What is an Event?

### Answer

An Event is a trigger that starts a workflow.

Common events include:

- push
- pull_request
- workflow_dispatch
- schedule
- release

Example:

```yaml
on:
  push:
```

---

# Q6. What is a Job?

### Answer

A Job is a collection of related steps executed on the same runner.

A workflow may contain multiple jobs, and jobs can run sequentially or in parallel depending on dependencies.

---

# Q7. What is a Step?

### Answer

A Step is the smallest unit of execution within a job.

A step either executes shell commands using `run` or invokes a reusable GitHub Action using `uses`.

Steps execute sequentially within the same job.

---

# Q8. What is a Runner?

### Answer

A Runner is the machine that executes workflow jobs.

GitHub provides GitHub-hosted runners such as Ubuntu, Windows, and macOS.

Organizations can also configure self-hosted runners for custom environments.

---

# Q9. What is a GitHub-hosted Runner?

### Answer

A GitHub-hosted runner is a temporary virtual machine automatically provisioned by GitHub.

Characteristics:

- Clean environment
- Pre-installed tools
- Automatically created
- Automatically destroyed after workflow completion

---

# Q10. What is a Self-hosted Runner?

### Answer

A Self-hosted Runner is a machine managed by the organization instead of GitHub.

It is commonly used when:

- Internal network access is required
- Custom software is needed
- Specialized hardware is required
- Compliance policies prevent using cloud-hosted runners

---

# Q11. Difference between run and uses?

### Answer

`run`

- Executes shell commands.
- Used for Bash, PowerShell, or Python commands.

Example:

```yaml
run: python app.py
```

`uses`

- Executes reusable GitHub Actions.

Example:

```yaml
uses: actions/checkout@v4
```

---

# Q12. Why is actions/checkout required?

### Answer

The GitHub runner starts with an empty workspace.

`actions/checkout` downloads the repository so that workflow steps can access source code, scripts, and configuration files.

Without checkout, repository files are unavailable.

---

# Q13. Why is actions/setup-python required?

### Answer

It installs the required Python version on the runner.

This ensures consistent execution regardless of the runner's default environment.

---

# Q14. What happens after a git push?

### Answer

1. Developer pushes code.
2. GitHub detects the configured event.
3. Workflow starts.
4. Runner is provisioned.
5. Repository is checked out.
6. Workflow steps execute.
7. Logs are generated.
8. Runner is destroyed.
9. Workflow status is reported.

---

# Q15. What is the purpose of workflow logs?

### Answer

Workflow logs help monitor execution and troubleshoot failures.

They display:

- Executed commands
- Output
- Errors
- Execution time
- Exit status

---

# Q16. Where are workflow files stored?

### Answer

Workflow files are stored inside:

```
.github/workflows/
```

Each workflow is defined in a YAML file.

---

# Q17. Can a workflow contain multiple jobs?

### Answer

Yes.

A workflow can contain multiple jobs.

Jobs may execute in parallel or sequentially using dependencies (`needs`), which we'll learn in a later module.

---

# Q18. Why are descriptive step names important?

### Answer

Descriptive names improve readability and make debugging easier because logs clearly indicate which step succeeded or failed.

---

# Q19. What is YAML?

### Answer

YAML (YAML Ain't Markup Language) is a human-readable data serialization format.

GitHub Actions uses YAML to define workflows.

YAML relies on indentation rather than braces or brackets.

---

# Q20. What are the benefits of GitHub Actions?

### Answer

- Native GitHub integration
- Event-driven automation
- Large marketplace of reusable actions
- GitHub-hosted and self-hosted runners
- Easy workflow management
- Supports CI/CD pipelines

---

# Quick Revision

Workflow
→ Complete automation

Event
→ Trigger

Job
→ Collection of steps

Step
→ Single task

Runner
→ Machine executing jobs

run
→ Execute commands

uses
→ Reusable GitHub Action

checkout
→ Download repository

setup-python
→ Install Python

---

# Interview Tip

When explaining GitHub Actions, describe the execution flow:

```
Developer

↓

Git Push

↓

Event

↓

Workflow

↓

Job

↓

Runner

↓

Steps

↓

Result
```

This demonstrates both conceptual understanding and practical knowledge.
