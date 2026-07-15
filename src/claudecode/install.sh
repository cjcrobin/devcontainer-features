#!/bin/sh
set -eu

VERSION="${VERSION:-latest}"
GLOBAL_CONFIG_HOME="${GLOBALCONFIGHOME:-}"
PROJECT_CONFIG_FOLDER="${PROJECTCONFIGFOLDER:-}"

# ---------------------------------------------------------------------------
# Package manager helpers
# ---------------------------------------------------------------------------

detect_package_manager() {
    for pm in apt-get apk dnf yum; do
        if command -v "$pm" >/dev/null 2>&1; then
            case "$pm" in
                apt-get) echo "apt" ;;
                *) echo "$pm" ;;
            esac
            return 0
        fi
    done
    echo "ERROR: No supported package manager found (apt-get, apk, dnf, yum)." >&2
    return 1
}

install_packages() {
    pkg_manager="$1"; shift
    case "$pkg_manager" in
        apt)     apt-get update -y && apt-get install -y "$@" ;;
        apk)     apk add --no-cache "$@" ;;
        dnf|yum) "$pkg_manager" install -y "$@" ;;
        *)       echo "ERROR: Unsupported package manager: $pkg_manager" >&2; return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# Node.js / npm
# ---------------------------------------------------------------------------

# Claude Code requires Node.js >= 18.
ensure_node_npm() {
    pkg_manager="$1"

    # Check whether an acceptable Node.js is already present.
    node_ok=0
    if command -v node >/dev/null 2>&1; then
        node_major=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
        if [ "${node_major:-0}" -ge 18 ] 2>/dev/null; then
            node_ok=1
        fi
    fi

    if [ "$node_ok" = "1" ]; then
        if command -v npm >/dev/null 2>&1; then
            echo "Node.js $(node --version) and npm $(npm --version) already available — skipping installation."
            return 0
        fi
        # Node.js is present and new enough, but npm is missing (common on
        # Ubuntu 24.04+ where the distro nodejs package omits npm).
        echo "Node.js $(node --version) found but npm missing — installing npm separately..."
        case "$pkg_manager" in
            apt)     install_packages apt npm ;;
            apk)     install_packages apk npm ;;
            dnf|yum) install_packages "$pkg_manager" npm ;;
            *)       echo "ERROR: Cannot install npm: unsupported package manager." >&2; return 1 ;;
        esac
        echo "Node.js $(node --version) and npm $(npm --version) installed."
        return 0
    fi

    # Node.js is absent or too old — install a fresh LTS release.
    echo "Node.js not found or too old (need >= 18). Installing Node.js 20 LTS..."

    case "$pkg_manager" in
        apt)
            # Use the NodeSource setup script which handles GPG, repo, and
            # apt pinning so that NodeSource's nodejs (bundled with npm) is
            # preferred over any distro-provided nodejs package.
            install_packages apt ca-certificates curl
            curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
            install_packages apt nodejs
            ;;
        apk)
            # Alpine 3.17+ ships Node.js 18+.
            install_packages apk nodejs npm
            ;;
        dnf|yum)
            install_packages "$pkg_manager" nodejs npm
            ;;
        *)
            echo "ERROR: Cannot install Node.js: no supported package manager." >&2
            return 1
            ;;
    esac

    echo "Node.js $(node --version) and npm $(npm --version) installed."
}

# ---------------------------------------------------------------------------
# Claude Code CLI
# ---------------------------------------------------------------------------

install_claude_code() {
    version="$1"

    if [ "$version" = "latest" ]; then
        pkg="@anthropic-ai/claude-code"
    else
        pkg="@anthropic-ai/claude-code@${version}"
    fi

    echo "Installing Claude Code: $pkg"
    npm install -g "$pkg"

    if ! command -v claude >/dev/null 2>&1; then
        echo "ERROR: 'claude' command not found after installation." >&2
        return 1
    fi

    echo "Claude Code installed: $(claude --version 2>/dev/null || echo '(version check unavailable)')"
}

# ---------------------------------------------------------------------------
# postCreateCommand setup script
#
# The setup script is written as a NOWDOC (single-quoted delimiter) so that
# no shell variables are expanded at write time.  Only the options env file
# uses double-quoted expansion to bake the feature option values in.
# ---------------------------------------------------------------------------

