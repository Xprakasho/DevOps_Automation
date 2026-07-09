
# Lab 02 – Git Internals

## Objective

Explore Git's internal structure and inspect Git objects such as HEAD, Commit, Tree, and Blob.

---

## Prerequisites

- Git installed
- Repository created
- At least one commit available

---

## Steps

### 1. Navigate to the Repository

```bash
cd ~/DevOps_Automation/DevOps_Automation
```

---

### 2. Explore the .git Directory

```bash
tree .git
```

Observe:

- HEAD
- refs/
- objects/
- logs/
- index/

---

### 3. Display Current Commit SHA

```bash
git rev-parse HEAD
```

Expected:

```
<commit-sha>
```

---

### 4. Verify Object Type

```bash
git cat-file -t HEAD
```

Expected:

```
commit
```

---

### 5. Inspect Commit Object

```bash
git cat-file -p HEAD
```

Observe:

- Tree
- Parent
- Author
- Committer
- Commit Message

---

### 6. Display Root Tree

```bash
git ls-tree HEAD
```

Observe:

- Blob objects (files)
- Tree objects (directories)

---

### 7. Inspect a Tree Object

Example:

```bash
git ls-tree HEAD:docs
```

or

```bash
git cat-file -p <tree-sha>
```

---

### 8. Inspect a Blob Object

```bash
git cat-file -p <blob-sha>
```

Observe the file contents stored inside the Blob.

---

## Verification

You should be able to identify:

- Current Commit SHA
- Tree Object
- Blob Object
- HEAD
- Repository structure inside `.git`

---

## Skills Gained

- Explore the `.git` directory
- Inspect Commit objects
- Inspect Tree objects
- Inspect Blob objects
- Understand how Git stores repository data

---

## Next Lab

➡️ **Lab 03 – Staging Area**
