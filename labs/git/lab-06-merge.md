
# Lab 06: Git Merge and Conflict Resolution

## Objective

Practice and understand:

- Fast-forward merge
- Three-way merge
- Merge conflict resolution

---

## Lab 1: Fast-Forward Merge

### Create Feature Branch

```bash
git switch -c feature/merge-demo
```

Create two commits:

```bash
echo "Fast-forward merge demo - commit D" > labs/git/merge-demo.txt
git add labs/git/merge-demo.txt
git commit -m "test: add first fast-forward merge demo commit"

echo "Fast-forward merge demo - commit E" >> labs/git/merge-demo.txt
git add labs/git/merge-demo.txt
git commit -m "test: add second fast-forward merge demo commit"
```

Merge into `main`:

```bash
git switch main
git merge feature/merge-demo
```

### Result

- `main` moved forward to the feature branch commit.
- No merge commit was created.
- Both branch pointers referenced the same commit.

Verify:

```bash
git log --oneline --graph --decorate --all
git show-ref --heads
```

---

## Lab 2: Three-Way Merge

Create a feature branch:

```bash
git switch -c feature/three-way-demo
```

Create and commit a feature change.

Then switch to `main` and create a different commit.

The branches now contain independent commits.

Merge:

```bash
git switch main
git merge feature/three-way-demo
```

### Result

Git created a merge commit because the histories had diverged.

Verify:

```bash
git log --oneline --graph --decorate --all
git cat-file -p HEAD
```

The merge commit contained two `parent` entries.

---

## Lab 3: Merge Conflict

Create a common file:

```text
Environment: Development
```

Modify the same line differently on both branches.

Main branch:

```text
Environment: Staging
```

Feature branch:

```text
Environment: Production
```

Attempt the merge:

```bash
git merge feature/conflict-demo
```

Git reported:

```text
CONFLICT (content)
Automatic merge failed
```

Inspect:

```bash
git status
cat labs/git/conflict-demo.txt
```

Conflict markers:

```text
<<<<<<< HEAD
Environment: Staging
=======
Environment: Production
>>>>>>> feature/conflict-demo
```

Resolve the conflict by editing the file and keeping the required content:

```text
Environment: Production
```

Mark the conflict as resolved:

```bash
git add labs/git/conflict-demo.txt
```

Complete the merge:

```bash
git commit -m "merge: resolve environment conflict"
```

Verify:

```bash
git log --oneline --graph --decorate --all
git cat-file -p HEAD
```

---

## Key Observations

- Fast-forward merge moves the current branch pointer forward.
- Fast-forward merge does not create a merge commit.
- Three-way merge occurs when branches have diverged.
- A merge commit has two parents.
- A conflict occurs when Git cannot safely combine changes.
- `git add` marks a conflicted file as resolved.
- `git commit` completes the merge.

---

## Commands Practiced

```bash
git switch -c <branch>
git switch <branch>
git merge <branch>
git status
git add <file>
git commit
git log --oneline --graph --decorate --all
git show-ref --heads
git cat-file -p HEAD
git merge --abort
```

---

## Lab Result

Successfully practiced:

- Fast-forward merge
- Three-way merge
- Divergent Git history
- Merge commit inspection
- Merge conflict creation
- Manual conflict resolution
