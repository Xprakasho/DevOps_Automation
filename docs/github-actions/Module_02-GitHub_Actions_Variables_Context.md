
Learning Objectives

After completing this module, you should be able to:

Explain Workflow, Job, and Step hierarchy.
Use Workflow-level environment variables.
Understand variable scope and precedence.
Use GitHub Context.
Differentiate ${{ }} from $VAR.
Build a clean production-style CI pipeline.
Explain workflow execution order.
Troubleshoot GitHub Actions logs.
1. GitHub Actions Execution Flow
Developer
    │
git push
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions Service
    │
Reads Workflow YAML
Evaluates Expressions
    │
    ▼
Allocate Runner
    │
    ▼
Set up Job
    │
    ▼
Checkout Repository
    │
    ▼
Run Steps
    │
    ▼
Job Complete
2. GitHub Actions Hierarchy
Workflow
│
└── Job
     │
     ├── Step
     ├── Step
     └── Step

Example

name: First CI Pipeline      # Workflow

jobs:
  validate:                  # Job

    steps:
      - name: Checkout       # Step
      - name: Run Bash
      - name: Run Python
3. Variable Scope
Workflow
      │
      ▼
Job
      │
      ▼
Step

Nearest scope always wins.

Example

Workflow

env:
  APP_NAME: DevOps_Automation

Job

env:
  APP_NAME: Job-App

Step

env:
  APP_NAME: Step-App

Output

Step-App
4. Variable Precedence

Priority

Step Env
      ↓
Job Env
      ↓
Workflow Env

Rule

GitHub always searches from the nearest scope outward.

5. Workflow Variables

Current production workflow

env:
  APP_NAME: DevOps_Automation
  APP_ENV: Development
  PYTHON_VERSION: "3.10"

Advantages

Single source of truth
Easy maintenance
Less duplication
Cleaner workflow
6. GitHub Context

Examples

${{ github.repository }}

${{ github.ref_name }}

${{ github.actor }}

${{ github.sha }}

${{ github.workflow }}

${{ github.run_number }}

GitHub Context is evaluated by GitHub before the runner starts.

7. Environment Variables

Example

echo "$APP_NAME"

Expanded by:

Bash Shell

NOT by GitHub.

8. ${{ }} vs $VAR
GitHub Expression	Shell Variable
${{ github.actor }}	$USER
${{ env.APP_NAME }}	$APP_NAME
Evaluation Timing

GitHub

${{ env.PYTHON_VERSION }}

↓

Runner starts

↓

Bash

echo $APP_NAME

Important:

GitHub evaluates expressions before execution.

Bash expands variables during execution.

9. Repository Metadata

Production pipeline prints

Repository

Branch

Commit SHA

Triggered By

Workflow

Run Number

Runner OS

Application

Environment

Purpose

Easier troubleshooting
Better logging
Self-documenting pipeline
10. Workflow Structure

Current CI

Checkout Repository

↓

Repository Information

↓

Bash Validation

↓

Python Validation

Simple.

Readable.

Maintainable.

11. Runner Execution

GitHub automatically creates

Set up job

This step

prepares VM
creates workspace
sets environment
prepares authentication
downloads workflow

before your first step runs.

12. Production CI (Version 2.0)

Current workflow

push

↓

workflow_dispatch

↓

Checkout

↓

Repository Metadata

↓

Bash Validation

↓

Python Validation
Best Practices

✅ Use descriptive job names

validate

build

test

deploy

NOT

first-job

second-job

✅ Use workflow variables for common configuration.

✅ Avoid hardcoding.

Bad

python-version: "3.10"

Good

python-version: ${{ env.PYTHON_VERSION }}

✅ Print useful metadata.

✅ Avoid duplicate information.

Don't print the same metadata again in a summary if it already appears at the start of the logs.

Common Mistakes

❌ Hardcoded versions

❌ Duplicate variables

❌ Using $VAR inside if:

Incorrect

if: $APP_NAME == "DevOps"

Correct

if: ${{ env.APP_NAME == 'DevOps' }}

❌ Using ${{ }} inside Bash when not needed

Bad

echo "${{ env.APP_NAME }}"

Good

echo "$APP_NAME"
