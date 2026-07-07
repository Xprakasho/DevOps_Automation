
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
