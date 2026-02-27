# zhayujie/chatgpt-on-wechat

仓库地址：https://github.com/zhayujie/chatgpt-on-wechat  
快照要点：`stars 41542`，`open issues 350`，`default branch master`，`最近推送 1 天`

## 架构
- 形态：Python 多通道 Agent 框架。
- 顶层目录体现标准分层：`agent`、`bridge`、`channel`、`plugins`、`skills`、`models`、`voice`。
- 入口为 `app.py`，同时提供 `Dockerfile` 与 `docker/`，支持长期运行场景。
- 关注点偏“企业/IM 平台接入 + 工具扩展 + 技能系统”。

## 依赖
- 包管理：`requirements.txt`（pip）
- 依赖规模：`约 21`
- 关键依赖：
  - 模型与网络：`openai`、`aiohttp`、`requests`
  - 通道/格式：`wechatpy`、`lark-oapi`、`dingtalk_stream`
  - 调度与配置：`croniter`、`python-dotenv`、`PyYAML`

## 风险
- 运行权限风险：项目能力覆盖系统资源与外部平台，部署权限过大时风险放大。
- 依赖老化风险：部分核心依赖版本线偏旧，需验证与当前模型 API 的兼容性。
- 渠道耦合风险：多平台支持带来配置复杂度与排障难度。

## 上线建议
- 若用于生产：
  1. 仅启用必要渠道插件，其他默认关闭。
  2. 使用容器隔离，限制文件系统和网络出站。
  3. 关键 token 分仓分环境管理，不与业务系统共用。
  4. 建立消息审计与告警，重点监控工具调用行为。
- 结论：`条件推荐`（适合有运维能力团队）。
