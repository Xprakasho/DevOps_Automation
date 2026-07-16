

# Lab 10: Advanced Git

## Objective

Practice advanced Git operations through hands-on experiments.

This lab begins with Git Stash.

Topics covered:

- Creating a stash
- Inspecting stash entries
- Applying a stash
- Popping a stash
- Staged and unstaged changes
- Restoring the Index
- Stashing untracked files
- Working with multiple stash entries
- Applying a specific stash

---

# Part 1: Create the Lab Branch

Create a feature branch:

```bash
git switch -c feature/day9-advanced-git
```

Verify:

```bash
git branch --show-current
git status
```

Expected:

```text
On branch feature/day9-advanced-git
nothing to commit, working tree clean
```

---

# Part 2: Create the Stash Demo File

Create:

```bash
echo "Application: Payment-Service" > labs/git/day9-stash-demo.txt
```

Stage and commit:

```bash
git add labs/git/day9-stash-demo.txt

git commit -m "test: add Day 9 stash demo file"
```

Verify:

```bash
git log --oneline --decorate -3
git status
cat labs/git/day9-stash-demo.txt
```

---

# Part 3: Create an Unstaged Change

Modify the file:

```bash
echo "Environment: Development" >> labs/git/day9-stash-demo.txt
```

Inspect:

```bash
git status --short
git diff
cat labs/git/day9-stash-demo.txt
```

Expected:

```text
 M labs/git/day9-stash-demo.txt
```

The change exists only in the Working Tree.

---

# Part 4: Create a Basic Stash

Create the stash:

```bash
git stash push -m "day9: basic stash demo"
```

Inspect:

```bash
git status --short
cat labs/git/day9-stash-demo.txt
git stash list
```

Observe:

```text
HEAD          -> unchanged
Index         -> clean
Working Tree  -> clean
Change        -> stored in stash
```

---

# Part 5: Apply the Stash

Run:

```bash
git stash apply
```

Inspect:

```bash
git status --short
cat labs/git/day9-stash-demo.txt
git stash list
```

Observe:

```text
HEAD                      -> unchanged
Environment: Development  -> restored
Working Tree              -> modified
Stash entry               -> retained
```

Important:

```text
apply = restore + keep stash
```

---

# Part 6: Test Git Stash Pop

First restore the file:

```bash
git restore labs/git/day9-stash-demo.txt
```

Verify:

```bash
git status --short
```

Apply using `pop`:

```bash
git stash pop
```

Inspect:

```bash
git status --short
cat labs/git/day9-stash-demo.txt
git stash list
```

Observe:

```text
Changes restored
Stash removed after successful application
```

Important:

```text
pop = restore + remove successfully applied stash
```

---

# Part 7: Prepare Staged and Unstaged Changes

Restore the file:

```bash
git restore labs/git/day9-stash-demo.txt
```

Add:

```bash
echo "Environment: Development" >> labs/git/day9-stash-demo.txt
```

Stage the change:

```bash
git add labs/git/day9-stash-demo.txt
```

Add another change:

```bash
echo "Debug: Enabled" >> labs/git/day9-stash-demo.txt
```

Inspect:

```bash
git status --short
git diff
git diff --cached
cat labs/git/day9-stash-demo.txt
```

Expected status:

```text
MM labs/git/day9-stash-demo.txt
```

State:

```text
Environment: Development -> staged
Debug: Enabled           -> unstaged
```

---

# Part 8: Stash Staged and Unstaged Changes

Create:

```bash
git stash push -m "day9: staged and unstaged demo"
```

Inspect:

```bash
git status --short
cat labs/git/day9-stash-demo.txt
git stash list
```

Inspect the stash:

```bash
git stash show --stat stash@{0}
git stash show -p stash@{0}
```

Observe:

```text
Both staged and unstaged content is stored
Index becomes clean
Working Tree becomes clean
HEAD remains unchanged
```

---

# Part 9: Apply Without Restoring the Index

Run:

```bash
git stash apply
```

Inspect:

```bash
git status --short
git diff
git diff --cached
```

Observe:

```text
Environment: Development -> unstaged
Debug: Enabled           -> unstaged
```

Expected:

```text
 M labs/git/day9-stash-demo.txt
```

Important:

```text
git stash apply restores content

It does not restore the original staging state by default
```

---

# Part 10: Restore and Apply with `--index`

