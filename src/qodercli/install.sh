#!/bin/sh
set -eu

EDITION="${EDITION:-global}"

detect_package_manager() {
    for pm in apt-get apk dnf yum; do
        if command -v "$pm" >/dev/null; then
            case "$pm" in
                apt-get) echo "apt" ;;
                *) echo "$pm" ;;
            esac
            return 0
        fi
    done
    echo "unknown"
    return 1
}

install_packages() {
    local pkg_manager="$1"; shift
    case "$pkg_manager" in
        apt)     apt-get update && apt-get install -y "$@" ;;
        apk)     apk add --no-cache "$@" ;;
        dnf|yum) "$pkg_manager" install -y "$@" ;;
        *)       return 1 ;;
    esac
}

ensure_curl() {
    command -v curl >/dev/null && return 0
    install_packages "$1" curl
}

ensure_ca_certificates() {
    case "$1" in
        apt)     install_packages apt ca-certificates ;;
        apk)     install_packages apk ca-certificates ;;
        dnf|yum) install_packages "$1" ca-certificates ;;
    esac
}

install_qodercli() {
    local edition="$1" install_url="" cmd_name="" qoder_dir=""

    case "$edition" in
        cn)
            install_url="https://qoder.com.cn/install"
            cmd_name="qoderclicn"
            qoder_dir=".qoder-cn"
            ;;
        global|*)
            install_url="https://qoder.com/install"
            cmd_name="qodercli"
            qoder_dir=".qoder"
            ;;
    esac

    # Install to $HOME (=/root during Docker build)
    curl -fsSL "$install_url" | bash

    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v "$cmd_name" >/dev/null 2>&1; then
        echo "ERROR: Qoder CLI ($edition) installation failed"
        return 1
    fi
    echo "Qoder CLI ($edition) installed:"
    "$cmd_name" --version || true

    # Copy to /usr/local/ so all users can access it
    local src="$HOME/$qoder_dir"
    local dst="/usr/local/lib/$qoder_dir"
    cp -r "$src" "$dst"
    chmod -R a+rX "$dst"

    # Symlink /usr/local/bin/<cmd> -> versioned binary
    for bin_file in "$dst/bin/$cmd_name"/*; do
        if [ -f "$bin_file" ] && [ -x "$bin_file" ]; then
            ln -sf "$bin_file" "/usr/local/bin/$cmd_name"
        fi
    done

    echo "Available system-wide: /usr/local/bin/$cmd_name"
}

main() {
    echo "Activating feature 'qodercli' (edition: $EDITION)"
    PKG_MANAGER=$(detect_package_manager)
    ensure_curl "$PKG_MANAGER" || { echo "ERROR: Cannot install curl"; exit 1; }
    ensure_ca_certificates "$PKG_MANAGER"
    install_qodercli "$EDITION" || exit 1
}

main
