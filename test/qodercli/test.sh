#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Feature-specific tests
check "curl installed" command -v curl
check "qodercli installed" command -v qodercli
check "qodercli version" qodercli --version

# Report results
reportResults
