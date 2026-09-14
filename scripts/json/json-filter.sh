#!/bin/bash

set -euo pipefail

CONFIG_FILE="application.json"

while IFS= read -r SERVER; do
    echo "Processing server: $SERVER"
done < <(
    jq -r '
      .servers[]
      | select(.enabled == true)
      | .name
    ' "$CONFIG_FILE"
)