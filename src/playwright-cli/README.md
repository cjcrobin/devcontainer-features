
# Playwright CLI (playwright-cli)

Installs Playwright CLI (@playwright/cli) globally via npm. Supports Ubuntu/Debian, Alpine, RHEL/Fedora/CentOS and other Linux distributions.

## Example Usage

```json
"features": {
    "ghcr.io/cjcrobin/devcontainer-features/playwright-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of @playwright/cli to install (e.g. 'latest', '0.1.17'). Passed directly to 'npm install -g'. | string | latest |
| installSkills | Run 'playwright-cli install --skills' after installation to install Playwright skills for coding agents. | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/cjcrobin/devcontainer-features/blob/main/src/playwright-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
