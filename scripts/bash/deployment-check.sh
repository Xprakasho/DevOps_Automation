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

echo "Starting deployment checks..."

check_directory "/tmp"
check_directory "/does-not-exist"

echo "All checks completed successfully."