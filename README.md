# Dev Container Features

This repository contains [Dev Container Features](https://containers.dev/implementors/features/) for development containers.

## Features

| Feature | Description | Usage |
|---------|-------------|-------|
| [claudecode](src/claudecode) | Claude Code CLI (`@anthropic-ai/claude-code`) | `ghcr.io/cjcrobin/devcontainer-features/claudecode:1` |
| [qodercli](src/qodercli) | Qoder CLI (Global & China editions) | `ghcr.io/cjcrobin/devcontainer-features/qodercli:1` |

## Usage

Add the feature to your `devcontainer.json`:

### Claude Code — Default

```json
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/cjcrobin/devcontainer-features/claudecode:1": {}
    }
}
```

### Claude Code — Pinned version

```json
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/cjcrobin/devcontainer-features/claudecode:1": {
            "version": "1.0.17"
        }
    }
}
```

### Claude Code — With host config mounted

Mounts `.claude/` and `.claude.json` from the host so credentials and settings survive container rebuilds:

```json
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/cjcrobin/devcontainer-features/claudecode:1": {
            "globalConfigHome": "/host/home/username",
            "projectConfigFolder": "/host/home/username/myproject"
        }
    }
}
```

### Claude Code Options

| Option | Description | Default |
|--------|-------------|--------|
| `version` | Version of `@anthropic-ai/claude-code` to install (e.g. `latest`, `1.0.17`) | `latest` |
| `globalConfigHome` | Host path whose `.claude/` and `.claude.json` are linked into `~/.claude/` and `~/.claude.json` | `""` (uses `~`) |
| `projectConfigFolder` | Host path whose `.claude/` and `.claude.json` are linked into `${workspaceFolder}` | `""` (skipped) |

---

### Qoder CLI — Global Edition (default)

```json
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/cjcrobin/devcontainer-features/qodercli:1": {}
    }
}
```

### Qoder CLI — China Edition

```json
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/cjcrobin/devcontainer-features/qodercli:1": {
            "edition": "cn"
        }
    }
}
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `edition` | `global` installs from qoder.com, `cn` installs from qoder.com.cn | `global` |

## Building

```bash
devcontainer features publish ./src --namespace cjcrobin/devcontainer-features
```

## Testing

### Test a specific feature

```bash
devcontainer features test -f claudecode .
devcontainer features test -f qodercli .
```

### Test all features

```bash
devcontainer features test .
```

### Test against a specific base image

```bash
devcontainer features test --skip-scenarios -f qodercli -i mcr.microsoft.com/devcontainers/base:ubuntu .
```

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── release.yaml    # Publish features to GHCR
│       └── test.yaml       # CI test workflow
├── src/
│   ├── claudecode/         # Claude Code CLI feature
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   ├── NOTES.md
│   │   └── README.md
│   └── qodercli/           # Qoder CLI feature (Global & CN)
│       ├── devcontainer-feature.json
│       ├── install.sh
│       ├── NOTES.md
│       └── README.md
├── test/
│   ├── claudecode/         # Tests for claudecode
│   │   ├── alpine.sh
│   │   ├── basic.sh
│   │   ├── scenarios.json
│   │   ├── test.sh
│   │   ├── with_config_home.sh
│   │   ├── with_global_config.sh
│   │   └── with_project_config.sh
│   └── qodercli/           # Tests for qodercli
│       ├── basic.sh
│       ├── cn.sh
│       ├── scenarios.json
│       └── test.sh
├── .gitignore
├── LICENSE
└── README.md
```

## License

This project is licensed under the [MIT License](LICENSE).
