
# Git Basics

## Objective

Understand the fundamentals of Git, why it is used, and the basic workflow for tracking source code.

---

# What is Version Control?

Version Control is a system that records changes made to files over time.

It allows developers to:

- Track changes
- Restore previous versions
- Collaborate with multiple developers
- Maintain project history

---

# What is Git?

Git is a Distributed Version Control System (DVCS) created by Linus Torvalds in 2005.

Git stores snapshots of a project instead of simply tracking file differences.

Key Features:

- Distributed architecture
- Fast performance
- Data integrity using SHA hashes
- Lightweight branching
- Offline development

---

# Git vs GitHub

| Git | GitHub |
|------|---------|
| Version Control System | Cloud hosting platform |
| Installed locally | Hosted online |
| Tracks code history | Stores Git repositories |
| Works offline | Requires internet for remote operations |

Example:

Git manages your repository.

GitHub stores the repository online.

---

# Git Repository

A Git Repository is a project directory that Git manages.

It contains:

- Source code
- Documentation
- Configuration
- Complete version history

Git stores repository metadata inside:

```
.git/
```

---

# Working Directory

The Working Directory contains the files currently being edited.

Example:

```
README.md
main.py
Dockerfile
```

Files here are modified before being staged.

---

# Git Workflow

```
Working Directory
        │
        ▼
git add
        │
        ▼
Staging Area (Index)
        │
        ▼
git commit
        │
        ▼
Local Repository
        │
        ▼
git push
        │
        ▼
GitHub Repository
```

---

# Basic Git Commands

## Initialize Repository

```bash
git init
```

---

## Clone Repository

```bash
git clone <repository-url>
```

---

## Check Status

```bash
git status
```

---

## Stage Files

```bash
git add .
```

or

```bash
git add README.md
```

---

## Commit

```bash
git commit -m "Initial commit"
```

---

## Push

```bash
git push origin main
```

---

## Pull

```bash
git pull origin main
```

---

# First Repository Setup

Our repository structure:

```
DevOps_Automation/

├── app/
├── assets/
├── docs/
├── infrastructure/
├── labs/
├── projects/
├── scripts/
├── templates/
├── README.md
├── LICENSE
└── .gitignore
```

This structure will be used throughout the DevOps learning journey.

---

# Best Practices

- Commit frequently.
- Write meaningful commit messages.
- Keep commits focused on one change.
- Review changes using `git status`.
- Never commit sensitive information.
- Use feature branches for development.

---

# Production Relevance

Git is used in almost every modern software project.

Examples:

- GitHub
- GitLab
- Azure DevOps
- Bitbucket

CI/CD tools such as GitHub Actions, GitLab CI, Jenkins, and Argo CD all integrate with Git repositories.

---

# Key Takeaways

- Git is a Distributed Version Control System.
- Git tracks project history.
- Git stores repositories locally.
- GitHub hosts repositories remotely.
- The standard Git workflow is:

```
Working Directory
        ↓
Staging Area
        ↓
Local Repository
        ↓
Remote Repository
```

---

# Summary

This chapter introduced Git fundamentals, repository structure, the Git workflow, and the basic commands required to create and manage a Git repository.
