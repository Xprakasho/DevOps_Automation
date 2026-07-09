
# Lab 08: Git Remotes and Pull Request Workflow

## Objective

Practice and understand:

- Local and remote-tracking branches
- Git fetch
- Git pull
- Git push
- Upstream tracking
- Pull Request workflow
- Base and compare branches
- Updating local main after a PR merge
- Feature branch cleanup

---

## Lab 1: Inspect the Remote Repository

View configured remotes:

```bash
git remote -v

Inspect the origin remote:

git remote show origin

View branch tracking information:

git branch -vv

View remote-tracking branches:

git branch -r
Observation

A local branch and its remote-tracking branch are separate references.

Example:

main
origin/main
Lab 2: Demonstrate Git Fetch

Create or modify a file directly on GitHub and commit the change.

Before fetching, inspect the graph:

git log --oneline --graph --decorate --all -6

Fetch remote changes:

git fetch origin

Inspect again:

git log --oneline --graph --decorate --all -6
git status
Observation

After fetch:

origin/main moves to the latest remote commit.
Local main remains unchanged.
The working directory remains unchanged.
Lab 3: Update Local Main

After fetching:

git merge --ff-only origin/main

Verify:

git status
git log --oneline --graph --decorate --all -6
Observation

Local main moves to the same commit as origin/main.

No new merge commit is created by the local fast-forward operation.

Lab 4: Demonstrate Git Pull

Create another change directly on GitHub.

Run:

git pull

Verify:

git status
git log --oneline --graph --decorate --all -6
Observation

Git pull performs fetch followed by integration.

In this lab, the local branch was updated using a fast-forward.

Lab 5: Create a Feature Branch

Create and switch to a new branch:

git switch -c feature/day7-demo

Create a demonstration file:

echo "Day 7 remote tracking demo" > labs/git/day7-remote-demo.txt

Stage and commit:

git add labs/git/day7-remote-demo.txt

git commit -m "test: add Day 7 remote tracking demo"

Inspect:

git branch -vv
git log --oneline --graph --decorate --all -6
Lab 6: Push Without an Upstream

Run:

git push
Expected Result

Git reports that the current branch has no upstream branch.

Inspect:

git branch -vv
git branch -r
Observation

The local feature branch exists, but no corresponding remote-tracking branch has been configured.

Lab 7: Configure Upstream Tracking

Push the branch and configure its upstream:

git push -u origin feature/day7-demo

Verify:

git branch -vv
git branch -r
git log --oneline --graph --decorate --all -6
Observation

The local branch now tracks:

origin/feature/day7-demo

Future git push and git pull commands can use the configured upstream.

Lab 8: Create a Pull Request

Create a Pull Request on GitHub.

Verify:

base: main
compare: feature/day7-demo
Important Checkpoint

The base branch is the destination branch.

The compare branch is the source branch.

Always verify both branches before merging.

Lab 9: Inspect an Incorrect Base Branch Scenario

During the lab, the feature branch was accidentally merged into:

feature/repository-foundation

instead of:

main

After fetching:

git fetch origin

Inspect the graph:

git log --oneline --graph --decorate --all -10
Observation

The merge commit appeared on:

origin/feature/repository-foundation

Local and remote main remained unchanged.

Lesson

A successfully merged Pull Request does not necessarily mean the changes were merged into main.

Always verify the PR base branch.

Lab 10: Inspect the PR Merge Commit

Inspect the GitHub-created merge commit:

git cat-file -p <merge-commit-sha>

Example output:

parent <previous-main-sha>
parent <feature-commit-sha>
Observation

The commit contains two parents.

This proves that GitHub created a merge commit.

Lab 11: Create the Correct Pull Request

Create another Pull Request:

base: main
compare: feature/day7-demo

Merge the Pull Request using:

Create a merge commit

Return to the CLI.

Switch to main:

git switch main

Fetch:

git fetch origin

Inspect:

git log --oneline --graph --decorate --all -10
git status
Observation

After fetch:

Local main remains at the old commit.
origin/main points to the new PR merge commit.
The working directory remains unchanged.
Lab 12: Inspect the Correct Merge Commit

Run:

git cat-file -p <merge-commit-sha>

Verify that it contains two parents:

parent <old-main-sha>
parent <feature-branch-sha>
Observation

GitHub performed the merge and created the merge commit.

Lab 13: Fast-Forward Local Main

Run:

git merge --ff-only origin/main

Verify:

git status
git log --oneline --graph --decorate --all -10
Observation

The local main pointer moves to the existing GitHub merge commit.

Important:

GitHub created a merge commit, but the later local update was a fast-forward.

These are two separate Git operations.

Lab 14: Delete the Merged Feature Branch

Delete the local feature branch:

git branch -d feature/day7-demo

Delete the remote feature branch:

git push origin --delete feature/day7-demo

Remove stale remote-tracking references:

git fetch --prune

Verify:

git branch -a
git log --oneline --graph --decorate --all -10
Final Workflow
Create Feature Branch
        |
        v
Make Changes
        |
        v
Commit
        |
        v
git push -u origin <branch>
        |
        v
Create Pull Request
        |
        v
Verify Base and Compare
        |
        v
Merge Pull Request
        |
        v
git fetch origin
        |
        v
Inspect Graph and Status
        |
        v
git merge --ff-only origin/main
        |
        v
Delete Local Feature Branch
        |
        v
Delete Remote Feature Branch
        |
        v
git fetch --prune
Key Takeaways
main and origin/main are separate references.
git fetch updates remote-tracking references without moving the local branch.
git pull performs fetch followed by integration.
git push -u configures upstream tracking.
The PR base branch is the destination.
The PR compare branch is the source.
A merge commit contains two parents.
A GitHub merge commit and a later local fast-forward are different operations.
Merged feature branches should be cleaned up when no longer needed.
