#!/bin/bash

set -euo pipefail

echo "Starting script..."

echo "Step 1: This works"

ls /does-not-exist

echo "Step 2: Script is still running"

echo "Completed successfully"