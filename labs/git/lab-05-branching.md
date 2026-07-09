
# Lab 05 – Git Branching

## Objective

Understand how Git branches work and observe branch pointer movement.

---

## Prerequisites

- Existing Git repository
- At least two commits

---

## Steps

### Display Branches

```bash
git branch
```

---

### Show References

```bash
git show-ref
```

---

### Explore Branch References

```bash
ls -R .git/refs
```

---

### View Branch SHA

```bash
cat .git/refs/heads/main
```

```bash
cat .git/refs/heads/feature/repository-foundation
```

---

### Switch Branch

```bash
git switch feature/repository-foundation
```

---

### Verify Current Branch

```bash
git branch
```

---

### Switch Back

```bash
git switch main
```

---

## Verification

Verify that:

- HEAD changes.
- Branch pointers remain unchanged.
- Working Directory changes only if the target commit differs.

---

## Skills Gained

- Inspect branch references.
- Read branch SHA values.
- Switch branches.
- Understand branch pointers.

---

## Learning Check

1. What is a Git branch?
2. What does HEAD point to?
3. What happens internally during `git switch`?
4. Do commits move?
5. Why are Git branches lightweight?

---

## Next Lab

➡️ Lab 06 – Fast Forward Merge
