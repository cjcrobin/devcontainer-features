#!/bin/bash
set -e

source dev-container-features-test-lib

check "node installed"   command -v node
check "npm installed"    command -v npm
check "claude installed" command -v claude
check "claude runs"      claude --version

# ---------------------------------------------------------------------------
# ~/.claude — must exist, be owned by the current user, and be mode 700
# ---------------------------------------------------------------------------
check ".claude dir exists"       test -d "$HOME/.claude"
check ".claude dir permissions"  bash -c '[ "$(stat -c %a "$HOME/.claude")" = "700" ]'
check ".claude dir owner"        bash -c '[ "$(stat -c %U "$HOME/.claude")" = "$(id -un)" ]'

# ---------------------------------------------------------------------------
# Workspace .claude — simulates what postCreateCommand does.
# Creates a temp dir that stands in for ${workspaceFolder}, runs the same
# mkdir + chmod logic from postCreateCommand, then validates the result.
# ---------------------------------------------------------------------------
_tmp_ws=$(mktemp -d)
mkdir -p "$_tmp_ws/.claude" && chmod 700 "$_tmp_ws/.claude"
export _WS_CLAUDE_DIR="$_tmp_ws/.claude"

check "workspace .claude dir exists"       test -d "$_WS_CLAUDE_DIR"
check "workspace .claude dir permissions"  bash -c '[ "$(stat -c %a "$_WS_CLAUDE_DIR")" = "700" ]'
check "workspace .claude dir owner"        bash -c '[ "$(stat -c %U "$_WS_CLAUDE_DIR")" = "$(id -un)" ]'

rm -rf "$_tmp_ws"

reportResults
