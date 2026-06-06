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

    curl -fsSL "$install_url" | bash

    if command -v "$cmd_name" >/dev/null; then
        echo "Qoder CLI ($edition) installed successfully!"
        "$cmd_name" --version || true
        return 0
    else
        echo "ERROR: Qoder CLI ($edition) installation failed!"
        return 1
    fi
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
