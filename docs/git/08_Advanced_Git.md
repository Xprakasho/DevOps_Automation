
# Advanced Git

## 1. Introduction

Advanced Git operations help engineers temporarily manage work, transfer specific changes between branches, recover from workflow interruptions, and maintain repository history safely.

This document begins with Git Stash.

Git Stash is commonly used when work is incomplete but the engineer needs to temporarily switch context without creating a commit.

---

# Part 1: Git Stash

## 2. What Is Git Stash?

Git Stash temporarily stores changes from the Working Tree and Index and restores the repository to a clean state.

Typical scenario:

```text
Working on feature
        |
        v
Incomplete changes exist
        |
        v
Urgent task requires branch switch
        |
        v
git stash
        |
        v
Working Tree becomes clean
        |
        v
Complete urgent work
        |
        v
git stash apply / pop
        |
        v
Continue previous work
```

Git Stash is useful when changes are not ready for a normal commit.

---

## 3. Git Stash Mental Model

The primary Git areas are:

```text
HEAD
  |
  v
Index / Staging Area
  |
  v
Working Tree
```

Git Stash introduces temporary storage for changes:

```text
HEAD
  |
  v
Index
  |
  v
Working Tree
  |
  | git stash
  v
Stash
```

Important:

```text
git stash does not move HEAD
git stash does not move the branch pointer
```

Instead, Git stores the changes and restores the Working Tree and Index to a clean state.

---

## 4. Creating a Basic Stash

Command:

```bash
git stash
```

A more descriptive method is:

```bash
git stash push -m "description"
```

Example:

```bash
git stash push -m "day9: staged and unstaged demo"
```

The `push` subcommand creates a stash entry.

The `-m` option adds a meaningful description.

Important:

```text
git stash push
```

does not mean pushing changes to a remote repository.

It means creating and pushing a new entry onto the Git stash stack.

---

## 5. Inspecting Stashes

List existing stash entries:

```bash
git stash list
```

Example:

```text
stash@{0}: On feature: latest work
stash@{1}: On feature: previous work
```

Git Stash behaves like a stack:

```text
Newest stash
    |
    v
stash@{0}

stash@{1}

stash@{2}
    |
    v
Older stash
```

Every newly created stash becomes:

```text
stash@{0}
```

Older entries move down the stack.

---

## 6. Inspecting Stash Content

Display a stash summary:

```bash
git stash show --stat stash@{0}
```

Display the complete patch:

```bash
git stash show -p stash@{0}
```

Example:

```bash
git stash show -p stash@{0}
```

This allows engineers to inspect changes before restoring them.

---

## 7. Applying a Stash

Command:

```bash
git stash apply
```

By default, this applies:

```text
stash@{0}
```

Important behavior:

```text
HEAD          -> unchanged
Branch        -> unchanged
Changes       -> restored
Stash entry   -> retained
```

Therefore:

```text
apply = restore changes + keep stash
```

---

## 8. Applying a Specific Stash

When multiple stash entries exist, a specific stash can be selected.

Example:

```bash
git stash apply 'stash@{1}'
```

This restores the selected stash instead of the latest stash.

Example:

```text
stash@{0} -> untracked file demo
stash@{1} -> staged and unstaged demo
```

Command:

```bash
git stash apply 'stash@{1}'
```

Result:

```text
stash@{1} changes restored
stash@{0} remains
stash@{1} remains
```

Important:

```text
git stash apply does not delete the stash entry
```

---

## 9. Git Stash Pop

Command:

```bash
git stash pop
```

`pop` applies the stash changes and removes the stash entry after successful application.

Concept:

```text
git stash pop
        |
        +--> Restore changes
        |
        +--> Remove successfully applied stash
```

Important comparison:

```text
git stash apply
    -> restore changes
    -> keep stash

git stash pop
    -> restore changes
    -> remove stash after successful application
```

---

## 10. Stashing Staged and Unstaged Changes

Consider a file containing:

```text
Application: Payment-Service
Environment: Development
Debug: Enabled
```

Suppose:

```text
Environment: Development -> staged
Debug: Enabled           -> unstaged
```

Status:

```text
MM file
```

The first `M` represents the difference between:

```text
HEAD <-> Index
```

The second `M` represents the difference between:

```text
Index <-> Working Tree
```

Running:

```bash
git stash push -m "staged and unstaged demo"
```

stores both staged and unstaged changes.

After the stash:

```text
Index        -> clean
Working Tree -> clean
HEAD         -> unchanged
```

---

## 11. Default Stash Apply Behavior

Suppose a stash originally contained:

```text
Environment: Development -> staged
Debug: Enabled           -> unstaged
```

Running:

```bash
git stash apply
```

restores the content.

