
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

------------------------------------------

## Git Rebase Interview Questions

### 1. What is Git rebase?

Git rebase replays commits from the current branch onto a new base.

---

### 2. Why do commit SHAs change after rebase?

Rebase changes commit parent relationships. Because the parent SHA is part of the commit object, Git creates new commit objects with new SHAs.

---

### 3. What is the difference between merge and rebase?

Merge preserves branch history and may create a merge commit.

Rebase rewrites history by replaying commits onto a new base, creating new SHAs and a linear history.

---

### 4. Does rebase modify the main branch?

No. When a feature branch is rebased onto `main`, the feature branch is rewritten. The `main` branch pointer does not move.

---

### 5. Why can a merge after rebase become a fast-forward merge?

After rebase, `main` is an ancestor of the rebased feature branch. Therefore, Git can move the `main` pointer forward without creating a merge commit.

---

### 6. How do you resolve a rebase conflict?

Resolve the conflicted file, stage it, and continue the rebase:

```bash
git add <resolved-file>
git rebase --continue
```

---

### 7. How do you cancel an ongoing rebase?

```bash
git rebase --abort
```

This restores the branch to its pre-rebase state.

---

### 8. What is the difference between resolving a merge conflict and a rebase conflict?

For a merge conflict:

```bash
git add <resolved-file>
git commit
```

For a rebase conflict:

```bash
git add <resolved-file>
git rebase --continue
```

---

### 9. Can old commits still exist after rebase?

Yes. Old commits may remain in the Git object database temporarily even when branches no longer reference them. Previous reference positions can often be found using `git reflog`.

---

### 10. Why should you avoid rebasing shared history?

Rebase creates new commit SHAs. If other developers are already using the original commits, rewriting that history can cause divergence and synchronization problems.

---

### 11. What does `git rebase --skip` do?

It skips the current commit being replayed and continues with the remaining commits.

---

### 12. What is the main benefit of rebase?

Rebase can produce a clean, linear commit history by replaying feature commits on top of the latest base branch.

-------------------------------------

---

# Git Remotes and Pull Requests Interview Questions

## 1. What is a Git remote?

A Git remote is a reference to another Git repository. It allows a local repository to fetch changes from and push changes to another repository.

---

## 2. What is `origin` in Git?

`origin` is the conventional default name assigned to the remote repository when a repository is cloned.

---

## 3. What is the difference between `main` and `origin/main`?

`main` is a local branch.

`origin/main` is a remote-tracking branch that represents the local repository's last known state of the remote `main` branch.

They are separate Git references and can point to different commits.

---

## 4. What does `git fetch` do?

`git fetch` downloads missing objects and updates remote-tracking references such as `origin/main`.

It does not move the current local branch and does not normally modify the working directory.

---

## 5. What is the difference between `git fetch` and `git pull`?

`git fetch` downloads remote changes without integrating them into the current local branch.

`git pull` performs a fetch followed by integration using merge or rebase, depending on the command options and configuration.

---

## 6. Why might `main` and `origin/main` point to different commits?

Because changes may exist locally or remotely that have not yet been synchronized.

For example, after `git fetch`, `origin/main` may move to a newer remote commit while local `main` remains unchanged.

---

## 7. What is a remote-tracking branch?

A remote-tracking branch is a local reference that records Git's last known state of a branch in a remote repository.

Example:

```text
origin/main
8. What is an upstream branch?

An upstream branch is the branch associated with a local branch for default push and pull operations.

Example:

Local branch:  feature/demo
Upstream:      origin/feature/demo
9. What does git push -u do?

It pushes the local branch to the remote repository and configures the remote branch as the upstream branch.

Example:

git push -u origin feature/demo
10. What happens when you run git push on a new branch without an upstream?

Git normally reports that the current branch has no upstream branch and suggests a command to configure one.

Example:

git push --set-upstream origin feature/demo
11. What is a Pull Request?

A Pull Request is a collaboration workflow provided by hosting platforms such as GitHub.

It proposes integrating changes from a source branch into a destination branch and supports review and discussion before merging.

12. What is the base branch in a Pull Request?

The base branch is the destination branch that will receive the changes.

Example:

base: main
13. What is the compare branch in a Pull Request?

The compare branch is the source branch containing the proposed changes.

Example:

compare: feature/demo
14. Why should you verify the base branch before merging a Pull Request?

Because selecting the wrong base branch causes the changes to be merged into the wrong destination branch.

A successful PR merge does not automatically mean that the changes were merged into main.

15. How can you identify a merge commit?

Inspect the commit:

git cat-file -p <commit-sha>

A merge commit normally contains more than one parent.

Example:

parent <base-parent-sha>
parent <feature-parent-sha>
16. Why did git status say the local branch was behind origin/main by two commits after the PR merge?

Because two commits reachable from origin/main were not yet reachable from local main:

The feature commit.
The GitHub-created merge commit.
17. Can GitHub create a merge commit while the later local update is a fast-forward?

Yes.

GitHub can merge the feature branch and create a new merge commit.

After fetching that commit, the local main branch can fast-forward to the already-existing merge commit.

The local fast-forward does not create another merge commit.

18. What does git merge --ff-only origin/main do?

It updates the current branch to origin/main only when the update can be performed as a fast-forward.

It prevents an unexpected merge commit from being created.

19. Does git fetch update the working directory?

Normally, no.

It downloads objects and updates remote-tracking references but does not check out those changes into the working directory.

20. Can git pull update the working directory?

Yes.

Because git pull fetches and then integrates changes into the current branch, the working directory may be updated.

21. What does git branch -vv show?

It displays local branches, their current commit, and configured upstream tracking information.

22. What does git branch -r show?

It displays remote-tracking branches.

23. What does git remote show origin provide?

It displays detailed information about the remote, including:

Fetch URL
Push URL
Remote branches
Tracking configuration
Push configuration
24. What is the difference between deleting a local and remote branch?

Delete a local merged branch:

git branch -d feature/demo

Delete a remote branch:

git push origin --delete feature/demo

They are separate operations.

25. What does git fetch --prune do?

It fetches remote updates and removes stale remote-tracking references for branches that no longer exist on the remote repository.

26. Explain a safe Git remote workflow.

A safe workflow is:

git fetch origin
        ↓
Inspect graph and status
        ↓
git merge --ff-only origin/main

This allows the developer to inspect remote changes before updating the local branch.

27. What is the difference between a local branch, remote branch, and remote-tracking branch?

A local branch exists in the local repository.

A remote branch exists in the remote repository.

A remote-tracking branch such as origin/main is a local reference representing Git's last known state of the remote branch.

28. What happens internally after a PR is merged on GitHub?

Depending on the selected merge strategy, GitHub updates the target branch.

When using Create a merge commit, GitHub creates a new commit containing two parents and moves the target branch to that commit.

The local repository remains unaware of this change until remote information is fetched.

29. Why is git fetch useful for troubleshooting?

Because it allows a developer to update remote-tracking information and inspect the commit graph before modifying the current local branch or working directory.

Useful commands include:

git fetch origin
git status
git log --oneline --graph --decorate --all
30. Explain the complete feature branch and Pull Request workflow.
Create feature branch
        ↓
Make changes
        ↓
Commit
        ↓
Push and configure upstream
        ↓
Create Pull Request
        ↓
Verify base and compare branches
        ↓
Review and merge
        ↓
Fetch remote changes
        ↓
Inspect commit graph
        ↓
Update local main
        ↓
Delete local feature branch
        ↓
Delete remote feature branch
        ↓
Prune stale remote-tracking references
