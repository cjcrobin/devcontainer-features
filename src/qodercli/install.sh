#!/bin/sh
set -eu

# Edition option: "global" (default) or "cn"
EDITION="${EDITION:-global}"

# Function to detect the package manager and OS type
detect_package_manager() {
    for pm in apt-get apk dnf yum; do
        if command -v $pm >/dev/null; then
            case $pm in
                apt-get) echo "apt" ;;
                *) echo "$pm" ;;
            esac
            return 0
        fi
    done
    echo "unknown"
    return 1
}

# Function to install packages using the appropriate package manager
install_packages() {
    local pkg_manager="$1"
    shift
    local packages="$@"

    case "$pkg_manager" in
        apt)
            apt-get update
            apt-get install -y $packages
            ;;
        apk)
            apk add --no-cache $packages
            ;;
        dnf|yum)
            $pkg_manager install -y $packages
            ;;
        *)
            echo "WARNING: Unsupported package manager. Cannot install packages: $packages"
            return 1
            ;;
    esac

    return 0
}

# Function to ensure curl is available
ensure_curl() {
    if command -v curl >/dev/null; then
        return 0
    fi

    local pkg_manager="$1"
    echo "curl not found, installing curl using $pkg_manager..."
    install_packages "$pkg_manager" "curl"
}

# Function to ensure ca-certificates are available
ensure_ca_certificates() {
    local pkg_manager="$1"
    case "$pkg_manager" in
        apt)
            install_packages apt "ca-certificates"
            ;;
        apk)
            install_packages apk "ca-certificates"
            ;;
        dnf|yum)
            install_packages "$pkg_manager" "ca-certificates"
            ;;
    esac
}

# Function to install Qoder CLI based on edition
install_qodercli() {
    local edition="$1"
    local install_url=""
    local cmd_name=""

    case "$edition" in
        cn)
            install_url="https://qoder.com.cn/install"
            cmd_name="qoderclicn"
            echo "Installing Qoder CLI (China Edition)..."
            ;;
        global|*)
            install_url="https://qoder.com/install"
            cmd_name="qodercli"
            echo "Installing Qoder CLI (Global Edition)..."
            ;;
    esac

    # Install normally — files go to $HOME (=/root during Docker build):
    #   $HOME/.local/bin/<cmd>   → entry-point script
    #   $HOME/.qoder/bin/<cmd>/  → versioned binary
    curl -fsSL "$install_url" | bash

    # Verify installation (build runs as root, so $HOME=/root)
    export PATH="$HOME/.local/bin:$HOME/.qoder/bin:$PATH"

    if ! command -v "$cmd_name" >/dev/null 2>&1; then
        echo "ERROR: Qoder CLI ($edition) installation failed!"
        return 1
    fi

    echo "Qoder CLI ($edition) installed successfully!"
    "$cmd_name" --version || true

    # ── Copy to system-wide location ─────────────────────────────
    # /root/ is not accessible to other users (e.g. vscode), so we
    # copy everything to /usr/local/ where all users can reach it.

    local qoder_src="$HOME/.qoder"

    # 1) Copy .qoder data directory to /usr/local/lib/
    if [ -d "$qoder_src" ]; then
        cp -r "$qoder_src" /usr/local/lib/qoder
        chmod -R a+rX /usr/local/lib/qoder
        echo "Copied $qoder_src -> /usr/local/lib/qoder"
    fi

    # 2) Copy the versioned binary to /usr/local/bin/
    if [ -d "$qoder_src/bin/$cmd_name" ]; then
        for bin_file in "$qoder_src/bin/$cmd_name"/*; do
            if [ -f "$bin_file" ] && [ -x "$bin_file" ]; then
                cp "$bin_file" "/usr/local/bin/"
                chmod a+rx "/usr/local/bin/$(basename "$bin_file")"
                echo "Copied binary $(basename "$bin_file") -> /usr/local/bin/"
            fi
        done
    fi

    # 3) Copy entry-point to /usr/local/bin/ and patch paths
    if [ -f "$HOME/.local/bin/$cmd_name" ]; then
        cp "$HOME/.local/bin/$cmd_name" "/usr/local/bin/$cmd_name"
        chmod a+rx "/usr/local/bin/$cmd_name"

        # Patch the entry-point: replace $HOME/.qoder and /root/.qoder
        # with the shared /usr/local/lib/qoder path
        sed -i "s|$HOME/.qoder|/usr/local/lib/qoder|g" "/usr/local/bin/$cmd_name" 2>/dev/null || true
        sed -i 's|\$HOME/\.qoder|/usr/local/lib/qoder|g' "/usr/local/bin/$cmd_name" 2>/dev/null || true

        echo "Copied and patched entry-point -> /usr/local/bin/$cmd_name"
    fi

    echo "Qoder CLI ($edition) is now available system-wide at /usr/local/bin/$cmd_name"
    return 0
}

# Main script starts here
main() {
    echo "Activating feature 'qodercli' (edition: $EDITION)"

    # Detect package manager
    PKG_MANAGER=$(detect_package_manager)
    echo "Detected package manager: $PKG_MANAGER"

    # Ensure curl and ca-certificates are available
    ensure_curl "$PKG_MANAGER" || {
        echo "ERROR: Failed to install curl. Please ensure curl is available in the container."
        exit 1
    }
    ensure_ca_certificates "$PKG_MANAGER"

    # Install Qoder CLI based on edition
    install_qodercli "$EDITION" || exit 1
}

# Execute main function
main
