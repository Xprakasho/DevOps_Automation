#!/bin/bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

DIRECTORY="$1"

echo "Checking directory: $DIRECTORY"

if [ -d "$DIRECTORY" ]; then
    echo "SUCCESS: Directory exists."
else
    echo "ERROR: Directory does not exist."
    exit 1
fi

echo "Check completed successfully."