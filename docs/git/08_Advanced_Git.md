
# Advanced Git

## 1. Introduction

Advanced Git operations help engineers temporarily manage work, transfer specific changes between branches, recover from workflow interruptions, and maintain repository history safely.

This document begins with Git Stash.

Git Stash is commonly used when work is incomplete but the engineer needs to temporarily switch context without creating a commit.

---

# Part 1: Git Stash

## 2. What Is Git Stash?

Git Stash temporarily stores changes from the Working Tree and Index and restores the repository to a clean state.

Typical scenario:

```text
Working on feature
        |
        v
Incomplete changes exist
        |
        v
Urgent task requires branch switch
        |
        v
git stash
        |
        v
Working Tree becomes clean
        |
        v
Complete urgent work
        |
        v
git stash apply / pop
        |
        v
Continue previous work
```

Git Stash is useful when changes are not ready for a normal commit.

---

## 3. Git Stash Mental Model

The primary Git areas are:

```text
HEAD
  |
  v
Index / Staging Area
  |
  v
Working Tree
```

Git Stash introduces temporary storage for changes:

```text
HEAD
  |
  v
Index
  |
  v
Working Tree
  |
  | git stash
  v
Stash
```

Important:

```text
git stash does not move HEAD
git stash does not move the branch pointer
```

Instead, Git stores the changes and restores the Working Tree and Index to a clean state.

---

## 4. Creating a Basic Stash

Command:

```bash
git stash
```

A more descriptive method is:

```bash
git stash push -m "description"
```

Example:

```bash
git stash push -m "day9: staged and unstaged demo"
```

The `push` subcommand creates a stash entry.

The `-m` option adds a meaningful description.

Important:

```text
git stash push
```

does not mean pushing changes to a remote repository.

It means creating and pushing a new entry onto the Git stash stack.

---

## 5. Inspecting Stashes

List existing stash entries:

```bash
git stash list
```

Example:

```text
stash@{0}: On feature: latest work
stash@{1}: On feature: previous work
```

Git Stash behaves like a stack:

```text
Newest stash
    |
    v
stash@{0}

stash@{1}

stash@{2}
    |
    v
Older stash
```

Every newly created stash becomes:

```text
stash@{0}
```

Older entries move down the stack.

---

## 6. Inspecting Stash Content

Display a stash summary:

```bash
git stash show --stat stash@{0}
```

Display the complete patch:

```bash
git stash show -p stash@{0}
```

Example:

```bash
git stash show -p stash@{0}
```

This allows engineers to inspect changes before restoring them.

---

## 7. Applying a Stash

Command:

```bash
git stash apply
```

By default, this applies:

```text
stash@{0}
```

Important behavior:

```text
HEAD          -> unchanged
Branch        -> unchanged
Changes       -> restored
Stash entry   -> retained
```

Therefore:

```text
apply = restore changes + keep stash
```

---

## 8. Applying a Specific Stash

When multiple stash entries exist, a specific stash can be selected.

Example:

```bash
git stash apply 'stash@{1}'
```

This restores the selected stash instead of the latest stash.

Example:

```text
stash@{0} -> untracked file demo
stash@{1} -> staged and unstaged demo
```

Command:

```bash
git stash apply 'stash@{1}'
```

Result:

```text
stash@{1} changes restored
stash@{0} remains
stash@{1} remains
```

Important:

```text
git stash apply does not delete the stash entry
```

---

## 9. Git Stash Pop

Command:

```bash
git stash pop
```

`pop` applies the stash changes and removes the stash entry after successful application.

Concept:

```text
git stash pop
        |
        +--> Restore changes
        |
        +--> Remove successfully applied stash
```

Important comparison:

```text
git stash apply
    -> restore changes
    -> keep stash

git stash pop
    -> restore changes
    -> remove stash after successful application
```

---

## 10. Stashing Staged and Unstaged Changes

Consider a file containing:

```text
Application: Payment-Service
Environment: Development
Debug: Enabled
```

Suppose:

```text
Environment: Development -> staged
Debug: Enabled           -> unstaged
```

Status:

```text
MM file
```

The first `M` represents the difference between:

```text
HEAD <-> Index
```

The second `M` represents the difference between:

```text
Index <-> Working Tree
```

Running:

```bash
git stash push -m "staged and unstaged demo"
```

stores both staged and unstaged changes.

After the stash:

```text
Index        -> clean
Working Tree -> clean
HEAD         -> unchanged
```

---

## 11. Default Stash Apply Behavior

Suppose a stash originally contained:

```text
Environment: Development -> staged
Debug: Enabled           -> unstaged
```

