#!/bin/bash

set -e

# Test if Qoder CLI (Global) is installed
if ! command -v qodercli &> /dev/null; then
    echo "qodercli command not found"
    exit 1
fi

# Test version output
if ! qodercli --version &> /dev/null; then
    echo "qodercli version check failed"
    exit 1
fi

echo "Qoder CLI (Global) installation test passed!"
exit 0
