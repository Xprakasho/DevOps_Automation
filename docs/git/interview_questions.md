
Basic

What is Git?

Difference between Git and GitHub?

What is a Repository?

What is a Git branch?
What is the purpose of HEAD?
What is the difference between Git and GitHub?

Intermediate

Explain Blob.

Explain Tree.

Explain Commit.

What is HEAD?

Why are Git branches lightweight?
Where are local branches stored?
What information is stored in .git/refs/heads/main?

Advanced

What happens internally during git commit?

How does Git save storage?

Explain the Index.

Difference between git diff and git diff --cached.

What happens internally when executing git switch feature?
Does switching branches move commits?
Why does the Working Directory sometimes change after switching branches?
Explain the relationship between HEAD, Branch, Commit, Tree, and Blob.

=============================================================

# Git Merge Interview Questions

## 1. What is Git merge?

Git merge integrates changes and history from one branch into the currently checked-out branch.

---

## 2. What is a fast-forward merge?

A fast-forward merge occurs when the current branch tip is an ancestor of the branch being merged.

Git moves the current branch pointer forward without creating a new merge commit.

---

## 3. What is a three-way merge?

A three-way merge occurs when branches have diverged.

Git uses three inputs:

- Common ancestor (merge base)
- Current branch tip (ours)
- Incoming branch tip (theirs)

Git combines the changes and normally creates a merge commit.

---

## 4. What is a merge commit?

A merge commit is a commit created when Git combines divergent histories.

Unlike a normal commit, which usually has one parent, a merge commit normally has two parents.

Verify using:

```bash
git cat-file -p HEAD

===================================

5. What is a merge conflict?

A merge conflict occurs when Git cannot automatically determine how to combine changes safely.

For example, two branches may modify the same line differently.

The engineer must manually resolve the conflicting content.

6. How do you resolve a merge conflict?
git status

Identify conflicted files.

Edit the files and remove the conflict markers.

Then:

git add <resolved-file>
git commit

git add marks the conflict as resolved, and git commit completes the merge.

7. What are HEAD, ours, and theirs during a merge?

HEAD refers to the currently checked-out branch.

ours refers to the current branch version.

theirs refers to the incoming branch version being merged.

8. How can you abort an unfinished merge?
git merge --abort

This attempts to restore the repository to its state before the merge started.

9. What is the difference between fast-forward and three-way merge?

A fast-forward merge only moves the current branch pointer and creates no merge commit.

A three-way merge combines divergent histories using a common ancestor and normally creates a merge commit.

10. How do you inspect Git merge history?
git log --oneline --graph --decorate --all

To inspect the current merge commit internally:

git cat-file -p HEAD

A merge commit will show multiple parent entries.


Save it.

After that, tell me it is done. Then we will make a **very concise cheatsheet update**, 
