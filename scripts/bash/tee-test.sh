#!/bin/bash

set -euo pipefail

echo "Running command..."

ls /does-not-exist | tee command.log

echo "This line should not execute."