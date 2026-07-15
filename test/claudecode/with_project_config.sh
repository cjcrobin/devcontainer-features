#!/bin/bash
set -e

source dev-container-features-test-lib

# The setup script must exist.
check "setup script exists"       test -f /usr/local/share/claude-devcontainer/setup.sh
check "setup script executable"   test -x /usr/local/share/claude-devcontainer/setup.sh

# PROJECT_CONFIG_FOLDER should be baked into the options file.
check "options file contains projectConfigFolder" \
    grep -q "CLAUDE_PROJECT_CONFIG_FOLDER=" /usr/local/share/claude-devcontainer/feature-options.env

# The project config folder value must be non-empty.
check "projectConfigFolder is set" \
    bash -c 'source /usr/local/share/claude-devcontainer/feature-options.env && [ -n "$CLAUDE_PROJECT_CONFIG_FOLDER" ]'

# The host home mount must exist.
check "host home mount exists"    test -d /tmp/.devcontainer-host-home

# Claude binary must still be available.
check "claude installed"          command -v claude

reportResults
