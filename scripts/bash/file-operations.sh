#!/bin/bash

set -euo pipefail

WORK_DIR="/tmp/devops-lab"
CONFIG_FILE="$WORK_DIR/config.txt"
BACKUP_FILE="$WORK_DIR/config.backup"

echo "Creating working directory..."

mkdir -p "$WORK_DIR"

echo "Creating configuration file..."

cat > "$CONFIG_FILE" <<EOF
APP_NAME=DevOps_Automation
APP_ENV=Development
APP_VERSION=1.0
EOF

echo "Configuration created:"
cat "$CONFIG_FILE"

echo "Creating backup..."

cp "$CONFIG_FILE" "$BACKUP_FILE"

echo "Backup created:"
ls -l "$WORK_DIR"

echo "File operations completed successfully."