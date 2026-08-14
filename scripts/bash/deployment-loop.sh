#!/bin/bash

set -euo pipefail

check_directory() {
    local DIRECTORY="$1"

    echo "Checking: $DIRECTORY"

    if [[ -d "$DIRECTORY" ]]; then
        echo "SUCCESS: Directory exists."
    else
        echo "ERROR: Directory does not exist."
        return 1
    fi
}

DIRECTORIES=(
    "/tmp"
    "/home/om"
    "/does-not-exist"
)

echo "Starting directory checks..."

for DIRECTORY in "${DIRECTORIES[@]}"; do
    check_directory "$DIRECTORY"
done

echo "All directory checks completed successfully."