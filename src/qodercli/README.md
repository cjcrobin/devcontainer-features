
# Qoder CLI (qodercli)

Installs the Qoder CLI globally (supports both Global and China editions)

## Example Usage

```json
"features": {
    "ghcr.io/cjcrobin/devcontainer-features/qodercli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| edition | Qoder CLI edition to install. 'global' installs from qoder.com, 'cn' installs from qoder.com.cn. | string | global |

# Qoder CLI

Installs the Qoder CLI via the official install script. The edition is selectable via the `edition` option.

## Installation

Depending on the selected edition:

- **Global** (default): `curl -fsSL https://qoder.com/install | bash` — binary: `qodercli`
- **China (CN)**: `curl -fsSL https://qoder.com.cn/install | bash` — binary: `qoderclicn`

## Usage

After installation, the CLI command will be available globally in the container:

- Global edition: `qodercli`
- China edition: `qoderclicn`


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/cjcrobin/devcontainer-features/blob/main/src/qodercli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
