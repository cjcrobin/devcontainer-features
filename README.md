# Dev Container Features

This repository contains [Dev Container Features](https://containers.dev/implementors/features/) for development containers.

## Features

| Feature | Description | Usage |
|---------|-------------|-------|
| [claudecode](src/claudecode) | Claude Code CLI (`@anthropic-ai/claude-code`) | `ghcr.io/cjcrobin/devcontainer-features/claudecode:1` |
| [codexcli](src/codexcli) | OpenAI Codex CLI (standalone binary) | `ghcr.io/cjcrobin/devcontainer-features/codexcli:1` |
| [playwright-cli](src/playwright-cli) | Playwright CLI (`@playwright/cli`) | `ghcr.io/cjcrobin/devcontainer-features/playwright-cli:1` |
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

### Codex CLI

Installs [OpenAI Codex CLI](https://github.com/openai/codex) via the official standalone installer. Downloads a pre-built statically-linked (musl) binary — works on **all Linux distributions** with no runtime dependencies.

```json
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/cjcrobin/devcontainer-features/codexcli:1": {}
    }
}
```

No options — no presets. Run `codex` after container creation to sign in or configure your environment.

---

### Playwright CLI — Default

Installs [Playwright CLI](https://github.com/microsoft/playwright-cli) (`@playwright/cli`) globally via npm. Provides a token-efficient CLI interface for browser automation, designed for coding agents.

```json
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/cjcrobin/devcontainer-features/playwright-cli:1": {}
    }
}
```

### Playwright CLI — Pinned version, skip skills

```json
{
    "name": "My Dev Container",
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/cjcrobin/devcontainer-features/playwright-cli:1": {
            "version": "0.1.17",
            "installSkills": false
        }
    }
}
```

### Playwright CLI Options

| Option | Description | Default |
|--------|-------------|--------|
| `version` | Version of `@playwright/cli` to install (e.g. `latest`, `0.1.17`) | `latest` |
| `installSkills` | Run `playwright-cli install --skills` after installation | `true` |

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
devcontainer features test -f codexcli .
devcontainer features test -f playwright-cli .
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
│   ├── codexcli/           # OpenAI Codex CLI feature
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   └── README.md
│   ├── playwright-cli/     # Playwright CLI feature
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
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
│   ├── codexcli/           # Tests for codexcli
│   │   ├── alpine.sh
│   │   ├── basic.sh
│   │   ├── fedora.sh
│   │   ├── scenarios.json
│   │   └── test.sh
│   ├── playwright-cli/     # Tests for playwright-cli
│   │   ├── alpine.sh
│   │   ├── basic.sh
│   │   ├── no_skills.sh
│   │   ├── scenarios.json
│   │   ├── test.sh
│   │   └── with_preinstalled_node.sh
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
