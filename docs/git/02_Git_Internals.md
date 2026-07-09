
# Git Internals

## Objective

Understand how Git works internally instead of memorizing commands.

By the end of this chapter you should understand:

- What `.git` is
- What `HEAD` is
- What a branch really is
- What a commit object contains
- How Git stores history
- Why Git operations are fast

---

# Git Architecture

A Git repository consists of two major parts.

```text
DevOps_Automation/
│
├── .git/              ← Git Database
│
├── README.md
├── docs/
├── labs/
├── scripts/
└── ...
```

The project files are called the **Working Directory**.

The `.git` directory stores all Git metadata including:

- Commit history
- Branches
- Tags
- Configuration
- Objects
- References

Without the `.git` directory, Git has no history.

---

# Git Workflow

Every change follows the same path.

```text
Working Directory
        │
        ▼
Staging Area (Index)
        │
        ▼
Local Repository (.git)
        │
        ▼
Remote Repository (GitHub)
```

This is one of the most important diagrams in Git.

---

# The HEAD Reference

Command:

```bash
cat .git/HEAD
```

Output:

```text
ref: refs/heads/main
```

HEAD **does not point directly to a commit.**

HEAD points to the currently checked-out branch.

Example:

```text
HEAD
 │
 ▼
refs/heads/main
```

If you switch branches:

```bash
git switch feature/repository-foundation
```

HEAD moves to:

```text
HEAD
 │
 ▼
refs/heads/feature/repository-foundation
```

---

# Branches

A branch is **not** a copy of your project.

A branch is simply a reference (pointer) to a commit.

Example:

```bash
cat .git/refs/heads/main
```

Output:

```text
9caf5f110a587a7406700fcab571fedcc1643e8b
```

That SHA identifies the latest commit on the `main` branch.

Similarly,

```bash
cat .git/refs/heads/feature/repository-foundation
```

returns

```text
39e2bd057379a56b4a1a7aec4928fde11e9d1969
```

which is the latest commit on the feature branch.

---

# Repository State

Current repository layout:

```text
                HEAD
                 │
                 ▼
               main
                 │
                 ▼
Commit B (9caf5f...)
                 │
                 ▼
Commit A (39e2bd...)
                 ▲
                 │
feature/repository-foundation
```

The `main` branch is one commit ahead of the feature branch.

---

# Git Objects

Git stores everything as objects.

There are four object types.

```text
Blob
Tree
Commit
Tag
```

---

## Blob

Stores file contents.

Example:

README.md

↓

Blob

---

## Tree

Stores directory structure.

Example:

docs/

↓

Tree

---

## Commit

Stores repository metadata.

A commit contains:

- Tree reference
- Parent commit
- Author
- Committer
- Commit message

Example:

```bash
git cat-file -p HEAD
```

Output:

```text
tree 0032179601fc9132d75a1dfeea344e97bdaafdb6
parent 39e2bd057379a56b4a1a7aec4928fde11e9d1969
author ...
committer ...

docs: initialize repository foundation
```

Explanation:

tree → Snapshot of the repository

parent → Previous commit

author → Person who created the change

committer → Person who created the commit

message → Commit description

---

# refs Directory

```text
refs/

├── heads/
├── remotes/
└── tags/
```

## refs/heads

Local branches.

Example:

- main
- feature/repository-foundation

---

## refs/remotes

Remote tracking branches.

Example:

- origin/main
- origin/feature/repository-foundation

---

## refs/tags

Release tags.

Examples:

v0.1.0

v1.0.0

---

# Why Git Is Fast

Git does not copy an entire project when creating a branch.

Instead:

```text
feature/docker

↓

Commit SHA
```

Creating a branch only creates another reference.

That is why branch creation is almost instantaneous.

---

# Key Takeaways

- `.git` is the Git database.
- HEAD points to the current branch.
- A branch points to a commit.
- A commit points to a tree.
- A tree points to blobs.
- Git stores objects instead of files.

---

# Interview Questions

### What is HEAD?

HEAD is a symbolic reference to the currently checked-out branch.

---

### What is a Git branch?

A Git branch is a named reference pointing to a commit.

---

### Why is Git branch creation so fast?

Because Git creates only a new reference to an existing commit instead of copying project files.

---

### What are the four Git object types?

- Blob
- Tree
- Commit
- Tag

---

# Production Notes

Modern DevOps tools rely heavily on Git.

Examples:

- GitHub Actions triggers workflows from Git commits.
- Argo CD continuously monitors Git repositories.
- Terraform code is version-controlled in Git.
- Kubernetes manifests are maintained in Git.
- Git becomes the single source of truth in GitOps.

## Tree Object

A Tree Object represents a snapshot of a directory.

A Tree contains references to:

- Blob Objects (files)
- Other Tree Objects (subdirectories)

A Commit points to one Root Tree.

Every directory inside the repository is represented as a separate Tree.

Example:

Commit
    │
    ▼
Root Tree
    │
    ├── README.md → Blob
    ├── docs → Tree
    ├── labs → Tree
    └── scripts → Tree

Trees make Git efficient because unchanged Trees and Blobs are reused between commits.b

Example:

100644 blob 159ea327... README.md

- 100644 → Regular file
- blob → File content object
- SHA → Unique identifier of the file content
- README.md → File name

Example:

040000 tree 192c585... docs

- 040000 → Directory
- tree → Directory object
- SHA → Tree identifier
- docs → Directory name

Git stores directories recursively as Tree Objects.

## Blob Object

A Blob (Binary Large Object) stores the contents of a file.

A Blob does not store:

- File name
- File path
- Permissions

It stores only the file content.

Example:

```text
README.md
```

↓

```text
Blob
```

↓

```text
SHA
```

Git identifies Blobs by their content.

If two files have identical contents, they reference the same Blob object.

This makes Git storage efficient and avoids duplication.

=====================================================================================================

# The Index (Staging Area)

The Index, also called the Staging Area, is an intermediate area between the Working Directory and the Local Repository.

Workflow:

```text
Working Directory
        │
    git add
        ▼
Index (Staging Area)
        │
   git commit
        ▼
Local Repository
```

Purpose:

- Prepare changes before committing.
- Allow selective commits.
- Review staged changes before creating permanent history.

The Index is stored in:

```text
.git/index
```

Key Point:

`git add` does **not** create a commit.

It copies the current version of a file from the Working Directory into the Index.

The commit is created only when `git commit` is executed.

============================================================================================================================

The Three Git Areas- Working Directory ↔ Index and Index ↔ Last Commit

git diff vs git diff --cached

How git status works
