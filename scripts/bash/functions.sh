#!/bin/bash

set -euo pipefail

greet_user() {
    echo "Inside function:"
    echo "Function \$1 = $1"
    echo "Function arguments = $#"
}

echo "Script arguments:"
echo "Script \$1 = ${1:-Not provided}"
echo "Script arguments = $#"

echo ""

greet_user "Om"
greet_user "DevOps Engineer"