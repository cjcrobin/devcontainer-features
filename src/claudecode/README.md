# Claude Code

Installs the [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (`@anthropic-ai/claude-code`) globally via npm. Automatically installs Node.js 20 LTS if a compatible version (>= 18) is not already present.

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `version` | string | `latest` | Version of `@anthropic-ai/claude-code` to install. Accepts any valid npm version tag (e.g. `latest`, `1.0.17`). |
| `configHome` | string | _(empty)_ | Parent directory for `.claude/` and `.claude.json`. Leave empty to use the default `~`. When set, a `/etc/profile.d` script creates symlinks at login time so config persists in a shared or mounted directory. |

## Usage

```jsonc
// .devcontainer/devcontainer.json
{
  "features": {
    "ghcr.io/cjcrobin/devcontainer-features/claudecode:1": {}
  }
}
```

### With a custom config directory

Useful when `.claude/` and `.claude.json` should be stored in a bind-mounted workspace so settings survive container rebuilds:

```jsonc
{
  "features": {
    "ghcr.io/cjcrobin/devcontainer-features/claudecode:1": {
      "configHome": "/workspaces/myproject"
    }
  }
}
```

At first login the profile script will create:

```
/workspaces/myproject/.claude/      ← symlinked from ~/.claude
/workspaces/myproject/.claude.json  ← symlinked from ~/.claude.json
```

## Supported Linux distributions

Node.js is installed through the appropriate package manager:

| Distribution family | Package manager | Node.js source |
|---|---|---|
| Debian / Ubuntu | `apt-get` | NodeSource (node_20.x) |
| Alpine | `apk` | Alpine repositories |
| RHEL / Fedora / CentOS | `dnf` / `yum` | Distribution repositories |

If Node.js >= 18 is already present (e.g. installed by another feature), the existing installation is reused.

## Notes

- The `claude` binary is installed globally and available to all users.
- The `configHome` symlinks are created lazily at login via `/etc/profile.d/claude-config-home.sh`. If the target directory does not exist yet (e.g. a workspace volume not yet mounted), the script retries on the next login.
- First use of `claude` will prompt for authentication with your Anthropic account.
