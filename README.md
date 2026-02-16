# Claude Code Docker Runner 文档

## 1. 概述

本项目使用 Docker 运行 Claude Code，并提供两个脚本入口：

- `./claude.sh`：推荐入口。负责环境变量写入、变量转发与隔离策略。
- `./run-claude.sh`：底层入口。提供完整构建、运行和维护参数。
- `./cc.sh`：入口脚本。提供本地代理配置。（修改example来获取本地配置）

## 2. 前置条件

- Docker 已安装并可用。
- 当前用户具备 Docker 执行权限。
- 本地已安装 Claude CLI（用于宿主机登录状态准备）。

初始化执行权限：

```bash
chmod +x ./claude.sh ./run-claude.sh
```

## 3. 快速开始

首次启动（构建镜像并启动）：

```bash
./claude.sh --rebuild
```

检查登录状态：

```bash
./claude.sh claude auth status
```

未登录时执行：

```bash
./claude.sh claude /login
```

local文件启动方式：

```bash
bash cc.sh
```

**分析其他文件夹下的项目**：用 `-w` 指定要挂载为工作区的目录，容器会以该目录为工作区启动，即可让 Claude 分析该项目。

```bash
# 使用绝对路径
bash cc.sh -w /path/to/your/project

# 或启动后执行单条指令，例如：
bash cc.sh -w /path/to/your/project claude "分析这个项目的结构和依赖"
```

## 4. SSH密钥管理

创建本地密钥来隔离本机完整的ssh密钥。

```bash
ssh-keygen -t ed25519 -f /path/to/repo/.ssh/Claude -C "ClaudeCode"
```


## 5. 命令参考

### 5.1 常用运行命令

进入交互式容器：

```bash
./claude.sh
```

执行单条 Claude 指令：

```bash
./claude.sh claude "analyze this codebase"
```

一次性执行并清理容器：

```bash
./claude.sh --rm --no-interactive claude auth status
```

### 5.2 安全相关命令

高隔离模式（推荐敏感仓库）：

```bash
./claude.sh --safe --no-privileged --no-gpg
```

### 5.3 维护命令

重建镜像（脚本/依赖变更后）：

```bash
./claude.sh --rebuild
```

重建容器（镜像不变）：

```bash
./claude.sh --recreate
```

清理脚本管理的已停止容器：

```bash
./run-claude.sh --remove-containers
```

## 6. 场景指引

首次使用当前仓库：

```bash
./claude.sh --rebuild
./claude.sh claude auth status
```

日常开发：

```bash
./claude.sh
```

敏感任务审查：

```bash
./claude.sh --safe --no-privileged --no-gpg claude "review this repository for secrets"
```

容器状态异常：

```bash
./claude.sh --recreate
./claude.sh --rebuild
```

## 7. 环境变量

`./claude.sh` 会确保并加载以下变量：

- `ANTHROPIC_BASE_URL`
- `ANTHROPIC_AUTH_TOKEN`
- `API_TIMEOUT_MS`
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`

## 8. CCometixLine 集成

镜像构建阶段自动安装 `@cometix/ccline`，并配置 Claude `statusLine`：

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/ccline/ccline",
    "padding": 0
  }
}
```

打开配置界面：

```bash
./claude.sh ccline --config
```

检查可执行路径：

```bash
./claude.sh command -v ccline
./claude.sh ls -l ~/.claude/ccline/ccline
```
