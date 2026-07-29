#!/bin/bash
set -e

source dev-container-features-test-lib

# When installSkills=false, playwright-cli should still be installed.
check "node installed"            command -v node
check "npm installed"             command -v npm
check "playwright-cli installed"  command -v playwright-cli
check "playwright-cli runs"       playwright-cli --version

reportResults
