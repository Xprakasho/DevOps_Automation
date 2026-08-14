#!/bin/bash

set -euo pipefail

LOG_FILE="deployment.log"

check_directory() {
    local DIRECTORY="$1"

    echo "Checking: $DIRECTORY" | tee -a "$LOG_FILE"

    if [[ -d "$DIRECTORY" ]]; then
        echo "SUCCESS: Directory exists." | tee -a "$LOG_FILE"
    else
        echo "ERROR: Directory does not exist." | tee -a "$LOG_FILE"
        return 1
    fi
}

DIRECTORIES=(
    "/tmp"
    "/home/om"
)

echo "Starting directory checks..." | tee "$LOG_FILE"

for DIRECTORY in "${DIRECTORIES[@]}"; do
    check_directory "$DIRECTORY"
done

echo "All directory checks completed successfully." | tee -a "$LOG_FILE"