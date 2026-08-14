#!/bin/bash

set -euo pipefail

echo "Checking /tmp..."

if ls /tmp > /dev/null 2>&1; then
    echo "SUCCESS: /tmp exists and is accessible."
else
    echo "ERROR: Cannot access /tmp."
fi

echo ""
echo "Checking a missing directory..."

if ls /does-not-exist > /dev/null 2>&1; then
    echo "SUCCESS: Directory exists."
else
    echo "ERROR: Directory does not exist."
fi

echo ""
echo "Script completed."