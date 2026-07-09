
# Git Branching

## Objective

Understand how Git branches work internally and why they are lightweight.

---

# What is a Branch?

A Git branch is a lightweight movable reference (pointer) to a commit.

A branch does not copy the repository or duplicate commits.

---

# Branch Architecture

HEAD
 │
 ▼
Branch
 │
 ▼
Commit
 │
 ▼
Tree
 │
 ▼
Blob

---

# Branch References

Git stores local branches under:

.git/refs/heads/

Example:

main

feature/repository-foundation

Each branch file contains only the latest Commit SHA.

---

# HEAD

HEAD is a special reference that points to the currently checked-out branch.

Example:

HEAD

↓

main

HEAD does not normally point directly to a commit.

---

# Creating a Branch

Command:

```bash
git branch feature/login
```

Internally:

- Creates a new branch reference.
- Stores the current Commit SHA.
- No files are copied.
- No commits are duplicated.

---

# Switching Branches

Command:

```bash
git switch feature/login
```

Internal Flow:

HEAD
↓

Target Branch
↓

Target Commit
↓

Tree
↓

Update Index

↓

Update Working Directory

If both branches point to the same commit, only HEAD changes.

The Working Directory remains unchanged.

---

# Branch Pointer Movement

Before Commit

HEAD

↓

main

↓

Commit C

feature

↓

Commit C

After Commit

HEAD

↓

main

↓

Commit D

↓

Commit C

feature

↓

Commit C

Only the currently checked-out branch moves.

---

# Production Relevance

Every modern Git platform uses branches.

Examples:

- GitHub
- GitLab
- Azure DevOps
- Bitbucket

Developers work on feature branches before merging into main.

---

# Common Mistakes

- Thinking branches are copies of repositories.
- Committing to the wrong branch.
- Forgetting to check the current branch.
- Switching branches with uncommitted changes.

---

# Key Takeaways

- Branches are lightweight pointers.
- HEAD points to the current branch.
- Commits never move.
- Branches move.
- Git updates the Working Directory when switching to a different commit.

---

# Summary

Git branches provide an efficient mechanism for parallel development by storing only a reference to a commit instead of duplicating repository data.
