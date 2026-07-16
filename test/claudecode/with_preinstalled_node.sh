#!/bin/bash
set -e

# This scenario runs on node:20-bookworm, which ships Node.js 20 and npm.
# The feature must DETECT the pre-installed runtime and skip reinstalling it,
# then install Claude Code on top using the existing npm.

source dev-container-features-test-lib

# --- Pre-installed Node.js must still be present and at the expected major version ---
check "node installed"          command -v node
check "npm installed"           command -v npm
check "node version is v20"     bash -c 'node --version | grep -q "^v20\."'

# --- Claude Code must be installed and runnable on top of the existing runtime ---
check "claude installed"        command -v claude
check "claude runs"             claude --version

reportResults