However, by default, the original staged state is not restored.

Result:

```text
Environment: Development -> unstaged
Debug: Enabled           -> unstaged
```

Status:

```text
 M file
```

Important principle:

```text
git stash apply
    |
    v
Restores file content

But does not restore the original Index state by default
```

---

## 12. Restoring the Index with `--index`

Command:

```bash
git stash apply --index
```

This attempts to restore both:

```text
Working Tree state
+
Index state
```

Example original state:

```text
Environment: Development -> staged
Debug: Enabled           -> unstaged
```

After:

```bash
git stash apply --index
```

Result:

```text
Environment: Development -> staged
Debug: Enabled           -> unstaged
```

Status:

```text
MM file
```

Comparison:

```text
git stash apply

Content restored
Original staging state not restored
```

versus:

```text
git stash apply --index

Content restored
Original staging state restored
```

---

## 13. Normal Stash and Untracked Files

Create an untracked file:

```bash
echo "Temporary configuration file" > temporary-file.txt
```

Status:

```text
?? temporary-file.txt
```

Run:

```bash
git stash push -m "normal stash"
```

Possible output:

```text
No local changes to save
```

Reason:

```text
Normal git stash ignores untracked files
```

The untracked file remains in the Working Tree.

---

## 14. Stashing Untracked Files

Use:

```bash
git stash push -u -m "stash untracked file"
```

The `-u` option means:

```text
--include-untracked
```

Result:

```text
Tracked changes   -> stashed
Untracked files   -> stashed
Working Tree      -> clean
Index             -> clean
HEAD              -> unchanged
```

The untracked file disappears from the Working Tree because it is stored in the stash.

Important:

```text
git stash
    |
    v
Tracked changes only

git stash -u
    |
    v
Tracked changes + untracked files
```

---

## 15. Multiple Stashes

Git can store multiple stash entries.

Example:

```text
stash@{0}: untracked file demo
stash@{1}: staged and unstaged demo
```

The newest stash is always:

```text
stash@{0}
```

A specific stash can be restored using:

```bash
git stash apply 'stash@{1}'
```

Important:

```text
apply does not remove the selected stash
```

Therefore, after successful application:

```text
stash@{0} -> remains
stash@{1} -> remains
```

---

## 16. Git Stash Command Comparison

| Command | Restores Changes | Removes Stash | Restores Index State |
|---|---|---|---|
| `git stash apply` | Yes | No | No |
| `git stash apply --index` | Yes | No | Yes |
| `git stash pop` | Yes | Yes, after successful application | No by default |
| `git stash push -u` | Creates stash | No | Stores tracked and untracked changes |

---

## 17. Practical DevOps Use Cases

Git Stash is useful when:

- An urgent production issue requires switching branches.
- A developer needs to pull or rebase but has incomplete local changes.
- Infrastructure code is partially modified but not ready for commit.
- A temporary experiment must be saved before changing context.
- A developer needs to compare work across branches.
- Local debugging changes should not yet become part of repository history.

Example workflow:

```bash
git status

git stash push -m "WIP: Terraform networking changes"

git switch main

git pull

git switch feature/networking

git stash apply
```

---

## 18. Key Mental Model

Remember:

```text
git stash
    |
    +--> HEAD does not move
    |
    +--> Branch pointer does not move
    |
    +--> Changes are temporarily stored
    |
    +--> Index becomes clean
    |
    +--> Working Tree becomes clean
```

Restoring:

```text
apply
    |
    +--> restore content
    +--> keep stash

pop
    |
    +--> restore content
    +--> remove successfully applied stash

apply --index
    |
    +--> restore content
    +--> attempt to restore staging state
```

---

## 19. Topics to Continue

The following Git Stash topics will be covered next:

```text
Stashing selected files
git stash drop
git stash clear
Stash conflicts
Stash conflict resolution
Git Stash internals
```

After completing Git Stash:

```text
Git Cherry-Pick
Git Tags
```

---

## 20. Summary

The most important Git Stash principles are:

1. Git Stash temporarily stores incomplete changes.
2. Creating a stash does not move HEAD or the current branch.
3. Normal stash operations save tracked staged and unstaged changes.
4. Normal stash operations ignore untracked files.
5. Use `-u` to include untracked files.
6. `git stash apply` restores changes but retains the stash.
7. `git stash pop` restores changes and removes the stash after successful application.
8. `git stash apply --index` attempts to restore the original Index state.
9. Multiple stashes are stored as a stack.
10. A specific stash can be selected using `stash@{n}`.

===================================

---

## 21. Stashing Selected Files

Git allows stashing only specific files instead of all modified tracked files.

Command:

```bash
git stash push -- <file>
```

Example:

```bash
git stash push -- labs/git/day9-app.txt
```

