
# Lab 03 - Git Commit Lifecycle

## Objective

Observe how Git creates objects during a commit.

## Commands

```bash
find .git/objects -type f | wc -l
git rev-parse HEAD
git status
git add .
git commit
git log --oneline
git cat-file -p HEAD
```

## Observations

- Initial Git objects
- Final Git objects
- New Commit SHA
- Parent Commit SHA
- New Tree SHA

## Conclusion

Git creates only the objects required for the changes.

Unchanged objects are reused.
