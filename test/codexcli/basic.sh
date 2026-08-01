#!/bin/bash
set -e

source dev-container-features-test-lib

check "codex installed" command -v codex
check "codex runs"      codex --version

reportResults
