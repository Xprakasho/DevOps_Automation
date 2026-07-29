Module Objectives

By the end of this module, you should understand:

What is a Job?
What is a Runner?
Why multiple jobs are used?
Parallel execution
Runner isolation
Why every job requires its own checkout
Job Dependencies using needs:
Failure propagation
Pipeline architecture
1. GitHub Actions Architecture
Workflow
    │
    ▼
Jobs
    │
    ▼
Steps
Hierarchy
Workflow
    ├── Job 1
    │      ├── Step
    │      ├── Step
    │      └── Step
    │
    └── Job 2
           ├── Step
           └── Step
2. What is a Job?

A Job is a collection of related steps executed on the same runner.

Example:

bash-validation
    ├── Checkout
    ├── Make Executable
    ├── Run Bash

Another Job

python-validation
    ├── Checkout
    ├── Setup Python
    ├── Run Python
3. Runner Architecture

Every Job gets its own runner.

Workflow
│
├── bash-validation
│      │
│      ▼
│   Ubuntu Runner #1
│
└── python-validation
       │
       ▼
    Ubuntu Runner #2
Important

Every runner is

Independent
Isolated
Temporary (Ephemeral)
4. Runner Isolation

Each runner has its own

Filesystem
Memory
Environment
Installed Software
Workspace

Runner A cannot access Runner B.

5. Why Checkout is Required in Every Job

Wrong assumption

Job A

Checkout Repository

↓

Job B

Run Python

This fails because Job B never downloaded the repository.

Correct

Job A

Checkout

Run Bash

↓

Job B

Checkout

Run Python

Rule:

Every job that needs repository files must execute actions/checkout.

6. Parallel Execution

Without dependencies

Code Push
     │
 ┌───┴─────┐
 ▼         ▼
Bash     Python

Both start together.

Time Example
Job	Duration
Bash	3 sec
Python	5 sec
YAML	2 sec

Sequential

3 + 5 + 2 = 10 sec

Parallel

Maximum(3,5,2)=5 sec

Benefit:

Faster CI
Better resource utilization
Shorter feedback loop
7. Job Dependencies (needs:)

Purpose

Control execution order.

Example

python-validation:
  needs: bash-validation

Execution

bash-validation
        │
        ▼
python-validation

Python waits until Bash completes successfully.

8. Pipeline Without needs
Code Push

├── Bash
│
└── Python

GitHub starts both jobs immediately.

9. Pipeline With needs
Code Push
     │
     ▼
Bash
     │
     ▼
Python

Python starts only after Bash succeeds.

10. Failure Propagation

Experiment

bash-validation

↓

exit 1

Result

bash-validation

❌ Failed

↓

python-validation

Skipped

Important

Python Job never started.

GitHub never scheduled a runner because the dependency failed.

11. Parallel vs Sequential

Parallel

A

B

C

Use When

Independent work
Faster execution

Sequential

A

↓

B

↓

C

Use When

Build
Deploy
Release
Database Migration
12. Real Production Pipeline
               Developer Push
                      │
      ┌───────────────┼───────────────┐
      ▼               ▼               ▼
 YAML Check     Python Check    Bash Check
      │               │               │
      └───────────────┼───────────────┘
                      ▼
             Build Helm Package
                      ▼
           Deploy Test Cluster
                      ▼
            Execute Test Suite
                      ▼
           Publish Test Report
13. CI/CD Architecture Thinking

Before writing YAML, answer

What depends on what?

Pipeline design should start with dependencies, not syntax.

14. Platform Independent Mapping
Concept	     GitHub Actions	  Jenkins	    GitLab CI	Azure DevOps
Pipeline	 Workflow	      Pipeline	    Pipeline	Pipeline
Job	         Job	          Stage/Node	Stage/Job	Stage/Job
Runner	     Runner	          Agent	        Runner	    Agent
Dependency   needs:	          Stage Order	needs:	    dependsOn
                             /Pipeline Flow
Different syntax.

Same architecture.

15. Common Mistakes
Forgetting Checkout
No repository found

Reason

New runner.

Wrong Indentation
Unexpected value 'python-validation'

Reason

Job created inside Steps.

Assuming Jobs Share Files

Wrong.

Jobs are isolated.

Thinking Skipped = Failed

Incorrect.

Failed

Job started

↓

Error occurred

Skipped

Job never started