Restore the file:

```bash
git restore labs/git/day9-stash-demo.txt
```

Verify:

```bash
git status --short
```

Apply:

```bash
git stash apply --index
```

Inspect:

```bash
git status --short
git diff
git diff --cached
cat labs/git/day9-stash-demo.txt
```

Expected:

```text
MM labs/git/day9-stash-demo.txt
```

Observe:

```text
Environment: Development -> staged
Debug: Enabled           -> unstaged
```

Important:

```text
--index attempts to restore the original Index state
```

---

# Part 11: Clean the Repository

Restore both the Index and Working Tree:

```bash
git restore --source=HEAD --staged --worktree labs/git/day9-stash-demo.txt
```

Verify:

```bash
git status --short
```

---

# Part 12: Create an Untracked File

Create:

```bash
echo "Temporary untracked configuration" > labs/git/day9-untracked-demo.txt
```

Inspect:

```bash
git status --short
```

Expected:

```text
?? labs/git/day9-untracked-demo.txt
```

---

# Part 13: Test Normal Stash with an Untracked File

Run:

```bash
git stash push -m "day9: normal stash with untracked file"
```

Inspect:

```bash
git status --short
git stash list
ls -l labs/git/day9-untracked-demo.txt
```

Observe:

```text
Normal stash ignores untracked files
```

The untracked file remains in the Working Tree.

---

# Part 14: Stash the Untracked File

Run:

```bash
git stash push -u -m "day9: stash untracked file"
```

Inspect:

```bash
git status --short
git stash list
ls -l labs/git/day9-untracked-demo.txt
```

Expected:

```text
Working Tree -> clean
Untracked file -> stored in stash
```

The `ls` command should report:

```text
No such file or directory
```

The file is stored in the stash and is not lost.

---

# Part 15: Inspect Multiple Stashes

Run:

```bash
git stash list
```

Example:

```text
stash@{0}: On day9-advanced-git: day9: stash untracked file
stash@{1}: On day9-advanced-git: day9: staged and unstaged demo
```

Observe:

```text
stash@{0} -> newest
stash@{1} -> older
```

---

# Part 16: Apply a Specific Stash

Apply:

```bash
git stash apply 'stash@{1}'
```

Inspect:

```bash
git status --short
git diff
git diff --cached
git stash list
```

Expected:

```text
 M labs/git/day9-stash-demo.txt
```

Observe:

```text
Environment: Development -> restored
Debug: Enabled           -> restored

Both changes -> unstaged

stash@{0} -> remains
stash@{1} -> remains
```

Important:

```text
git stash apply 'stash@{n}'
```

allows a specific stash entry to be selected.

---

# Part 17: Restore the Working Tree

Run:

```bash
git restore labs/git/day9-stash-demo.txt
```

Inspect:

```bash
git status --short
git stash list
cat labs/git/day9-stash-demo.txt
```

Expected final state:

```text
HEAD          -> unchanged
Index         -> clean
Working Tree  -> clean

stash@{0} -> remains
stash@{1} -> remains
```

---

# Key Observations

## Observation 1: Stash Does Not Move HEAD

```text
HEAD before stash == HEAD after stash
```

---

## Observation 2: Apply vs Pop

```text
apply
    |
    +--> restore
    +--> keep stash

pop
    |
    +--> restore
    +--> remove successfully applied stash
```

---

## Observation 3: Default Apply vs `--index`

```text
git stash apply
    |
    v
Restore content only
```

```text
git stash apply --index
    |
    v
Restore content + attempt to restore Index state
```

---

## Observation 4: Normal Stash vs `-u`

```text
git stash
    |
    v
Tracked changes
```

```text
git stash -u
    |
    v
Tracked changes + untracked files
```

---

## Observation 5: Multiple Stashes

```text
Newest -> stash@{0}

Older  -> stash@{1}

Older  -> stash@{2}
```

Specific stash:

```bash
git stash apply 'stash@{1}'
```

---

# Command Summary

```bash
git stash

git stash push -m "message"

git stash list

git stash show --stat stash@{0}

git stash show -p stash@{0}

git stash apply

git stash apply 'stash@{1}'

git stash apply --index

git stash pop

git stash push -u -m "message"
```

---

# Topics for Next Session

Continue Git Stash with:

