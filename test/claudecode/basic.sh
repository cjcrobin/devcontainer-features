#!/bin/bash
set -e

# Optional: Import test library
source dev-container-features-test-lib

check "node installed"   command -v node
check "npm installed"    command -v npm
check "claude installed" command -v claude
check "claude runs"      claude --version

reportResults
