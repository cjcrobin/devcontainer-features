#!/bin/bash
set -e

# Optional: Import test library
source dev-container-features-test-lib

check "node installed"   command -v node
check "npm installed"    command -v npm
check "claude installed" command -v claude

# ~/.claude must exist with correct permissions and owner
check ".claude dir exists"       test -d "$HOME/.claude"
check ".claude dir permissions"  bash -c '[ "$(stat -c %a "$HOME/.claude")" = "700" ]'
check ".claude dir owner"        bash -c '[ "$(stat -c %U "$HOME/.claude")" = "$(id -un)" ]'

reportResults
