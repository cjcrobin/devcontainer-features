#!/bin/sh
set -eu

# ---------------------------------------------------------------------------
# Package manager helpers
# ---------------------------------------------------------------------------

detect_package_manager() {
    for pm in apt-get apk dnf yum zypper pacman; do
        if command -v "$pm" >/dev/null 2>&1; then
            case "$pm" in
                apt-get) echo "apt" ;;
                *)       echo "$pm" ;;
            esac
            return 0
        fi
    done
    echo ""
}

install_packages() {
    pkg_manager="$1"; shift
    case "$pkg_manager" in
        apt)     apt-get update -y && apt-get install -y --no-install-recommends "$@" ;;
        apk)     apk add --no-cache "$@" ;;
        dnf)     dnf install -y "$@" ;;
        yum)     yum install -y "$@" ;;
        zypper)  zypper --non-interactive install "$@" ;;
        pacman)  pacman -Sy --noconfirm "$@" ;;
        *)       echo "ERROR: Unsupported package manager: $pkg_manager" >&2; return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------

ensure_curl() {
    if command -v curl >/dev/null 2>&1; then
        return 0
    fi
    pkg_manager="$1"
    if [ -z "$pkg_manager" ]; then
        echo "ERROR: curl is required but not found, and no supported package manager is available to install it." >&2
        return 1
    fi
    echo "curl not found — installing..."
    install_packages "$pkg_manager" curl
}

ensure_ca_certificates() {
    pkg_manager="$1"
    if [ -z "$pkg_manager" ]; then
        return 0
    fi
    # ca-certificates is needed for HTTPS downloads; install if the package
    # manager is available (idempotent on most distros).
    case "$pkg_manager" in
        apt)     install_packages apt ca-certificates ;;
        apk)     install_packages apk ca-certificates ;;
        dnf|yum|zypper|pacman) install_packages "$pkg_manager" ca-certificates ;;
    esac
}

ensure_tar() {
    if command -v tar >/dev/null 2>&1; then
        return 0
    fi
    pkg_manager="$1"
    if [ -z "$pkg_manager" ]; then
        echo "ERROR: tar is required but not found, and no supported package manager is available to install it." >&2
        return 1
    fi
    echo "tar not found — installing..."
    install_packages "$pkg_manager" tar
}

# ---------------------------------------------------------------------------
# Codex CLI installation
# ---------------------------------------------------------------------------

install_codex() {
    echo "Installing Codex CLI via standalone installer..."

    # Install to system-wide locations so all users can access codex:
    #   CODEX_INSTALL_DIR  — where the 'codex' symlink is placed
    #   CODEX_HOME         — where the actual release binaries are stored
    #   CODEX_NON_INTERACTIVE — skip any interactive prompts
    export CODEX_INSTALL_DIR="/usr/local/bin"
    export CODEX_HOME="/usr/local/lib/codex"
    export CODEX_NON_INTERACTIVE="true"

    curl -fsSL https://chatgpt.com/codex/install.sh | sh

    if ! command -v codex >/dev/null 2>&1; then
        # Fallback: check the install dir directly
        if [ -x /usr/local/bin/codex ]; then
            export PATH="/usr/local/bin:$PATH"
        else
            echo "ERROR: 'codex' command not found after installation." >&2
            return 1
        fi
    fi

    echo "Codex CLI installed successfully: $(codex --version 2>/dev/null || echo '(version check unavailable)')"
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

main() {
    echo "Activating feature 'codexcli'"

    PKG_MANAGER="$(detect_package_manager)"

    ensure_curl "$PKG_MANAGER"
    ensure_ca_certificates "$PKG_MANAGER"
    ensure_tar "$PKG_MANAGER"
    install_codex

    echo "Feature 'codexcli' installation complete."
}

main
