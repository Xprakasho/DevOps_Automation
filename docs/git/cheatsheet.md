
Command	Purpose

git cat-file -p HEAD	          Display commit contents
git cat-file -t HEAD	          Display object type
git ls-tree HEAD	          Show root tree
git ls-tree HEAD:docs	          Show contents of a tree
git rev-parse HEAD	          Show current commit SHA
git diff	                  Compare Working Directory with Index
git diff --cached	          Compare Index with Last Commit
find .git/objects -type f | wc -l	Count Git objects

# Git Cheatsheet

## Repository

git init

git clone

git status

---

## Staging

git add .

git restore --staged

git diff

git diff --cached

---

## Commit

git commit

git log

git log --oneline

git show

---

## Internals

git cat-file

git ls-tree

git rev-parse HEAD

find .git/objects -type f | wc -l

---

git branch

List branches

--------------------

git branch <branch>

Create branch

--------------------

git switch <branch>

Switch branch

--------------------

git switch -c <branch>

Create and switch

--------------------

git show-ref

Display references

--------------------

cat .git/refs/heads/main

Display latest commit SHA

--------------------

git branch --show-current

Display current branch
