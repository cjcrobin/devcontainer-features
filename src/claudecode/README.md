
# Claude Code (claudecode)

Installs Claude Code CLI (@anthropic-ai/claude-code) globally via npm. Mounts selected Claude config files from the host machine into the container at creation time.

## Example Usage

```json
"features": {
    "ghcr.io/cjcrobin/devcontainer-features/claudecode:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of @anthropic-ai/claude-code to install (e.g. 'latest', '1.0.17'). Passed directly to 'npm install -g'. | string | latest |
| globalConfigHome | Path whose .claude/ sub-directory and .claude.json are linked into the container's ~/.claude/ and ~/.claude.json. Relative paths are resolved under the host home directory; absolute paths are used as-is inside the container. Defaults to the host home directory itself (empty string = home root). | string | - |
| projectConfigFolder | Path whose .claude/ sub-directory and .claude.json are linked into ${workspaceFolder}/.claude/ and ${workspaceFolder}/.claude.json. Relative paths are resolved under the host home directory; absolute paths are used as-is inside the container. Leave empty to skip project-level config. | string | - |

# Claude Code

Installs the `@anthropic-ai/claude-code` npm package globally so the `claude` binary is available system-wide inside the container.

## Node.js requirement

Claude Code requires Node.js >= 18. If no compatible Node.js is detected at build time, the feature installs **Node.js 20 LTS** via:

- **Debian/Ubuntu**: NodeSource `node_20.x` repository
- **Alpine**: `apk add nodejs npm`
- **RHEL/Fedora/CentOS**: `dnf`/`yum` distribution packages

If Node.js >= 18 is already present, the existing Node.js installation is reused. If npm is missing, npm is installed separately.

## Host config mounting

The feature adds a bind mount of `${localEnv:HOME}` (host home directory) to `/tmp/.devcontainer-host-home` inside the container. This mount is established by Docker before the container starts and is therefore available during all lifecycle hooks.

During `postCreateCommand`, `/usr/local/share/claude-devcontainer/setup.sh` runs as the `remoteUser` and creates selective symlinks:

- **Global**: `{globalConfigHome}/.claude/{item}` → `~/.claude/{item}` for each known item that exists on the host
- **Global**: `{globalConfigHome}/.claude.json` → `~/.claude.json` if the file exists
- **Project** (when `projectConfigFolder` is set): same pattern but into `${workspaceFolder}/`

If a destination already exists as a regular file or directory (not a symlink), it is preserved and skipped.

### Known item list

`agents`, `skills`, `hooks`, `rules`, `Claude.md`, `settings.json`

Any other files or directories in `.claude/` (on either side) are intentionally left untouched.

### Path resolution

`globalConfigHome` and `projectConfigFolder` accept either a **relative path** (resolved under the host home directory) or an **absolute path** (used as-is inside the container). An empty value (the default) means the host home directory itself.

| Option value | Effective container path |
|---|---|
| `` (empty) | `/tmp/.devcontainer-host-home` (host HOME) |
| `claude-settings` | `/tmp/.devcontainer-host-home/claude-settings` |
| `/custom/mount/configs` | `/custom/mount/configs` |

Relative paths are useful when the config directory lives somewhere under the host home directory. Absolute paths are useful when you have added an extra bind mount in your `devcontainer.json` pointing to a directory outside the host home.

### Symlink behaviour

Because the symlink targets are inside the bind mount, writes from the container (e.g., Claude Code updating `settings.json`) propagate back to the host file system immediately.

## Summary

- Claude Code is installed globally via npm.
- Config linking happens during postCreateCommand, not via a login profile hook.
- Both globalConfigHome and projectConfigFolder accept relative paths (resolved under host home) or absolute container paths.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/cjcrobin/devcontainer-features/blob/main/src/claudecode/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
