
# Git Merge and Merge Conflicts

## Objective

Understand how Git integrates branches using fast-forward and three-way merges, and how merge conflicts are identified and resolved.

---

## What is Git Merge?

Git merge integrates the history and changes of one branch into another branch.

The branch currently referenced by HEAD is the branch that receives the merge result.

Example:

```bash
git switch main
git merge feature
```

Here, `feature` is merged into `main`.

---

## 1. Fast-Forward Merge

A fast-forward merge is possible when the current branch has no independent commits after the feature branch was created.

### Before Merge

```text
          D --- E  feature
         /
A --- B --- C  main
```

Internally:

```text
HEAD → main → C

feature → E
```

### Command

```bash
git switch main
git merge feature
```

### After Merge

```text
A --- B --- C --- D --- E
                        ↑
                   main, feature
```

Internally:

```text
HEAD → main → E

feature → E
```

### What Happened?

- No new merge commit was created.
- The `main` branch pointer moved from C to E.
- HEAD remained attached to `main`.
- The feature branch pointer did not move.

### Key Concept

> Fast-forward merge = move the current branch pointer forward.

---

## 2. Three-Way Merge

A three-way merge is required when both branches contain independent commits.

### Before Merge

```text
          F  feature
         /
A --- B --- C
             \
              G  main
```

Git cannot move `main` directly to `F` because the branches have diverged.

### Three Inputs Used by Git

Git uses:

1. Merge Base — common ancestor
2. Ours — current branch tip
3. Theirs — branch being merged

Example:

```text
Merge Base → C

Ours       → G

Theirs     → F
```

### Command

```bash
git switch main
git merge feature
```

### After Merge

```text
          F --------
         /           \
A --- B --- C         M  main
             \       /
              G -----
```

Git creates a new merge commit `M`.

### Merge Commit

A normal commit usually has one parent.

A merge commit has two or more parents.

This can be inspected using:

```bash
git cat-file -p HEAD
```

Example:

```text
tree <tree-sha>

parent <main-commit-sha>

parent <feature-commit-sha>

author ...

committer ...

Merge branch 'feature'
```

### Key Concept

> Three-way merge = combine divergent histories and create a merge commit.

---

## 3. Merge Conflict

A merge conflict occurs when Git cannot safely determine how to combine changes automatically.

One common example is when two branches modify the same line differently.

### Common Ancestor

```text
Environment: Development
```

### Main Branch

```text
Environment: Staging
```

### Feature Branch

```text
Environment: Production
```

During the merge, Git cannot determine which value should become the final result.

---

## Conflict Markers

Git adds conflict markers to the affected file:

```text
<<<<<<< HEAD
Environment: Staging
=======
Environment: Production
>>>>>>> feature/conflict-demo
```

Meaning:

```text
<<<<<<< HEAD

Current branch version / Ours

=======

Incoming branch version / Theirs

>>>>>>> feature branch
```

---

## Checking Conflict Status

```bash
git status
```

Example:

```text
Unmerged paths:

both modified: labs/git/conflict-demo.txt
```

---

## Resolving a Merge Conflict

### Step 1: Open the conflicted file

```bash
vi labs/git/conflict-demo.txt
```

### Step 2: Decide the correct final content

Example:

```text
Environment: Production
```

### Step 3: Remove the conflict markers

Remove:

```text
<<<<<<< HEAD
=======
>>>>>>> feature/conflict-demo
```

### Step 4: Stage the resolved file

```bash
git add labs/git/conflict-demo.txt
```

During conflict resolution, `git add` tells Git that the file has been resolved.

### Step 5: Complete the merge

```bash
git commit -m "merge: resolve environment conflict"
```

### Step 6: Verify the history

```bash
git log --oneline --graph --decorate --all
```

### Step 7: Inspect the merge commit

```bash
git cat-file -p HEAD
```

---

## Aborting a Merge

If the merge should not continue:

```bash
git merge --abort
```

This attempts to return the repository to its state before the merge started.

---

## Fast-Forward vs Three-Way Merge

| Feature | Fast-Forward | Three-Way |
|---|---|---|
| Divergent history | No | Yes |
| Independent commits on both branches | No | Yes |
| New merge commit | No | Yes |
| Current branch pointer moves | Yes | Yes, to the new merge commit |
| Merge base required for calculation | Trivial ancestry relationship | Yes |
| Merge commit parents | N/A | Two or more |

---

## Merge Conflict Lifecycle

```text
git merge
    |
    v
Git detects conflicting changes
    |
    v
Merge pauses
    |
    v
Inspect with git status
    |
    v
Edit conflicted files
    |
    v
Remove conflict markers
    |
    v
git add
    |
    v
git commit
    |
    v
Merge completed
```

---

## Useful Commands

```bash
git merge <branch>
```

Merge a branch into the current branch.

```bash
git log --oneline --graph --decorate --all
```

Display the commit graph.

```bash
git show-ref --heads
```

Display local branch references and their commit SHAs.

```bash
git cat-file -p HEAD
```

Inspect the current commit object.

```bash
git status
```

Check the current merge and conflict state.

```bash
git merge --abort
```

Abort an unfinished merge.

---

## Common Mistakes

- Merging while checked out on the wrong branch.
- Thinking HEAD moves directly between commits during a normal merge.
- Thinking fast-forward creates a merge commit.
- Forgetting that three-way merge uses a common ancestor.
- Editing conflict markers incorrectly.
- Forgetting to run `git add` after resolving a conflict.
- Thinking a merge conflict means Git is broken.
- Pushing changes without reviewing the commit graph.

---

## Production Relevance

Merge conflicts commonly occur when multiple developers work on overlapping areas of a codebase.

Before completing a production merge:

- Review the target and source branches.
- Pull or fetch recent changes.
- Review the commit history.
- Resolve conflicts carefully.
- Run application tests.
- Review the final diff.
- Use Pull Requests or Merge Requests for peer review.

---

## Interview Summary

### What is a fast-forward merge?

A fast-forward merge occurs when the current branch tip is an ancestor of the branch being merged. Git integrates the branch by moving the current branch pointer forward without creating a merge commit.

### What is a three-way merge?

A three-way merge occurs when branches have diverged. Git uses the merge base, the current branch tip, and the incoming branch tip to calculate the merged result and normally creates a merge commit.

### What is a merge conflict?

A merge conflict occurs when Git cannot automatically determine the correct merged content. Human intervention is required to edit the conflicting files, stage the resolution, and complete the merge.

---

## Key Takeaways

- Merge integrates changes from different branches.
- The currently checked-out branch receives the merge result.
- Fast-forward merge moves a branch pointer.
- Fast-forward merge creates no merge commit.
- Three-way merge handles divergent histories.
- A merge commit normally contains two parents.
- Merge conflicts require human decisions.
- `git add` marks a conflict as resolved.
- `git commit` completes the conflict-resolution merge.
- `git merge --abort` can cancel an unfinished merge.

---

## Final Mental Model

```text
FAST-FORWARD

Current branch is an ancestor
        |
        v
Move branch pointer forward
        |
        v
No merge commit
```

```text
THREE-WAY MERGE

Branches diverged
        |
        v
Find merge base
        |
        v
Compare Base + Ours + Theirs
        |
        v
Combine changes
        |
        v
Create merge commit
```

```text
MERGE CONFLICT

Git cannot safely combine changes
        |
        v
Pause merge
        |
        v
Human resolves content
        |
        v
git add
        |
        v
git commit
        |
        v
Merge completed
