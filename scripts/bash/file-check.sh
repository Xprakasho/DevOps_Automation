#!/bin/bash

set -euo pipefail

CONFIG_FILE="/tmp/devops-lab/config.txt"
BACKUP_FILE="/tmp/devops-lab/config.backup"

check_file() {
    local FILE="$1"

    echo "Checking file: $FILE"

    if [[ -f "$FILE" ]]; then
        echo "SUCCESS: File exists."
    else
        echo "ERROR: File does not exist."
        return 1
    fi
}

check_file "$CONFIG_FILE"
check_file "$BACKUP_FILE"

echo "All file checks completed successfully."