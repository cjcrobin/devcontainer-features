# Codex CLI (codexcli)

Installs [OpenAI Codex CLI](https://github.com/openai/codex) using the official standalone installer. The installer downloads a pre-built statically-linked (musl) binary, so it works on **all Linux distributions** without requiring Node.js or any other runtime.

## Usage

```json
"features": {
    "ghcr.io/cjcrobin/devcontainer-features/codexcli:1": {}
}
```

## How It Works

1. Detects the available package manager (apt-get, apk, dnf, yum, zypper, pacman).
2. Ensures `curl` and `ca-certificates` are installed (installs them if missing).
3. Runs the official installer: `curl -fsSL https://chatgpt.com/codex/install.sh | sh`
4. Verifies the `codex` binary is available and symlinks it to `/usr/local/bin` for system-wide access.

## No Presets

This feature does not configure any API keys, models, or preferences. Run `codex` after container creation to sign in or set up your environment.
