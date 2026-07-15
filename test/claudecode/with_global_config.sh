#!/bin/bash
set -e

source dev-container-features-test-lib

# The setup script is installed by install.sh during image build.
check "setup script exists"       test -f /usr/local/share/claude-devcontainer/setup.sh
check "setup script executable"   test -x /usr/local/share/claude-devcontainer/setup.sh
check "feature options env exists" test -f /usr/local/share/claude-devcontainer/feature-options.env

# GLOBAL_CONFIG_HOME should be baked into the options file.
check "options file contains globalConfigHome" \
    grep -q "CLAUDE_GLOBAL_CONFIG_HOME" /usr/local/share/claude-devcontainer/feature-options.env

# The host home mount must exist (set up by the feature's mounts declaration).
check "host home mount exists"    test -d /tmp/.devcontainer-host-home

# Claude binary must still be available.
check "claude installed"          command -v claude

reportResults
