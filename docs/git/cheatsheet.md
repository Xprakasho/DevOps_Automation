
Command	Purpose

git cat-file -p HEAD	          Display commit contents
git cat-file -t HEAD	          Display object type
git ls-tree HEAD	          Show root tree
git ls-tree HEAD:docs	          Show contents of a tree
git rev-parse HEAD	          Show current commit SHA
git diff	                  Compare Working Directory with Index
git diff --cached	          Compare Index with Last Commit
find .git/objects -type f | wc -l	Count Git objects
