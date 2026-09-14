#!/bin/bash

set -euo pipefail

CONFIG_FILE="application.json"

APP_NAME=$(jq -r '.application.name' "$CONFIG_FILE")
ENVIRONMENT=$(jq -r '.application.environment' "$CONFIG_FILE")
REPLICAS=$(jq -r '.deployment.replicas' "$CONFIG_FILE")

echo "Application : $APP_NAME"
echo "Environment : $ENVIRONMENT"
echo "Replicas    : $REPLICAS"