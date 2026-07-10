## Objective

Practice:

- `git restore`
- `git restore --staged`
- restoring Index and Working Tree
- `git reset --soft`
- `git reset --mixed`
- `git reset --hard`
- `git reflog`
- recovering lost commits
- `git revert`
- resolving revert conflicts

---

## Part 1: Create the Recovery Branch

```bash
git switch main
git status
git switch -c feature/day8-git-recovery
Part 2: Create the Recovery Demo File
echo "Environment: Production" > labs/git/day8-recovery-demo.txt

git add labs/git/day8-recovery-demo.txt

git commit -m "test: add Day 8 recovery demo file"

Verify:

git log --oneline --decorate -4
cat labs/git/day8-recovery-demo.txt
git status
Part 3: Practice git restore

Modify the file:

echo "Environment: Development" > labs/git/day8-recovery-demo.txt

Inspect:

git status --short
git diff -- labs/git/day8-recovery-demo.txt
cat labs/git/day8-recovery-demo.txt

Restore it:

git restore labs/git/day8-recovery-demo.txt

Verify:

git status --short
cat labs/git/day8-recovery-demo.txt
git diff

Expected result:

Environment: Production
Part 4: Practice git restore --staged

Modify the file:

echo "Environment: Staging" > labs/git/day8-recovery-demo.txt

Stage it:

git add labs/git/day8-recovery-demo.txt

Inspect:

git status --short
git diff
git diff --cached

Unstage it:

git restore --staged labs/git/day8-recovery-demo.txt

Verify:

git status --short
git diff
git diff --cached

The change should remain in the Working Tree but no longer be staged.

Part 5: Restore Index and Working Tree

Run:

git restore --source=HEAD --staged --worktree labs/git/day8-recovery-demo.txt

Verify:

git status --short
cat labs/git/day8-recovery-demo.txt

Expected:

Environment: Production
Part 6: Create Additional Commits

Add application configuration:

echo "Application: Payment-Service" >> labs/git/day8-recovery-demo.txt

git add labs/git/day8-recovery-demo.txt

git commit -m "test: add application configuration"

Add application version:

echo "Version: 2.0" >> labs/git/day8-recovery-demo.txt

git add labs/git/day8-recovery-demo.txt

git commit -m "test: add application version"

Verify:

git log --oneline --decorate -4
cat labs/git/day8-recovery-demo.txt
git status
Part 7: Practice git reset --soft

Run:

git reset --soft HEAD~1

Inspect:

git log --oneline --decorate -4
git status
git diff
git diff --cached
cat labs/git/day8-recovery-demo.txt

Observe:

HEAD moved backward.
Index retained the changes.
Working Tree retained the changes.
Version: 2.0 remains staged.

Recover the commit for the next exercise using its SHA if required.

Part 8: Practice git reset --mixed

Run:

git reset --mixed HEAD~1

Inspect:

git log --oneline --decorate -4
git status
git diff
git diff --cached
cat labs/git/day8-recovery-demo.txt

Observe:

HEAD moved.
Index was reset.
Working Tree was retained.
Changes became unstaged.
Part 9: Accidental Repeated Reset

During the lab, git reset --mixed HEAD~1 was accidentally executed multiple times.

Inspect:

git log --oneline --decorate -4
git status

The branch may have moved farther backward than intended.

Use:

git reflog --oneline -10

Observe previous HEAD positions.

Part 10: Recover Using Reflog

Identify the lost commit:

git reflog --oneline -10

Recover:

git reset --hard <lost-commit-SHA>

In the Day 8 exercise:

git reset --hard ecdef10

Verify:

git log --oneline --decorate -4
git status
cat labs/git/day8-recovery-demo.txt

Expected file:

Environment: Production
Application: Payment-Service
Version: 2.0

Part 10: Recover Using Reflog

Identify the lost commit:

git reflog --oneline -10

Recover:

git reset --hard <lost-commit-SHA>

In the Day 8 exercise:

git reset --hard ecdef10

Verify:

git log --oneline --decorate -4
git status
cat labs/git/day8-recovery-demo.txt

Expected file:

Environment: Production
Application: Payment-Service
Version: 2.0
Part 11: Practice git reset --hard

Run:

git reset --hard HEAD~1

Inspect:

git log --oneline --decorate -4
git status
git diff
git diff --cached
cat labs/git/day8-recovery-demo.txt

Observe:

HEAD moved.
Index was reset.
Working Tree was reset.
Version: 2.0 disappeared.

Recover again using reflog:

git reflog --oneline -10
git reset --hard <lost-commit-SHA>
Part 12: Practice git revert

Revert the version commit:

git revert <version-commit-SHA>

In the Day 8 exercise:

git revert ecdef10

Verify:

git log --oneline --decorate -5
git status
cat labs/git/day8-recovery-demo.txt
git cat-file -p HEAD

Observe:

The original commit remains in history.
A new revert commit is created.
The new revert commit has one parent.
Version: 2.0 is removed.
Part 13: Create Version 3.0

Run:

echo "Version: 3.0" >> labs/git/day8-recovery-demo.txt

git add labs/git/day8-recovery-demo.txt

git commit -m "test: update application to version 3.0"

Verify:

git log --oneline --decorate -5
cat labs/git/day8-recovery-demo.txt
git status
Part 14: Create a Revert Conflict

Revert the earlier revert commit:

git revert <revert-commit-SHA>

In the Day 8 exercise:

git revert 69752b3

Inspect:

git status
cat labs/git/day8-recovery-demo.txt
git diff

Expected conflict:

Version: 3.0

Part 15: Resolve the Revert Conflict

Keep:

Environment: Production
Application: Payment-Service
Version: 3.0

Remove all conflict markers.

Stage the resolution:

git add labs/git/day8-recovery-demo.txt

Inspect:

git status
git diff --cached

Continue:

git revert --continue

Part 16: Inspect Hidden Whitespace Changes

During the exercise, an additional blank line was accidentally introduced.

Inspect:

git show --stat HEAD
git show HEAD
cat -A labs/git/day8-recovery-demo.txt

Important lesson:

Even if the intended content appears unchanged, whitespace or blank-line differences may still produce a real commit.

Always inspect:

git diff --cached

before continuing a merge, rebase, or revert operation.

Final Verification
git status
git log --oneline --graph --decorate --all -10
git reflog --oneline -10
cat -A labs/git/day8-recovery-demo.txt
Final Recovery Workflow
Identify problem
      ↓
git status
      ↓
git log / git reflog
      ↓
Understand HEAD / Index / Working Tree
      ↓
Choose restore / reset / revert
      ↓
Inspect git diff
      ↓
Inspect git diff --cached
      ↓
Perform recovery
      ↓
Verify final state
Lab Summary

This lab demonstrated:

Discarding Working Tree changes.
Unstaging files.
Restoring Index and Working Tree.
Undoing commits with soft, mixed, and hard reset.
Recovering from accidental resets.
Using reflog to find lost commits.
Recovering branch pointers.
Safely undoing shared history using revert.
Resolving revert conflicts.
Detecting unintended whitespace changes.
EOF
