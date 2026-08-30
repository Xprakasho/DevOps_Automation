#!/bin/bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <environment> <config-file>"
    exit 1
fi

ENVIRONMENT="$1"
CONFIG_FILE="$2"
LOG_FILE="deployment-validation.log"

{
    echo "================================"
    echo " Deployment Validator"
    echo "================================"
    echo
    echo "Environment : $ENVIRONMENT"
    echo "Config      : $CONFIG_FILE"
    echo

    echo "Checking configuration..."

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "ERROR: Configuration file does not exist."
        exit 1
    fi

    echo "SUCCESS: File exists."

    if [[ ! -r "$CONFIG_FILE" ]]; then
        echo "ERROR: Configuration file is not readable."
        exit 1
    fi

    echo "SUCCESS: File is readable."

    if ! jq empty "$CONFIG_FILE"; then
        echo "ERROR: Invalid JSON."
        exit 1
    fi

    echo "SUCCESS: JSON is valid."

    APPLICATION=$(jq -r '.application' "$CONFIG_FILE")
    VERSION=$(jq -r '.version' "$CONFIG_FILE")

    echo
    echo "Application : $APPLICATION"
    echo "Version     : $VERSION"
    echo
    echo "Validation completed successfully."

} | tee "$LOG_FILE"