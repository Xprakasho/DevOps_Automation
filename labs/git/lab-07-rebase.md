
# Lab 07: Git Rebase

## Objective

Practice and understand:

- Rebase workflow
- Commit SHA changes
- Linear history
- Fast-forward merge after rebase
- Rebase conflict resolution
- Reflog inspection

---

## Lab 1: Basic Rebase

### Create Feature Branch

```bash
git switch -c feature/rebase-demo
```

Create and commit two feature changes.

### Create Independent Main Change

```bash
git switch main
```

Create and commit an independent change on `main`.

### Inspect Diverged History

```bash
git log --oneline --graph --decorate --all
```

Expected structure:

```text
          D --- E  feature
         /
A --- B --- C
             \
              F  main
```

### Rebase Feature onto Main

```bash
git switch feature/rebase-demo
git rebase main
```

Inspect:

```bash
git log --oneline --graph --decorate --all
git show-ref --heads
```

Expected result:

```text
A --- B --- C --- F --- D' --- E'
                  ↑             ↑
                 main         feature
```

Observation:

```text
D ≠ D'
E ≠ E'
```

Rebase creates new commits because parent relationships change.

---

## Lab 2: Fast-Forward After Rebase

```bash
git switch main
git merge feature/rebase-demo
```

Inspect:

```bash
git log --oneline --graph --decorate --all
```

Observation:

- `main` moves forward.
- No merge commit is created.
- History remains linear.

---

## Lab 3: Inspect Old Commits

```bash
git reflog --oneline
```

Inspect an old commit:

```bash
git cat-file -p <old-commit-sha>
```

Observation:

Old commits may still exist even when branches no longer reference them.

---

## Lab 4: Rebase Conflict

Create a common file and make different changes on `main` and the feature branch.

Start rebase:

```bash
git switch feature/rebase-conflict
git rebase main
```

Inspect:

```bash
git status
cat <conflicted-file>
```

Resolve the conflict:

```bash
git add <resolved-file>
git rebase --continue
```

Abort if required:

```bash
git rebase --abort
```

---

## Key Learning

```text
Rebase
   ↓
Replay Commits
   ↓
New Parent Relationships
   ↓
New Commit Objects
   ↓
New SHAs
   ↓
Linear History
```

Golden Rule:

> Avoid rebasing shared history that other developers are already using.
