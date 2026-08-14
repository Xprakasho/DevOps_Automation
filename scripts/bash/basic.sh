#!/bin/bash

echo "=================================="
echo "Bash DevOps Fundamentals"
echo "=================================="

APP_NAME="DevOps_Automation"
APP_ENV="Development"

echo "Application : $APP_NAME"
echo "Environment : $APP_ENV"

echo ""
echo "System Information"
echo "------------------"

echo "User        : $(whoami)"
echo "Home        : $HOME"
echo "Shell       : $SHELL"
echo "Hostname    : $(hostname)"
echo "OS          : $(uname -s)"
echo "Kernel      : $(uname -r)"
echo "Directory   : $(pwd)"
echo "Date        : $(date)"

echo "=================================="