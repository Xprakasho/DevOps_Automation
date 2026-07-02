
# Lab 01 – Repository Setup

## Objective

Create a Git repository and push the initial project structure to GitHub.

---

## Prerequisites

- Git installed
- GitHub repository created

---

## Steps

### Clone Repository

```bash
git clone <repository-url>
cd DevOps_Automation
```

---

### Verify Repository

```bash
git status
```

Expected:

```
working tree clean
```

---

### Create Project Structure

```bash
mkdir -p app assets docs infrastructure labs projects scripts templates
```

---

### Create Initial Files

```bash
touch README.md LICENSE .gitignore
```

---

### Stage Files

```bash
git add .
```

---

### Commit

```bash
git commit -m "docs: initialize repository foundation"
```

---

### Push

```bash
git push origin main
```

---

## Verification

- Repository created
- Files visible on GitHub
- Commit history updated

---

## Skills Gained

- Clone repository
- Stage files
- Commit changes
- Push to GitHub
