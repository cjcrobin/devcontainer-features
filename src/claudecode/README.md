# Claude Code

Installs the [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (`@anthropic-ai/claude-code`) globally via npm.

If a compatible Node.js version (>= 18) is not already present, the feature installs Node.js 20 LTS.

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `version` | string | `latest` | Version of `@anthropic-ai/claude-code` to install. Accepts any valid npm version tag (for example `latest`, `1.0.17`). |
| `globalConfigHome` | string | _(empty)_ | Relative or absolute path. Relative paths are resolved under the host home directory; absolute paths are used as-is inside the container. The feature links `.claude/` items and `.claude.json` from this location into container `~/.claude/` and `~/.claude.json`. Empty means host home root. |
| `projectConfigFolder` | string | _(empty)_ | Relative or absolute path. Relative paths are resolved under the host home directory; absolute paths are used as-is inside the container. When set, the same `.claude/` items and `.claude.json` are linked into `${workspaceFolder}/.claude/` and `${workspaceFolder}/.claude.json`. Leave empty to skip project-level config. |

## Usage

```jsonc
// .devcontainer/devcontainer.json
{
  "features": {
    "ghcr.io/cjcrobin/devcontainer-features/claudecode:1": {}
  }
}
```

### With global host config

Use `globalConfigHome` to source config from a folder under host home:

```jsonc
{
  "features": {
    "ghcr.io/cjcrobin/devcontainer-features/claudecode:1": {
      "globalConfigHome": "claude-config"
    }
  }
}
```

With this example, links are created from host `~/claude-config/.claude/*` and `~/claude-config/.claude.json` into container `~/.claude/*` and `~/.claude.json`.

### With project-level config

Use `projectConfigFolder` to also link into `${workspaceFolder}`:

```jsonc
{
  "features": {
    "ghcr.io/cjcrobin/devcontainer-features/claudecode:1": {
      "projectConfigFolder": "claude-project-config"
    }
  }
}
```

You can combine both options:

```jsonc
{
  "features": {
    "ghcr.io/cjcrobin/devcontainer-features/claudecode:1": {
      "globalConfigHome": "claude-global",
      "projectConfigFolder": "claude-project"
    }
  }
}
```

## Supported Linux distributions

Node.js is installed through the appropriate package manager:

| Distribution family | Package manager | Node.js source |
|---|---|---|
| Debian / Ubuntu | `apt-get` | NodeSource (node_20.x) |
| Alpine | `apk` | Alpine repositories |
| RHEL / Fedora / CentOS | `dnf` / `yum` | Distribution repositories |

If Node.js >= 18 is already present (for example, installed by another feature), the existing installation is reused. If npm is missing, npm is installed separately.

## Config Linking Behavior

The feature bind-mounts host `${HOME}` into the container at `/tmp/.devcontainer-host-home`.

During `postCreateCommand`, `/usr/local/share/claude-devcontainer/setup.sh` links selected config entries if they exist:

- `.claude/agents`
- `.claude/skills`
- `.claude/hooks`
- `.claude/rules`
- `.claude/Claude.md`
- `.claude/settings.json`
- `.claude.json`

Only these known entries are linked. Other existing files in container `.claude/` are left untouched.

If a destination exists as a non-symlink file or directory, it is not overwritten.

## Notes

- The `claude` binary is installed globally and available to all users.
- Config linking runs in `postCreateCommand`, not from `/etc/profile.d`.
- `globalConfigHome` and `projectConfigFolder` accept relative paths (resolved under host home) or absolute container paths.
- First use of `claude` will prompt for authentication with your Anthropic account.
