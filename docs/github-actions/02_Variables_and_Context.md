
Module 02 – Variables and Context
1. Introduction

Variables are one of the most fundamental concepts in GitHub Actions. They allow workflows to become reusable, maintainable, and dynamic instead of relying on hardcoded values.

GitHub Actions provides multiple ways to work with values:

Environment Variables
GitHub Context
Expressions
Built-in Variables
Repository Variables

Understanding who creates these values, when they become available, and who evaluates them is essential for writing production-quality workflows.

2. Learning Objectives

After completing this module, you should be able to:

Explain the purpose of variables.
Differentiate between Environment Variables and GitHub Context.
Understand Expressions (${{ }}).
Explain Variable Scope.
Use Built-in Variables.
Configure Repository Variables.
Decide which variable type is appropriate for different scenarios.
3. Variable Types
Type	Created By	Access Method	Typical Usage
Environment Variable	Developer	$APP_NAME or ${{ env.APP_NAME }}	Workflow configuration
GitHub Context	GitHub	${{ github.actor }}	Repository metadata
Built-in Variable	GitHub	$GITHUB_SHA	Shell scripts
Repository Variable	Developer (Repository Settings)	${{ vars.APP_NAME }}	Shared repository configuration
4. Environment Variables
Definition

Environment Variables are values defined by the developer inside a workflow.

Example

env:
  APP_NAME: Inventory-Service
  ENVIRONMENT: Dev

Advantages:

Reusable
Easy to modify
Cleaner workflows
Reduces duplication
5. GitHub Context

GitHub automatically creates contextual information whenever a workflow starts.

Examples

${{ github.actor }}

${{ github.repository }}

${{ github.sha }}

${{ github.ref_name }}

GitHub Context contains information that GitHub already knows before the runner starts.

Examples:

Repository
Branch
Commit
Workflow
Event
Actor
6. Expressions (${{ }})

Expression syntax:

${{ ... }}

GitHub evaluates expressions before the runner starts.

Example

run: echo "${{ github.actor }}"

GitHub replaces the expression with the actual value before sending commands to the runner.

7. Environment Variables vs Expressions

Environment Variable

$APP_NAME

Expanded by:

Linux Shell

Timing:

During command execution

Expression

${{ github.actor }}

Evaluated by:

GitHub

Timing:

Before the runner starts
8. Variable Scope

GitHub Actions supports three scopes.

Workflow Scope

env:

Accessible throughout the workflow.

Job Scope

jobs:
  build:
    env:

Accessible only within that job.

Step Scope

steps:
  - env:

Accessible only within that step.

Hierarchy

Step Scope
      ↑
Job Scope
      ↑
Workflow Scope

The nearest definition overrides broader scopes.

9. Built-in Variables

GitHub automatically creates built-in environment variables.

Common examples:

GITHUB_SHA
GITHUB_REF
GITHUB_REPOSITORY
GITHUB_ACTOR
GITHUB_WORKSPACE

Example

echo $GITHUB_SHA

These are expanded by the Linux shell during execution.

10. GitHub Context vs Built-in Variables
GitHub Context	Built-in Variable
${{ github.sha }}	$GITHUB_SHA
${{ github.actor }}	$GITHUB_ACTOR
${{ github.repository }}	$GITHUB_REPOSITORY

Both often represent the same information.

Difference:

GitHub Context → evaluated by GitHub.
Built-in Variables → expanded by the Linux shell.
11. Repository Variables

Repository Variables are stored outside the workflow.

Location

Repository

↓

Settings

↓

Secrets and variables

↓

Actions

↓

Variables

Example

APP_NAME = Inventory-Service

AWS_REGION = ap-south-1

Access

${{ vars.APP_NAME }}

These variables are shared across all workflows in the repository.

12. Repository Variables vs Environment Variables
Repository Variable	Environment Variable
Stored in GitHub Settings	Stored in YAML
Shared across workflows	Limited by scope
${{ vars.NAME }}	$NAME / ${{ env.NAME }}
13. Repository Variables vs GitHub Context

GitHub Context

${{ github.repository }}

Automatically generated.

Repository Variable

${{ vars.APP_NAME }}

Created and managed by the repository owner.

14. Complete Execution Flow
Developer
     │
     ▼
Git Push
     │
     ▼
GitHub Receives Event
     │
     ▼
Creates GitHub Context
     │
Creates Built-in Variables
     │
Evaluates Expressions (${{ }})
     │
Starts Runner
     │
Linux Expands Environment Variables ($VAR)
     │
Workflow Executes
15. Best Practices

✅ Use Environment Variables for workflow-specific configuration.

✅ Use Repository Variables for shared repository configuration.

✅ Use GitHub Context for repository metadata.

✅ Use Built-in Variables inside shell scripts.

✅ Avoid hardcoded values.

16. Common Mistakes

❌ Using $github.actor

❌ Using ${{ APP_NAME }}

❌ Expecting Repository Variables to automatically become shell variables.

❌ Using GITHUB_REF when only the branch name is required.

17. Golden Rules
GitHub evaluates Expressions.
Linux expands Environment Variables.
GitHub Context contains GitHub metadata.
Repository Variables store shared configuration.
Variable Scope determines accessibility.
The closest scope overrides the broader scope.
18. Module Summary

After this module you now understand:

Variables
Environment Variables
GitHub Context
Expressions
Variable Scope
Built-in Variables
Repository Variables
