#!/bin/bash
# 修复 volume 权限
sudo chown -R vscode:vscode /home/vscode/.m2

# 拷贝配置文件
mkdir -p /home/vscode/.m2
cp .devcontainer/settings.xml /home/vscode/.m2/settings.xml
sudo chown vscode:vscode /home/vscode/.m2/settings.xml

sudo mkdir -p /opt/settings
sudo chown -R vscode:vscode /opt/settings
cp .devcontainer/server.properties /opt/settings/server.properties

sudo mkdir /data/logs
sudo chown -R vscode:vscode /data/logs

sudo chown -R vscode:vscode ${workspaceFolder}/.vscode/settings.json

sudo apt update
sudo apt install maven -y

# skills 统一用 claude 的，通过 symlink 共享
ln -sfn "${workspaceFolder}/.claude/skills" "${workspaceFolder}/.qoder/skills"
ln -sfn "${workspaceFolder}/.claude/skills" "${workspaceFolder}/.codex/skills"