#!/bin/bash

set -euo pipefail

DIRECTORIES=(
    "/tmp"
    "/home/om"
    "/does-not-exist"
)


for DIRECTORY in "${DIRECTORIES[@]}"; do

    echo "Checking: $DIRECTORY"

    if [[ -d "$DIRECTORY" ]]; then
        echo "  SUCCESS: Directory exists."
    else
        echo "  ERROR: Directory does not exist."
    fi

done

echo ""
echo "All directory checks completed."