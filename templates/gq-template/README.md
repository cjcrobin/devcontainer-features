# GQ Dev Container Template

> **Private Usage** — not intended for general public use.

A pre-configured Dev Container template for Java or Python projects, with AI tool integrations (Claude Code, Codex CLI, Qoder CLI).

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `projectName` | string | `my-project` | 项目名称，用于容器命名和目录路径 |
| `image` | string | `mcr.microsoft.com/devcontainers/java:dev-8-jdk-trixie` | 基础开发镜像（Java 或 Python） |
| `langExtension` | string | `vscjava.vscode-java-pack` | VS Code 语言扩展包（与镜像保持一致） |

## Usage

```jsonc
// .devcontainer/devcontainer.json
{
  "templates": {
    "ghcr.io/cjcrobin/devcontainer-features/gq-template:1": {
      "projectName": "my-project",
      "image": "mcr.microsoft.com/devcontainers/java:dev-8-jdk-trixie",
      "langExtension": "vscjava.vscode-java-pack"
    }
  }
}
```

## Included Tools

- **Claude Code** (`@anthropic-ai/claude-code`)
- **Codex CLI** (OpenAI Codex standalone binary)
- **Qoder CLI** (Global & China editions)
- **Node.js 20**
