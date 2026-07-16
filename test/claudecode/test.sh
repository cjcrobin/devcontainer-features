#!/bin/bash
set -e

source dev-container-features-test-lib

check "node installed"     command -v node
check "npm installed"      command -v npm
check "node version ok"    bash -c 'node_major=$(node --version | sed "s/v//" | cut -d. -f1); [ "$node_major" -ge 18 ]'
check "claude installed"   command -v claude
check "claude runs"        claude --version

reportResults
