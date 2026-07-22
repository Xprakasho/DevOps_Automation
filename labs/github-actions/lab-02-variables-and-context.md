
Lab 02 Outline
Objective

By the end of this lab, you will understand:

Workflow-level Environment Variables
Job-level Environment Variables
Step-level Environment Variables
GitHub Context
Built-in Variables
Repository Variables
Variable Scope
Variable Precedence
Expression Evaluation
Linux Shell Expansion
Lab Architecture
                 Git Push
                     │
                     ▼
               GitHub Actions
                     │
                     ▼
        Evaluate Expressions (${{ }})
                     │
                     ▼
            Start GitHub Runner
                     │
                     ▼
        Expand Environment Variables
                     │
                     ▼
              Execute Workflow
Repository Structure
.github/
└── workflows/
    └── lab-02-variables.yml
Part 1 – Create Repository Variables

Go to:

Repository
    ↓
Settings
    ↓
Secrets and variables
    ↓
Actions
    ↓
Variables

Create:

Name	Value
APP_NAME	DevOps_Automation
COMPANY	Engineering-Lab
REGION	ap-south-1
Part 2 – Create Workflow

We'll create one workflow that demonstrates:

Workflow Scope
env:
  APP_NAME: Workflow-App
Job Scope
jobs:
  demo:
    env:
      APP_NAME: Job-App
Step Scope
steps:
  - name: Step Scope
    env:
      APP_NAME: Step-App
GitHub Context

Print:

${{ github.actor }}
${{ github.repository }}
${{ github.ref_name }}
${{ github.sha }}
Built-in Variables

Print:

$GITHUB_ACTOR
$GITHUB_REPOSITORY
$GITHUB_REF
$GITHUB_SHA
$GITHUB_WORKSPACE
Repository Variables

Print:

${{ vars.APP_NAME }}
${{ vars.COMPANY }}
${{ vars.REGION }}
Environment Variables

Print:

$APP_NAME

at each scope to observe how the value changes.

Part 3 – Observe Variable Precedence

Expected behavior:

Workflow
Workflow-App

↓

Job
Job-App

↓

Step
Step-App

This demonstrates that:

Step Scope
      ↑
Job Scope
      ↑
Workflow Scope

The closest scope overrides the broader one.

Part 4 – Observe GitHub Evaluation

You'll see that:

${{ github.actor }}

is already replaced before the shell executes.

Part 5 – Observe Linux Expansion

You'll also see:

$APP_NAME

expanded by the Linux shell during execution.

Part 6 – Expected Output

Students should observe something similar to:

Workflow Variable : Workflow-App

Job Variable : Job-App

Step Variable : Step-App

Repository Variable : DevOps_Automation

Actor : OmPrakash

Repository : Xprakasho/DevOps_Automation

Branch : main

Commit : 9b1a23f...

Workspace :

/home/runner/work/DevOps_Automation/DevOps_Automation
Part 7 – Learning Outcomes

After this lab you should be able to explain:

Why ${{ }} exists.
Why $APP_NAME works.
Difference between GitHub Context and Built-in Variables.
Difference between Repository Variables and Environment Variables.
Variable Scope.
Variable Precedence.
GitHub evaluation timeline.
Linux shell expansion.
Part 8 – Challenge Exercise

Without changing the workflow logic:

Change APP_NAME in Repository Variables.
Run the workflow again.
Observe which values change.
Explain why they changed.

This reinforces that configuration can be modified without editing the workflow file, a key DevOps principle.

💡 One Improvement I'd Like to Add

Starting with Lab 02, I want to make our labs feel more like what you'd encounter in a company. At the end of every lab, we'll include a "Troubleshooting Corner" with common mistakes and how to diagnose them.

For example:

Problem	                                Likely Cause	                         Fix
${{ vars.APP_NAME }} is empty   	Repository Variable not created	        Add it in Repository Settings
$APP_NAME is empty	                Not mapped to env:	                Map vars.APP_NAME into env
Wrong branch name	                Used GITHUB_REF instead of github.ref_name	Choose the appropriate variable
