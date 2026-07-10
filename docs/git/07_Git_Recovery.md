
## 1. Introduction

Git recovery requires understanding three important areas:

1. HEAD
2. Index / Staging Area
3. Working Tree

Most Git recovery commands affect one or more of these areas.

---

## 2. Git's Three Areas

### HEAD

HEAD normally points to the current branch, and the current branch points to a commit.

Example:

```text
A --- B --- C
          ↑
         HEAD
         main
Index / Staging Area

The Index contains the snapshot that will become the next commit.

git add <file>

copies changes from the Working Tree into the Index.

Working Tree

The Working Tree contains the files currently checked out on disk.

A useful mental model is:

HEAD  →  Index  →  Working Tree
Part 1: git restore
3. Restore Working Tree Changes

Command:

git restore <file>

Default behavior:

Index → Working Tree

The file in the Working Tree is replaced with the version stored in the Index.

Example:

git restore labs/git/day8-recovery-demo.txt

Important:

HEAD does not move.
Branch does not move.
Index does not change.
Working Tree is restored from the Index.
4. Unstage a File

Command:

git restore --staged <file>

Behavior:

HEAD → Index

The Index is restored from HEAD.

The Working Tree remains unchanged.

Example:

git restore --staged labs/git/day8-recovery-demo.txt

After this command, staged changes normally become unstaged changes.

5. Restore Both Index and Working Tree

Command:

git restore --source=HEAD --staged --worktree <file>

Behavior:

HEAD → Index
HEAD → Working Tree

Both the Index and Working Tree are restored to match HEAD.

This can discard local changes, so it must be used carefully.

Part 2: git reset
6. Understanding git reset

git reset can move the current branch pointer and modify the Index and Working Tree depending on the reset mode.

The three primary reset modes are:

--soft
--mixed
--hard
7. git reset --soft

Command:

git reset --soft HEAD~1

Behavior:

HEAD / Branch → Move
Index         → Keep
Working Tree  → Keep

Example:

Before:

A --- B --- C
          ↑
         HEAD

After:

A --- B
      ↑
     HEAD

C changes remain staged.

Use case:

Undo the last commit.
Keep all changes staged.
Recommit with a corrected commit message or additional changes.
8. git reset --mixed

Command:

git reset --mixed HEAD~1

--mixed is the default reset mode.

Therefore:

git reset HEAD~1

is equivalent to:

git reset --mixed HEAD~1

Behavior:

HEAD / Branch → Move
Index         → Reset
Working Tree  → Keep

The removed commit's changes normally remain as unstaged Working Tree changes.

Use case:

Undo a commit.
Keep the file changes.
Rework the changes before staging again.
9. git reset --hard

Command:

git reset --hard HEAD~1

Behavior:

HEAD / Branch → Move
Index         → Reset
Working Tree  → Reset

This is destructive to tracked local changes.

Use carefully.

Example:

git reset --hard HEAD~1

The branch moves backward and the Index and Working Tree are changed to match the target commit.

10. Reset Comparison
Command	HEAD / Branch	Index	Working Tree
git reset --soft	Move	Keep	Keep
git reset --mixed	Move	Reset	Keep
git reset --hard	Move	Reset	Reset

Memory rule:

soft  = HEAD
mixed = HEAD + Index
hard  = HEAD + Index + Working Tree
Part 3: Git Reflog
11. What is git reflog?

Command:

git reflog

git reflog records movements of references such as HEAD.

It can show commits that are no longer visible in the normal branch history.

Example:

git reflog --oneline -10

Possible output:

8eb8372 HEAD@{0}: reset: moving to HEAD~1
51c3a0e HEAD@{1}: reset: moving to HEAD~1
db0ca46 HEAD@{2}: reset: moving to HEAD~1
ecdef10 HEAD@{3}: commit: test: add application version
12. Why git log and git reflog are different

git log shows commits reachable from the selected references.

git reflog shows recent reference movement history.

Therefore, after:

git reset --hard HEAD~1

a commit may disappear from normal git log output but still remain recoverable through git reflog.

13. Recovering a Lost Commit

First inspect the reflog:

git reflog --oneline -10

Identify the required commit SHA.

Then recover it:

git reset --hard <commit-SHA>

Example:

git reset --hard ecdef10

Verify:

git log --oneline --decorate -5
git status
Part 4: git revert
14. What is git revert?

Command:

git revert <commit-SHA>

git revert creates a new commit that applies the inverse of an earlier commit.

Example history:

A --- B --- C

Running:

git revert C

produces:

A --- B --- C --- D

where D reverses the changes introduced by C.

The original commit remains in history.

15. Reset vs Revert
Reset
A --- B --- C
          ↑
         HEAD

After:

git reset --hard HEAD~1

Result:

A --- B
      ↑
     HEAD

The branch pointer moves backward.

Revert

Before:

A --- B --- C

After:

git revert C

Result:

A --- B --- C --- D

D reverses C.

History is preserved.

16. When to Use Reset and Revert

Use reset primarily when:

Working with local/private history.
The commit has not been shared.
History rewriting is acceptable.

Use revert primarily when:

The commit is already shared.
The branch is public.
History must be preserved.
Working with production or team repositories.
Part 5: Revert Conflicts
17. Can git revert Cause Conflicts?

Yes.

A revert may conflict when later commits have modified the same content that the revert operation is attempting to change.

Example:

Commit 1 → Add Version: 2.0
Commit 2 → Revert Version: 2.0
Commit 3 → Add Version: 3.0

Reverting Commit 2 attempts to restore:

Version: 2.0

But the current file contains:

Version: 3.0

Git may not be able to resolve this automatically.

18. Inspecting a Revert Conflict

Check:

git status

Git may show:

You are currently reverting commit <SHA>.

Unmerged paths:
    both modified: <file>

Inspect the file:

cat <file>

Conflict markers may appear:

Version: 3.0
19. Resolving a Revert Conflict

Edit the file and select the desired final content.

Remove all conflict markers.

Then stage the resolution:

git add <file>

Verify:

git status

Inspect exactly what is staged:

git diff --cached

Then continue:

git revert --continue
20. Abort a Revert

To cancel the current revert operation:

git revert --abort

This returns the repository to the state before the revert operation started.

21. Skip a Revert

During an applicable multi-commit revert sequence:

git revert --skip

skips the current commit and continues the sequence.

Part 6: Production Troubleshooting Workflow

A safe recovery workflow is:

Problem occurs
      ↓
git status
      ↓
git log --oneline --graph --decorate --all
      ↓
Inspect HEAD / Index / Working Tree
      ↓
Choose restore / reset / revert / reflog
      ↓
Inspect changes
      ↓
git diff
git diff --cached
      ↓
Perform recovery
      ↓
Verify repository state

Useful verification commands:

git status
git diff
git diff --cached
git log --oneline --graph --decorate --all
git reflog
git show HEAD
Part 7: Key Interview Concepts
restore

Used primarily to restore file content or unstage changes.

reset

Moves a branch reference and, depending on mode, resets the Index and Working Tree.

revert

Creates a new inverse commit while preserving existing history.

reflog

Records recent local reference movements and can help recover commits no longer reachable through normal branch history.

Final Mental Model
git restore <file>
Index → Working Tree

git restore --staged <file>
HEAD → Index

git reset --soft
Move HEAD

git reset --mixed
Move HEAD + Reset Index

git reset --hard
Move HEAD + Reset Index + Working Tree

git reflog
Find previous reference positions

git revert
Create a new inverse commit

The most important recovery rule is:

Before running a recovery command, identify what should happen to HEAD, the Index, and the Workig tree.
