# HKUDS/nanobot

仓库地址：https://github.com/HKUDS/nanobot  
快照要点：`stars 25864`，`open issues 710`，`default branch main`，`最近推送 0 天`

## 架构
- 形态：Python 轻量化 OpenClaw 风格实现。
- 顶层结构：`nanobot`（核心）、`bridge`（通道桥接）、`tests`、`docker-compose.yml`。
- 通过 `pyproject.toml` 管理，强调“小体量 + 可读性”路线。
- 支持多 IM/模型/MCP 等能力，但整体工程规模相对主线更小。

## 依赖
- 包管理：`pyproject.toml`
- 依赖规模：`约 25`
- 关键依赖：
  - 模型层：`litellm`
  - 框架与配置：`typer`、`pydantic`、`pydantic-settings`
  - 网络与通道：`httpx`、`websockets`、`slack-sdk`、`lark-oapi`、`python-telegram-bot`
  - 协议扩展：`mcp`

## 风险
- 维护压力风险：Issue 数量高，说明迭代快但治理压力也大。
- 成熟度风险：轻量实现在极端场景与复杂通道组合下的稳定性需额外验证。
- 兼容性风险：与官方主线能力可能存在行为差异。

## 上线建议
- 推荐路径：
  1. 先用于 POC/灰度，不直接替代官方主链路。
  2. 对关键流程（消息收发、记忆、定时任务）做压力与故障演练。
  3. 对第三方通道 token 做隔离，避免跨环境复用。
- 结论：`POC/灰度推荐`。
