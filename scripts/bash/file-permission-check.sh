#!/bin/bash

set -euo pipefail

check_file() {
    local FILE="$1"

    echo "Checking: $FILE"

    if [[ ! -f "$FILE" ]]; then
        echo "ERROR: File does not exist."
        return 1
    fi

    if [[ ! -r "$FILE" ]]; then
        echo "ERROR: File is not readable."
        return 1
    fi

    echo "SUCCESS: File exists and is readable."
}

check_file "/tmp/devops-lab/config.txt"
check_file "/tmp/devops-lab/config.backup"

echo "All permission checks completed successfully."