```text
Stashing selected files
git stash drop
git stash clear
Stash conflicts
Stash conflict resolution
Git Stash internals
```

Then continue Advanced Git:

```text
Git Cherry-Pick
Git Tags
```

=============================================

---

# Part 18: Stashing Selected Files

## Objective

Learn how to stash only a specific file while leaving other modified files untouched.

### Create Demo Files

```bash
cat > labs/git/day9-app.txt <<EOF
Application: Payment-Service
EOF

cat > labs/git/day9-db.txt <<EOF
Database: PostgreSQL
EOF
```

Commit:

```bash
git add .
git commit -m "test: add stash selected files demo"
```

Modify both:

```bash
echo "Environment: Development" >> labs/git/day9-app.txt

echo "Replica: Enabled" >> labs/git/day9-db.txt
```

Inspect:

```bash
git status --short
```

Expected:

```text
 M labs/git/day9-app.txt
 M labs/git/day9-db.txt
```

Stash only one file:

```bash
git stash push -m "day9: selected file demo" -- labs/git/day9-app.txt
```

Verify:

```bash
git status --short
git stash show -p stash@{0}
```

Observe:

- day9-app.txt restored
- day9-db.txt still modified
- stash contains only day9-app.txt

---

# Part 19: git stash drop

View stashes:

```bash
git stash list
```

Delete one stash:

```bash
git stash drop stash@{1}
```

Verify:

```bash
git stash list
```

Observe:

- Selected stash removed
- Remaining stashes renumbered

---

# Part 20: git stash clear

Remove every stash:

```bash
git stash clear
```

Verify:

```bash
git stash list
```

Expected:

```text
(no stash entries)
```

---

# Part 21: Cherry-pick Single Commit

Switch:

```bash
git switch main
git switch -c feature/cherry-pick-demo
```

Create:

```bash
echo "Application: Payment-Service" > labs/git/cherry-demo.txt
```

Commit:

```bash
git add .
git commit -m "test: add cherry-pick demo file"
```

Second commit:

```bash
echo "Version: 1.0" >> labs/git/cherry-demo.txt

git add .

git commit -m "test: add application version"
```

Third commit:

```bash
echo "Environment: Production" >> labs/git/cherry-demo.txt

git add .

git commit -m "test: add production environment"
```

Inspect:

```bash
git log --oneline --decorate -3
```

---

# Part 22: Cherry-pick Dependency Conflict

Create target branch:

```bash
git switch main

git switch -c feature/cherry-target
```

Attempt:

```bash
git cherry-pick <version-sha>
```

Observe:

```text
CONFLICT (modify/delete)
```

Reason:

The target branch does not yet contain the file created by the earlier commit.

Abort:

```bash
git cherry-pick --abort
```

---

# Part 23: Successful Cherry-pick

Cherry-pick file creation:

```bash
git cherry-pick <create-file-sha>
```

Then:

```bash
git cherry-pick <version-sha>
```

Verify:

```bash
git log --decorate --oneline

cat labs/git/cherry-demo.txt
```

Observe:

- New SHAs
- Same commit messages
- Source branch unchanged

---

# Part 24: Lightweight Tag

Create:

```bash
git tag v1.0
```

Inspect:

```bash
git tag

git show v1.0

git log --decorate --oneline
```

---

# Part 25: Annotated Tag

Create:

```bash
git tag -a v1.1 -m "First production release"
```

Inspect:

```bash
git show v1.1
```

Observe:

- Tagger
- Date
- Message
- Referenced commit

---

# Part 26: Tag an Older Commit

Create:

```bash
git tag v0.9 <commit-sha>
```

Inspect:

```bash
git log --decorate --oneline

git show v0.9
```

---

# Part 27: Push and Delete Tags

Push one:

```bash
git push origin v1.1
```

Push all:

```bash
git push origin --tags
```

Delete local:

```bash
git tag -d v0.9
```

Delete remote:

```bash
git push origin --delete v0.9
```

---

# Key Observations

1. Selected file stashing affects only chosen files.
2. git stash drop removes one stash.
3. git stash clear removes all stashes.
4. Cherry-pick copies changes and creates a new commit.
5. Cherry-picked commits receive new SHAs.
6. Cherry-pick may fail if required context is missing.
7. Tags never move automatically.
8. Lightweight tags are simple pointers.
9. Annotated tags store metadata.
10. Tags must be pushed explicitly.
