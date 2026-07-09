
# Git Workflow - Internal Commit Lifecycle

## Objective

Understand what happens internally when Git creates a new commit.

---

# Git Workflow

```
Working Directory
        │
    git add
        ▼
Index (Staging Area)
        │
   git commit
        ▼
Local Repository
        │
    git push
        ▼
Remote Repository (GitHub)
```

---

# What Happens During git add

- Git compares the Working Directory with the Index.
- Changed files are copied into the Index.
- No commit is created.
- The Local Repository is unchanged.

---

# What Happens During git commit

Git performs several internal operations:

1. Creates new Blob objects for new or modified file contents.
2. Reuses existing Blob objects for unchanged files.
3. Creates new Tree objects for directories whose contents changed.
4. Creates one new Commit object.
5. Updates the current branch pointer.
6. HEAD continues pointing to the current branch.

---

# Commit Object Structure

```
Commit
│
├── Tree
├── Parent Commit
├── Author
├── Committer
└── Commit Message
```

Example:

```
tree 80f2096...
parent eca3458...
author Om ...
committer Om ...

docs: add Git learning modules and hands-on labs
```

---

# Why Git Doesn't Duplicate the Repository

Git stores objects using SHA hashes.

Only changed objects are created.

Unchanged objects are reused.

Example:

Commit 1

README → Blob A

LICENSE → Blob B

Commit 2 (README modified)

README → Blob C (New)

LICENSE → Blob B (Reused)

---

# Git Object Flow

HEAD

↓

Branch

↓

Commit

↓

Tree

↓

Blob

---

# Production Relevance

GitHub Actions checks out a specific Commit SHA.

Argo CD synchronizes Kubernetes using a specific Git commit.

Because commits are immutable, deployments are reproducible and traceable.

---

# Key Takeaways

- git add updates the Index.
- git commit creates new Git objects.
- Only changed objects are stored.
- Commits point to Trees.
- Trees point to Blobs.
- Branches move after commits.
- HEAD continues pointing to the current branch.
