#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Feature-specific tests

# --- Node.js (prerequisite) ---
check "node installed"     command -v node
check "npm installed"      command -v npm
check "node version ok"    bash -c 'node_major=$(node --version | sed "s/v//" | cut -d. -f1); [ "$node_major" -ge 18 ]'

# --- option: version — Claude Code CLI installed and runnable ---
check "claude installed"   command -v claude
check "claude runs"        claude --version

# --- postCreateCommand setup script ---
check "setup script exists"      test -f /usr/local/share/claude-devcontainer/setup.sh
check "setup script executable"  test -x /usr/local/share/claude-devcontainer/setup.sh

# --- feature-options.env (bakes all option values at image-build time) ---
check "feature options env exists" test -f /usr/local/share/claude-devcontainer/feature-options.env

# --- option: globalConfigHome — key must be present (may be empty by default) ---
check "options env has CLAUDE_GLOBAL_CONFIG_HOME" \
    grep -q "^CLAUDE_GLOBAL_CONFIG_HOME=" /usr/local/share/claude-devcontainer/feature-options.env

# --- option: projectConfigFolder — key must be present (may be empty by default) ---
check "options env has CLAUDE_PROJECT_CONFIG_FOLDER" \
    grep -q "^CLAUDE_PROJECT_CONFIG_FOLDER=" /usr/local/share/claude-devcontainer/feature-options.env

# --- containerEnv: _CLAUDE_HOST_HOME must be injected by the feature ---
check "_CLAUDE_HOST_HOME env var is set" test -n "${_CLAUDE_HOST_HOME}"

# --- mounts: host home bind-mount must be present ---
check "host home mounted"  test -d /tmp/.devcontainer-host-home

# Report results
reportResults
