#!/bin/bash

set -euo pipefail

echo "Script name : $0"
echo "First arg   : ${1:-Not provided}"
echo "Second arg  : ${2:-Not provided}"
echo "Arguments   : $#"

if [[ $# -lt 1 ]]; then
    echo "ERROR: Please provide an environment."
    exit 1
fi

echo "Deploying to environment: $1"