write_setup_script() {
    cfg_dir="/usr/local/share/claude-devcontainer"
    mkdir -p "$cfg_dir"

    # Bake the resolved option values into a separate env file.
    # This file is sourced by setup.sh at postCreateCommand time.
    cat > "$cfg_dir/feature-options.env" << OPTS
CLAUDE_GLOBAL_CONFIG_HOME=${GLOBAL_CONFIG_HOME}
CLAUDE_PROJECT_CONFIG_FOLDER=${PROJECT_CONFIG_FOLDER}
OPTS

    # Write the setup script.  NOWDOC: nothing inside is expanded here.
    cat > "$cfg_dir/setup.sh" << 'SETUP_SCRIPT'
#!/bin/sh
set -eu

# Load feature options baked in at image build time.
. /usr/local/share/claude-devcontainer/feature-options.env

# Known items to selectively sync inside a .claude/ directory.
# Files or sub-directories that are absent on the host are silently skipped.
CLAUDE_ITEMS="agents skills hooks rules Claude.md settings.json"

# The host HOME is bind-mounted here by the devcontainer feature.
# _CLAUDE_HOST_HOME is injected via containerEnv; fall back to the default path.
HOST_HOME_MOUNT="${_CLAUDE_HOST_HOME:-/tmp/.devcontainer-host-home}"

# ---------------------------------------------------------------------------
# resolve_in_mount <relative_path>
#   Returns the path within the host-home bind mount for a given relative
#   path (relative to host home directory).  An empty path defaults to the
#   mount root (= host HOME itself).
# ---------------------------------------------------------------------------
resolve_in_mount() {
    rel="$1"

    if [ -z "$rel" ]; then
        echo "$HOST_HOME_MOUNT"
        return
    fi

    # Strip any accidental leading slash so paths are truly relative.
    echo "$HOST_HOME_MOUNT/${rel#/}"
}

# ---------------------------------------------------------------------------
# link_if_exists <src> <dst>
#   Creates or updates a symlink dst -> src if src exists.
#   Skips when dst is already a regular file/directory (not a symlink) to
#   preserve any file the user may have already placed there.
# ---------------------------------------------------------------------------
link_if_exists() {
    src="$1"
    dst="$2"

    if [ ! -e "$src" ]; then
        return 0   # source absent — skip silently
    fi

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        _bn=$(basename "$dst")
        echo "  skip (existing non-symlink): $_bn"
        return 0
    fi

    ln -sfn "$src" "$dst"
    echo "  linked: $dst -> $src"
}

# ---------------------------------------------------------------------------
# setup_items <staging_dir> <target_dir>
#   Links each known .claude/ item and .claude.json from the staging directory
#   into the target directory, creating .claude/ only when needed.
#   Other files already present in target/.claude/ are left untouched.
# ---------------------------------------------------------------------------
setup_items() {
    staging="$1"
    target="$2"

    src_claude_dir="$staging/.claude"
    src_claude_json="$staging/.claude.json"

    if [ ! -d "$src_claude_dir" ] && [ ! -f "$src_claude_json" ]; then
        echo "  nothing found under $staging — skipping"
        return 0
    fi

    # .claude/ items (selective — only the known list)
    if [ -d "$src_claude_dir" ]; then
        mkdir -p "$target/.claude"
        for item in $CLAUDE_ITEMS; do
            link_if_exists "$src_claude_dir/$item" "$target/.claude/$item"
        done
    fi

    # .claude.json
    link_if_exists "$src_claude_json" "$target/.claude.json"
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
    echo "==> Claude Code devcontainer config setup"

    if [ ! -d "$HOST_HOME_MOUNT" ]; then
        echo "WARNING: Host home mount not found at $HOST_HOME_MOUNT — skipping config setup." >&2
        exit 0
    fi

    # ---- Global config  (~/.claude/* and ~/.claude.json) ----
    global_staging=$(resolve_in_mount "${CLAUDE_GLOBAL_CONFIG_HOME:-}")
    echo "--> Global config  source : $global_staging"
    echo "                   target : $HOME"
    setup_items "$global_staging" "$HOME"

    # ---- Project config  (${workspaceFolder}/.claude/* and .claude.json) ----
    if [ -n "${CLAUDE_PROJECT_CONFIG_FOLDER:-}" ]; then
        project_staging=$(resolve_in_mount "$CLAUDE_PROJECT_CONFIG_FOLDER")
        # postCreateCommand CWD is set to containerWorkspaceFolder by the runtime.
        workspace="${CONTAINER_WORKSPACE_FOLDER:-${WORKSPACE_FOLDER:-$PWD}}"
        echo "--> Project config source : $project_staging"
        echo "                   target : $workspace"
        setup_items "$project_staging" "$workspace"
    fi

    echo "==> Claude Code devcontainer config setup complete"
}

main
SETUP_SCRIPT

    chmod -R a+rX "$cfg_dir"
    chmod +x "$cfg_dir/setup.sh"
    echo "Setup script written to $cfg_dir/setup.sh"
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

main() {
    echo "Activating feature 'claudecode' (version: ${VERSION})"
    PKG_MANAGER=$(detect_package_manager)
    ensure_node_npm "$PKG_MANAGER"
    install_claude_code "$VERSION"
    write_setup_script
    echo "Feature 'claudecode' installation complete."
}

main
