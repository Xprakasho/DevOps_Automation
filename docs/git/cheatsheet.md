
Command	Purpose

git cat-file -p HEAD	          Display commit contents
git cat-file -t HEAD	          Display object type
git ls-tree HEAD	          Show root tree
git ls-tree HEAD:docs	          Show contents of a tree
git rev-parse HEAD	          Show current commit SHA
git diff	                  Compare Working Directory with Index
git diff --cached	          Compare Index with Last Commit
find .git/objects -type f | wc -l	Count Git objects

# Git Cheatsheet

## Repository

git init

git clone

git status

---

## Staging

git add .

git restore --staged

git diff

git diff --cached

---

## Commit

git commit

git log

git log --oneline

git show

---

## Internals

git cat-file

git ls-tree

git rev-parse HEAD

find .git/objects -type f | wc -l

---

git branch

List branches

--------------------

git branch <branch>

Create branch

--------------------

git switch <branch>

Switch branch

--------------------

git switch -c <branch>

Create and switch

--------------------

git show-ref

Display references

--------------------

cat .git/refs/heads/main

Display latest commit SHA

--------------------

git branch --show-current

Display current branch

==================

## Git Merge

Merge a branch into the currently checked-out branch:

```bash
git merge <branch>
```

### Fast-Forward Merge

```text
Current branch is an ancestor
        ↓
Branch pointer moves forward
        ↓
No merge commit
```

### Three-Way Merge

```text
Branches have diverged
        ↓
Git finds merge base
        ↓
Combines Base + Ours + Theirs
        ↓
Creates merge commit
```

### Merge Conflict Workflow

```bash
git merge <branch>

git status

# Edit and resolve conflicted files

git add <resolved-file>

git commit
```

Abort an unfinished merge:

```bash
git merge --abort
```

Inspect branch history:

```bash
git log --oneline --graph --decorate --all
```

Inspect a merge commit:

```bash
git cat-file -p HEAD
```

Display branch references:

```bash
git show-ref --heads
```

### Conflict Markers

```text
<<<<<<< HEAD
Current branch / Ours
=======
Incoming branch / Theirs
>>>>>>> feature-branch
```

### Quick Mental Model

```text
Fast-Forward = Move Pointer

Three-Way = Merge Base + Ours + Theirs → Merge Commit

Conflict = Human Decision → git add → git commit
```

--------------------

## Git Rebase

Rebase the current branch onto another branch:

```bash
git rebase <branch>
```

Typical feature workflow:

```bash
git switch feature
git rebase main
```

Continue after resolving a conflict:

```bash
git add <resolved-file>
git rebase --continue
```

Abort an ongoing rebase:

```bash
git rebase --abort
```

Skip the current commit:

```bash
git rebase --skip
```

Inspect previous reference positions:

```bash
git reflog --oneline
```

### Quick Mental Model

```text
Rebase
   ↓
Replay Commits on New Base
   ↓
New Parent Relationships
   ↓
New Commit SHAs
   ↓
Linear History
```

### Merge vs Rebase

```text
Merge  = Preserve History + Possible Merge Commit

Rebase = Rewrite History + New SHAs + Linear History
```

### Golden Rule

```text
Avoid rebasing shared/public history.

--------------------------------

---

## Git Remotes and Pull Requests

### View Remote Configuration

```bash
git remote -v
git remote show origin
View Branch Tracking
git branch -vv
View Remote-Tracking Branches
git branch -r
View All Branches
git branch -a
Fetch Remote Changes
git fetch origin
Fetch and Remove Stale Remote References
git fetch --prune
Inspect After Fetch
git status
git log --oneline --graph --decorate --all
Update Local Main Safely
git merge --ff-only origin/main
Fetch and Integrate Changes
git pull
Push Current Tracking Branch
git push
Push New Branch and Configure Upstream
git push -u origin <branch-name>
Delete Local Merged Branch
git branch -d <branch-name>
Delete Remote Branch
git push origin --delete <branch-name>
Inspect a Merge Commit
git cat-file -p <commit-sha>
Important Concepts
main
    Local branch

origin/main
    Remote-tracking branch

git fetch
    Download objects + update remote-tracking refs

git pull
    Fetch + integration

git push -u
    Push + configure upstream

PR base
    Destination branch

PR compare
    Source branch

Merge commit
    Commit with multiple parents

git fetch --prune
    Remove stale remote-tracking references
Safe Remote Update Workflow
git fetch origin
        ↓
git status
        ↓
git log --oneline --graph --decorate --all
        ↓
git merge --ff-only origin/main
Complete Pull Request Workflow
git switch -c feature/demo
        ↓
Make changes
        ↓
git add
        ↓
git commit
        ↓
git push -u origin feature/demo
        ↓
Create PR
        ↓
Verify base and compare
        ↓
Merge PR
        ↓
git switch main
        ↓
git fetch origin
        ↓
Inspect graph
        ↓
git merge --ff-only origin/main
        ↓
git branch -d feature/demo
        ↓
git push origin --delete feature/demo
        ↓
git fetch --prune

-----------------------------------

# Git Recovery

## Restore Working Tree from Index

```bash
git restore <file>
Index → Working Tree
Unstage a File
git restore --staged <file>
HEAD → Index
Restore Index and Working Tree from HEAD
git restore --source=HEAD --staged --worktree <file>
Reset Modes
git reset --soft HEAD~1
git reset --mixed HEAD~1
git reset --hard HEAD~1
soft  = Move HEAD
mixed = Move HEAD + Reset Index
hard  = Move HEAD + Reset Index + Working Tree
Inspect Reflog
git reflog
git reflog --oneline -10
Recover a Lost Commit
git reflog
git reset --hard <commit-SHA>
Revert a Commit
git revert <commit-SHA>
Continue or Abort Revert
git revert --continue
git revert --abort
git revert --skip
Recovery Inspection Commands
git status
git diff
git diff --cached
git log --oneline --graph --decorate --all
git reflog
git show HEAD
cat -A <file>
Reset vs Revert
reset  → Move branch pointer / rewrite local history
revert → Create inverse commit / preserve history
Conflict Resolution Workflow
git status
      ↓
Inspect conflict
      ↓
Edit file
      ↓
git add <file>
      ↓
git diff --cached
      ↓
git revert --continue
