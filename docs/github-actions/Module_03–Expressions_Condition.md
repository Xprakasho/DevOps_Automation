Learning Objectives

After completing this module, you should be able to:

Understand what GitHub Expressions are.
Use the if: keyword to control execution.
Understand the difference between Context-based and Status-based conditions.
Use success(), failure(), always(), and cancelled().
Combine multiple conditions using logical operators.
Predict the execution flow of a workflow.
Explain why steps are Executed, Skipped, or Failed.
1. GitHub Expression

An expression is a logical statement evaluated by GitHub before a step executes.

Syntax:

${{ expression }}

Examples:

${{ github.ref_name }}

${{ github.actor }}

${{ github.sha }}

${{ env.APP_NAME }}

${{ github.ref_name == 'main' }}
2. What is if:

The if: keyword tells GitHub whether a step or job should execute.

Example

- name: Run Python
  if: ${{ github.ref_name == 'main' }}
  run: python info.py

GitHub asks:

Is current branch main?

YES

↓

Execute

NO

↓

Skip

3. Expression Evaluation

GitHub evaluates expressions before the step starts.

Execution Flow

Read Workflow

↓

Evaluate Expression

↓

TRUE?

↓

YES → Execute

NO → Skip
4. Context-Based Conditions

These use GitHub metadata.

Examples

${{ github.ref_name }}

${{ github.actor }}

${{ github.event_name }}

${{ github.repository }}

Example

if: ${{ github.ref_name == 'main' }}
5. Status-Based Conditions

These depend on previous execution status.

Functions

success()

failure()

always()

cancelled()
6. success()

Question GitHub asks

Did all previous steps succeed?

Returns

TRUE

only if every previous step completed successfully.

Example

- name: Success Demo
  if: ${{ success() }}
  run: echo "Everything succeeded."
7. failure()

Question GitHub asks

Has any previous step failed?

Returns

TRUE

when one or more previous steps failed.

Example

- name: Collect Logs
  if: ${{ failure() }}
  run: kubectl logs deployment/my-app

Common Uses

Collect logs
Generate diagnostics
Capture Kubernetes events
Save failure artifacts
8. always()

Question GitHub asks

Should I execute regardless?

Answer

YES

Always.

Example

- name: Upload Report
  if: ${{ always() }}
  run: ./upload-report.sh

Common Uses

Upload reports
Archive logs
Cleanup
Notifications
9. cancelled()

Question

Was this workflow cancelled?

Example

- name: Release Lock
  if: ${{ cancelled() }}
  run: ./unlock.sh

Used for

Unlock resources
Cleanup
Cancellation notification
10. Step Status
Status	Meaning
✅ Success	Step executed successfully
❌ Failed	Step executed but returned an error
⏭️ Skipped	Step was never executed because its condition evaluated to FALSE
11. Execution Flow
GitHub Reads Workflow

↓

Evaluate Condition

↓

TRUE?

↓

Execute

↓

FALSE?

↓

Skip
12. Combining Conditions

AND

if: ${{ github.ref_name == 'main' && success() }}

Meaning

Branch = main

AND

Previous Steps Successful

Both must be TRUE.

OR

if: ${{ failure() || cancelled() }}

Meaning

Run if

Failure

OR

Cancelled
13. Production Example
Deploy

↓

Verify Pods

↓

Collect Logs (failure())

↓

Upload Report (always())

↓

Notify Team (always())

Deployment Success

Deploy ✅

Verify Pods ✅

Collect Logs ⏭️

Upload Report ✅

Notify Team ✅

Deployment Failure

Deploy ❌

Collect Logs ✅

Upload Report ✅

Notify Team ✅
Best Practices

✅ Use if: instead of duplicating workflows.

✅ Use always() for reports and cleanup.

✅ Use failure() for diagnostics.

✅ Use branch conditions for deployment.

✅ Keep conditions simple and readable.

Common Mistakes

❌ Using Bash syntax inside if:.

Wrong

if: $APP_NAME == "DevOps"

Correct

if: ${{ env.APP_NAME == 'DevOps' }}

❌ Confusing Skipped with Failed.

Skipped

↓

Condition FALSE

Failed

↓

Step executed and returned an error.