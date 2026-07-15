# Claude Code

Installs the `@anthropic-ai/claude-code` npm package globally so the `claude` binary is available system-wide inside the container.

## Node.js requirement

Claude Code requires Node.js >= 18. If no compatible Node.js is detected at build time, the feature installs **Node.js 20 LTS** via:

- **Debian/Ubuntu**: NodeSource `node_20.x` repository
- **Alpine**: `apk add nodejs npm`
- **RHEL/Fedora/CentOS**: `dnf`/`yum` distribution packages

## Host config mounting

The feature adds a bind mount of `${localEnv:HOME}` (host home directory) to `/tmp/.devcontainer-host-home` inside the container. This mount is established by Docker before the container starts and is therefore available during all lifecycle hooks.

During `postCreateCommand`, `/usr/local/share/claude-devcontainer/setup.sh` runs as the `remoteUser` and creates selective symlinks:

- **Global**: `{globalConfigHome}/.claude/{item}` → `~/.claude/{item}` for each known item that exists on the host
- **Global**: `{globalConfigHome}/.claude.json` → `~/.claude.json` if the file exists
- **Project** (when `projectConfigFolder` is set): same pattern but into `${workspaceFolder}/`

### Known item list

`agents`, `skills`, `hooks`, `rules`, `Claude.md`, `settings.json`

Any other files or directories in `.claude/` (on either side) are intentionally left untouched.

### Path resolution

`globalConfigHome` and `projectConfigFolder` accept paths **relative to the host home directory**.  An empty value (the default) means the host home directory itself.  The bind mount maps host HOME → `/tmp/.devcontainer-host-home`, so the setup script appends the relative path directly:

```
option value    = claude-settings          (relative to host HOME)
mounted path    = /tmp/.devcontainer-host-home/claude-settings
```

### Symlink behaviour

Because the symlink targets are inside the bind mount, writes from the container (e.g., Claude Code updating `settings.json`) propagate back to the host file system immediately.