Running:

```bash
git stash apply
```

restores the content.

However, by default, the original staged state is not restored.

Result:

```text
Environment: Development -> unstaged
Debug: Enabled           -> unstaged
```

Status:

```text
 M file
```

Important principle:

```text
git stash apply
    |
    v
Restores file content

But does not restore the original Index state by default
```

---

## 12. Restoring the Index with `--index`

Command:

```bash
git stash apply --index
```

This attempts to restore both:

```text
Working Tree state
+
Index state
```

Example original state:

```text
Environment: Development -> staged
Debug: Enabled           -> unstaged
```

After:

```bash
git stash apply --index
```

Result:

```text
Environment: Development -> staged
Debug: Enabled           -> unstaged
```

Status:

```text
MM file
```

Comparison:

```text
git stash apply

Content restored
Original staging state not restored
```

versus:

```text
git stash apply --index

Content restored
Original staging state restored
```

---

## 13. Normal Stash and Untracked Files

Create an untracked file:

```bash
echo "Temporary configuration file" > temporary-file.txt
```

Status:

```text
?? temporary-file.txt
```

Run:

```bash
git stash push -m "normal stash"
```

Possible output:

```text
No local changes to save
```

Reason:

```text
Normal git stash ignores untracked files
```

The untracked file remains in the Working Tree.

---

## 14. Stashing Untracked Files

Use:

```bash
git stash push -u -m "stash untracked file"
```

The `-u` option means:

```text
--include-untracked
```

Result:

```text
Tracked changes   -> stashed
Untracked files   -> stashed
Working Tree      -> clean
Index             -> clean
HEAD              -> unchanged
```

The untracked file disappears from the Working Tree because it is stored in the stash.

Important:

```text
git stash
    |
    v
Tracked changes only

git stash -u
    |
    v
Tracked changes + untracked files
```

---

## 15. Multiple Stashes

Git can store multiple stash entries.

Example:

```text
stash@{0}: untracked file demo
stash@{1}: staged and unstaged demo
```

The newest stash is always:

```text
stash@{0}
```

A specific stash can be restored using:

```bash
git stash apply 'stash@{1}'
```

Important:

```text
apply does not remove the selected stash
```

Therefore, after successful application:

```text
stash@{0} -> remains
stash@{1} -> remains
```

---

## 16. Git Stash Command Comparison

| Command | Restores Changes | Removes Stash | Restores Index State |
|---|---|---|---|
| `git stash apply` | Yes | No | No |
| `git stash apply --index` | Yes | No | Yes |
| `git stash pop` | Yes | Yes, after successful application | No by default |
| `git stash push -u` | Creates stash | No | Stores tracked and untracked changes |

---

## 17. Practical DevOps Use Cases

Git Stash is useful when:

- An urgent production issue requires switching branches.
- A developer needs to pull or rebase but has incomplete local changes.
- Infrastructure code is partially modified but not ready for commit.
- A temporary experiment must be saved before changing context.
- A developer needs to compare work across branches.
- Local debugging changes should not yet become part of repository history.

Example workflow:

```bash
git status

git stash push -m "WIP: Terraform networking changes"

git switch main

git pull

git switch feature/networking

git stash apply
```

---

## 18. Key Mental Model

Remember:

```text
git stash
    |
    +--> HEAD does not move
    |
    +--> Branch pointer does not move
    |
    +--> Changes are temporarily stored
    |
    +--> Index becomes clean
    |
    +--> Working Tree becomes clean
```

Restoring:

```text
apply
    |
    +--> restore content
    +--> keep stash

pop
    |
    +--> restore content
    +--> remove successfully applied stash

apply --index
    |
    +--> restore content
    +--> attempt to restore staging state
```

---

## 19. Topics to Continue

The following Git Stash topics will be covered next:

```text
Stashing selected files
git stash drop
git stash clear
Stash conflicts
Stash conflict resolution
Git Stash internals
```

After completing Git Stash:

```text
Git Cherry-Pick
Git Tags
```

---

## 20. Summary

The most important Git Stash principles are:

1. Git Stash temporarily stores incomplete changes.
2. Creating a stash does not move HEAD or the current branch.
3. Normal stash operations save tracked staged and unstaged changes.
4. Normal stash operations ignore untracked files.
5. Use `-u` to include untracked files.
6. `git stash apply` restores changes but retains the stash.
7. `git stash pop` restores changes and removes the stash after successful application.
8. `git stash apply --index` attempts to restore the original Index state.
9. Multiple stashes are stored as a stack.
10. A specific stash can be selected using `stash@{n}`.
