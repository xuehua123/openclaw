# openclaw/openclaw

仓库地址：https://github.com/openclaw/openclaw  
快照要点：`stars 233508`，`open issues 8441`，`default branch main`，`最近推送 0 天`

## 架构
- 形态：TypeScript 大型多模块仓库。
- 顶层结构显示为“平台级工程”：`apps`、`packages`、`extensions`、`skills`、`src`、`ui`、`test`。
- 运行形态偏“网关 + 通道 + 技能 + CLI/TUI/UI”组合，适配多消息渠道与多端。
- 从脚本规模看（大量 `gateway:*`、`ui:*`、`tui:*`、`test:*`），具备完整工程化和持续发布能力。

## 依赖
- 包管理：`pnpm@10.23.0`
- 依赖规模（根包）：`dependencies 54`，`devDependencies 19`
- 关键依赖方向：
  - 通道与 IM：`@whiskeysockets/baileys`、`@slack/bolt`、`@line/bot-sdk`、`@discordjs/voice`
  - 网关/API：`express`
  - Agent 协议/工具：`@agentclientprotocol/sdk`
  - CLI/体验：`commander`、`chalk`

## 风险
- 复杂度风险高：模块多、依赖广、集成面大。
- 供应链风险：跨多个渠道 SDK，升级联动成本高。
- 运维风险：Issue 体量大，需自行建立“可控版本线”。
- 安全面风险：一旦开启多通道与高权限技能，密钥与动作边界需要严格治理。

## 上线建议
- 作为生产核心时建议：
  1. 固定 release/tag，不直接跟 `main`。
  2. 首次只开最少通道（例如 1-2 个），分阶段放量。
  3. 技能白名单 + 最小权限 token + 审计日志。
  4. 网关进程和插件执行环境隔离部署。
- 结论：`生产基线（推荐）`，但必须配套治理体系。
