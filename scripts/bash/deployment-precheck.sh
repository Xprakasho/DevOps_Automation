#!/bin/bash

set -euo pipefail

LOG_FILE="deployment-precheck.log"

DIRECTORIES=(
    "/tmp"
    "/home/om"
)

FILES=(
    "/tmp/devops-lab/config.txt"
    "/tmp/devops-lab/config.backup"
    "/tmp/devops-lab/missing.conf"
)

check_directory() {
    local DIRECTORY="$1"

    echo "Checking directory: $DIRECTORY" | tee -a "$LOG_FILE"

    if [[ -d "$DIRECTORY" ]]; then
        echo "SUCCESS: Directory exists." | tee -a "$LOG_FILE"
    else
        echo "ERROR: Directory does not exist." | tee -a "$LOG_FILE"
        return 1
    fi
}

check_file() {
    local FILE="$1"

    echo "Checking file: $FILE" | tee -a "$LOG_FILE"

    if [[ ! -f "$FILE" ]]; then
        echo "ERROR: File does not exist." | tee -a "$LOG_FILE"
        return 1
    fi

    if [[ ! -r "$FILE" ]]; then
        echo "ERROR: File is not readable." | tee -a "$LOG_FILE"
        return 1
    fi

    echo "SUCCESS: File exists and is readable." | tee -a "$LOG_FILE"
}

echo "========================================" | tee "$LOG_FILE"
echo "     Deployment Pre-Check" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

for DIRECTORY in "${DIRECTORIES[@]}"; do
    check_directory "$DIRECTORY"
done

for FILE in "${FILES[@]}"; do
    check_file "$FILE"
done

echo "========================================" | tee -a "$LOG_FILE"
echo "All deployment checks passed." | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"