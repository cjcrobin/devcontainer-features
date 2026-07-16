#!/bin/bash
set -e

source dev-container-features-test-lib

check "node installed"   command -v node
check "npm installed"    command -v npm
check "claude installed" command -v claude
check "claude runs"      claude --version

# ~/.claude must exist with correct permissions
check ".claude dir exists"       test -d "$HOME/.claude"
check ".claude dir permissions"  bash -c '[ "$(stat -c %a "$HOME/.claude")" = "700" ]'

reportResults
