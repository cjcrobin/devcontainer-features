# Dev Container Features

This repository contains [Dev Container Features](https://containers.dev/implementors/features/) for installing Qoder CLI tools in development containers.

## Features

| Feature | Description | Usage |
|---------|-------------|-------|
| [qodercli](src/qodercli) | Qoder CLI (Global & China editions) | `ghcr.io/cjcrobin/devcontainer-features/qodercli:1` |

## Usage

Add the feature to your `devcontainer.json`:

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

### Test the feature

```bash
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
│   └── qodercli/           # Qoder CLI feature (Global & CN)
│       ├── devcontainer-feature.json
│       ├── install.sh
│       ├── NOTES.md
│       └── README.md
├── test/
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
