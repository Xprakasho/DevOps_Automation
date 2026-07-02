
# Lab 03 – Staging Area

## Objective

Understand how changes move from the Working Directory to the Staging Area (Index) before becoming part of a commit.

---

## Prerequisites

- Git repository available
- At least one existing commit

---

## Steps

### 1. Check Repository Status

```bash
git status
```

Expected:

```
working tree clean
```

---

### 2. Modify a File

Edit `README.md` and add a new line.

Example:

```text
Learning Git Internals - Day 2
```

---

### 3. View Unstaged Changes

```bash
git status
```

Observe:

```
Changes not staged for commit
```

---

### 4. Compare Working Directory with Index

```bash
git diff
```

Observe the modifications made to the file.

---

### 5. Stage the File

```bash
git add README.md
```

---

### 6. Verify Staged Changes

```bash
git status
```

Observe:

```
Changes to be committed
```

---

### 7. Compare Index with Last Commit

```bash
git diff --cached
```

Observe the staged changes.

---

### 8. Create a Commit

```bash
git commit -m "docs: update README"
```

---

### 9. Verify Commit History

```bash
git log --oneline -2
```

---

## Verification

Verify that you can:

- Identify unstaged changes.
- Stage specific files.
- View staged changes.
- Create a new commit.

---

## Skills Gained

- Use `git status`
- Use `git diff`
- Stage changes with `git add`
- View staged changes with `git diff --cached`
- Create commits

---

## Learning Check

1. What is the difference between the Working Directory and the Index?
2. What does `git add` do?
3. Why does `git diff` become empty after `git add`?
4. What does `git diff --cached` compare?
5. Why does Git use a Staging Area?

---

## Next Lab

