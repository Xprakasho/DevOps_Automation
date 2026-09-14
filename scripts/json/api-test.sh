#!/bin/bash

set -euo pipefail

API_URL="https://jsonplaceholder.typicode.com/todos/1"

echo "Calling API..."

RESPONSE=$(curl -sSf "$API_URL")

echo "API response received."

COMPLETED=$(echo "$RESPONSE" | jq -r '.completed')

echo "Completed: $COMPLETED"

if [[ "$COMPLETED" == "true" ]]; then
    echo "Task is completed."
else
    echo "Task is not completed."
fi