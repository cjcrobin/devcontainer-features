#!/bin/bash

set -e

# Test if Qoder CLI (CN) is installed
if ! command -v qoderclicn &> /dev/null; then
    echo "qoderclicn command not found"
    exit 1
fi

# Test version output
if ! qoderclicn --version &> /dev/null; then
    echo "qoderclicn version check failed"
    exit 1
fi

echo "Qoder CLI (CN) installation test passed!"
exit 0
