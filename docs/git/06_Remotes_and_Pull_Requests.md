
# Git Remotes, Fetch, Pull, Push, and Pull Requests

## Objective

Understand how a local Git repository communicates with a remote repository and how remote-tracking branches, fetch, pull, push, upstream tracking, and Pull Requests work.

---

## 1. What is a Git Remote?

A remote is a reference to another Git repository.

The default remote name is commonly:

```bash
origin

View configured remotes:

git remote -v

Inspect detailed remote configuration:

git remote show origin
2. Local Branch vs Remote-Tracking Branch

Example:

main
origin/main

main is a local branch.

origin/main is a remote-tracking branch.

origin/main represents Git's local knowledge of the main branch on the remote repository.

Important:

main != origin/main

They are separate references and can point to different commits.

3. View Branch Tracking Information
git branch -vv

Example:

main 5118961 [origin/main] latest commit

This shows that local main tracks origin/main.

View remote-tracking branches:

git branch -r

View all local and remote-tracking branches:

git branch -a
4. Git Fetch

Command:

git fetch origin

Git fetch:

Connects to the remote repository.
Downloads missing Git objects.
Updates remote-tracking branches.
Does not move the current local branch.
Does not normally change the working directory.

Example before fetch:

A --- B --- C
              ↑
        main, origin/main

A new commit is created on GitHub:

A --- B --- C --- D
              ↑       ↑
             main   GitHub main

Run:

git fetch origin

Result:

A --- B --- C --- D
              ↑       ↑
             main  origin/main

The local main branch remains unchanged.

5. Inspect Changes After Fetch

Useful commands:

git status
git log --oneline --graph --decorate --all

Example:

Your branch is behind 'origin/main' by 1 commit,
and can be fast-forwarded.

This means the remote-tracking branch contains commits that the local branch does not contain.

6. Updating Local Main After Fetch

After fetching:

git merge --ff-only origin/main

If fast-forwarding is possible, Git moves the local main pointer to the same commit as origin/main.

Example:

Before:

A --- B --- C --- D
              ↑       ↑
             main  origin/main

After:

A --- B --- C --- D
                      ↑
                main, origin/main

--ff-only prevents Git from creating an unexpected merge commit.

7. Git Pull

Command:

git pull

Conceptually:

git pull = git fetch + integration

The integration strategy may be merge, rebase, or fast-forward only depending on configuration and command options.

Unlike git fetch, git pull can:

Move the current local branch.
Update the working directory.
Create a merge commit in some situations.
Produce merge conflicts.
8. Git Fetch vs Git Pull
Operation	git fetch	git pull
Downloads remote changes	Yes	Yes
Updates remote-tracking branches	Yes	Yes
Moves current local branch	No	Usually
Updates working directory	No	Usually
Automatically integrates changes	No	Yes

A useful workflow is:

git fetch origin
git log --oneline --graph --decorate --all
git status
git merge --ff-only origin/main

This allows inspection before integration.

9. Git Push

Command:

git push

Git push sends local commits and updates a branch on the remote repository.

A new local branch may initially have no upstream branch.

Example:

git push

Error:

The current branch feature/day7-demo has no upstream branch.

Set the upstream:

git push --set-upstream origin feature/day7-demo

Short form:

git push -u origin feature/day7-demo
10. What is an Upstream Branch?

An upstream branch is the remote-tracking branch associated with a local branch.

Example:

Local branch:
feature/day7-demo

Upstream:
origin/feature/day7-demo

After setting upstream:

git branch -vv

may show:

feature/day7-demo [origin/feature/day7-demo]

Now commands such as:

git push
git pull

know the default remote branch.

11. Pull Request Workflow

Typical workflow:

Create feature branch
        ↓
Make changes
        ↓
Commit changes
        ↓
Push feature branch
        ↓
Create Pull Request
        ↓
Review changes
        ↓
Merge Pull Request
        ↓
Fetch remote changes
        ↓
Update local main
        ↓
Delete feature branch
12. Base Branch and Compare Branch

When creating a Pull Request:

base: main
compare: feature/day7-demo

The base branch is the destination branch.

The compare branch is the source branch containing the proposed changes.

Always verify the base branch before merging a Pull Request.

Incorrect:

base: feature/repository-foundation
compare: feature/day7-demo

Correct:

base: main
compare: feature/day7-demo
13. Pull Request Merge Commit

When GitHub creates a merge commit, the commit has two parents.

Inspect the commit:

git cat-file -p <merge-commit-sha>

Example:

parent 5118961
parent 80c3d73

First parent:

Previous base branch commit

Second parent:

Feature branch commit

This proves the commit is a merge commit.

14. Important PR Merge vs Local Fast-Forward Distinction

GitHub may perform a three-way merge and create a merge commit.

Later, the local repository can fetch that merge commit and update main using a fast-forward.

Example:

GitHub:

             Feature
                \
Main ------------ M

GitHub creates merge commit M.

After fetch:

Local main ------ A
                   \
                    M ← origin/main

Run:

git merge --ff-only origin/main

Result:

Local main -------- M
                    ↑
             main, origin/main

The local operation is a fast-forward.

It does not create another merge commit.

15. Deleting a Merged Feature Branch

Delete the local branch:

git branch -d feature/day7-demo

The -d option performs safe deletion.

Delete the remote branch:

git push origin --delete feature/day7-demo

Remove stale remote-tracking references:

git fetch --prune
16. Important Inspection Commands

View commit graph:

git log --oneline --graph --decorate --all

View local branch references:

git show-ref --heads

View tracking relationships:

git branch -vv

View remote branches:

git branch -r

View all branches:

git branch -a

Inspect remote configuration:

git remote show origin

Inspect a Git object:

git cat-file -p <sha>
17. Day-7 Key Takeaways
main and origin/main are separate references.
git fetch downloads objects and updates remote-tracking branches.
git fetch does not move the current local branch.
git pull performs fetch followed by integration.
git push -u pushes a branch and configures its upstream.
Always verify the base and compare branches before merging a Pull Request.
A merge commit contains two parents.
A GitHub PR merge and a later local fast-forward are separate Git operations.
git branch -d safely deletes a merged local branch.
git fetch --prune removes stale remote-tracking references.