Result:

```text
day9-app.txt   -> stashed

day9-db.txt    -> remains modified
```

This is useful when only part of the current work should be temporarily stored.

Typical DevOps use case:

```text
values.yaml        -> stash

README.md          -> continue editing

deployment.yaml    -> continue editing
```

Important:

```text
Only the specified file is stashed.

Other modified files remain unchanged.
``` 
=================================================

---

## 22. Removing Stashes

Delete a single stash:

```bash
git stash drop stash@{0}
```

Result:

```text
Selected stash removed.

Remaining stash entries are automatically renumbered.
```

Delete every stash:

```bash
git stash clear
```

Result:

```text
All stash entries removed.
```

Important:

Neither command changes:

- HEAD
- Branch
- Index
- Working Tree

Only the stash references are removed.

====================================================

---

# 23. Git Cherry-pick

## What Is Cherry-pick?

Git Cherry-pick copies the changes introduced by one or more commits and creates new commits on the current branch.

Command:

```bash
git cherry-pick <commit-sha>
```

Example:

```text
Feature Branch

A
B
C
```

Cherry-pick B onto main:

```text
main

X
Y
B'
```

Important:

```text
Original commit remains.

A new commit is created.

New SHA is generated.
```

Cherry-pick copies the patch, not the original commit.

---

## Multiple Commits

```bash
git cherry-pick sha1 sha2
```

---

## Commit Ranges

Include B:

```bash
git cherry-pick B^..D
```

Cherry-picks:

```text
B
C
D
```

Exclude B:

```bash
git cherry-pick B..D
```

Cherry-picks:

```text
C
D
```

---

## Cherry-pick Dependency

Cherry-picking a commit may fail if the target branch lacks commits required by the selected commit.

Example:

```text
Commit A
Create file

Commit B
Modify file
```

Cherry-picking only B may fail because the file does not yet exist.

---

## Cherry-pick Options

Abort:

```bash
git cherry-pick --abort
```

Continue:

```bash
git cherry-pick --continue
```

Trace original commit:

```bash
git cherry-pick -x <sha>
```

---

## Cherry-pick vs Merge

| Merge | Cherry-pick |
|--------|-------------|
| Brings all commits | Brings selected commits |
| Preserves branch history | Creates new commits |
| Used for integrating branches | Used for hotfixes and backports |

---

## Common Use Cases

- Production hotfix
- Backport bug fixes
- Copy security patches
- Release branch maintenance

==============================================================================

---

# 24. Git Tags

Git Tags create permanent names for specific commits.

Unlike branches, tags normally do not move.

Example:

```text
A
B
C
D
```

```text
v1.0
  |
  D
```

---

## Lightweight Tags

Create:

```bash
git tag v1.0
```

Characteristics:

- Simple reference
- No metadata

---

## Annotated Tags

Create:

```bash
git tag -a v1.1 -m "First production release"
```

Annotated tags store:

- Tagger
- Date
- Message
- Referenced commit

Recommended for production releases.

---

## Tag Older Commits

```bash
git tag v0.9 <commit-sha>
```

Tags can reference any commit.

---

## Inspect Tags

List:

```bash
git tag
```

Display:

```bash
git show v1.1
```

---

## Push Tags

Push one:

```bash
git push origin v1.1
```

Push all:

```bash
git push origin --tags
```

Important:

```text
git push

does NOT push tags automatically.
```

---

## Delete Tags

Delete local:

```bash
git tag -d v1.0
```

Delete remote:

```bash
git push origin --delete v1.0
```

---

## Branch vs Tag

| Branch | Tag |
|---------|-----|
| Moves | Fixed |
| Development | Releases |
| Changes over time | Permanent reference |

---

## Typical Release Workflow

```text
Commit

↓

Merge

↓

CI Pipeline

↓

Create Tag

↓

Push Tag

↓

Deploy Release
```
=====================================================================================

# Detached HEAD

## What is Detached HEAD?
- HEAD points directly to a commit instead of a branch.
- No branch moves while working in Detached HEAD.
- Common when checking out tags or historical commits.

## Why use it?
- Inspect old releases
- Debug historical commits
- CI/CD systems
- Production investigation

## Risks
- Commits are not attached to any branch.
- They become unreachable if you leave Detached HEAD.

## Recovery
git switch -c feature/new-branch

or

git branch feature/new-branch <commit>

Use git reflog if you already switched away.

------------------------------

# Git Worktree

## Purpose
Allows multiple working directories from one repository.

## Benefits
- No stash required
- Parallel development
- Faster than cloning
- Shared Git object database

## Commands

git worktree add ../DevOps_Main main

git worktree list

git worktree remove ../DevOps_Main

--------------------------------------------------

