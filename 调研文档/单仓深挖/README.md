# 单仓深挖（Top8）

本目录按“单仓逐个输出”的方式，对当前 Top8 项目分别给出：
- 架构
- 依赖
- 风险
- 上线建议

数据基于本地快照：
- `data/single_repo_raw/*.json`
- `data/openclaw_deepdive_top8_live.json`

## 仓库列表
1. [openclaw/openclaw](./01-openclaw_openclaw.md)
2. [zhayujie/chatgpt-on-wechat](./02-zhayujie_chatgpt-on-wechat.md)
3. [VoltAgent/awesome-openclaw-skills](./03-VoltAgent_awesome-openclaw-skills.md)
4. [HKUDS/nanobot](./04-HKUDS_nanobot.md)
5. [CherryHQ/cherry-studio](./05-CherryHQ_cherry-studio.md)
6. [qwibitai/nanoclaw](./06-qwibitai_nanoclaw.md)
7. [hesamsheikh/awesome-openclaw-usecases](./07-hesamsheikh_awesome-openclaw-usecases.md)
8. [openclaw/clawhub](./08-openclaw_clawhub.md)

## 快速矩阵
| Repo | 定位 | 上线结论 |
|---|---|---|
| openclaw/openclaw | 官方核心运行时 | 生产基线（推荐） |
| zhayujie/chatgpt-on-wechat | 多渠道 Agent 框架 | 条件推荐 |
| VoltAgent/awesome-openclaw-skills | 技能目录列表 | 不直接上线（资料库） |
| HKUDS/nanobot | 轻量替代实现 | POC/灰度推荐 |
| CherryHQ/cherry-studio | 桌面 AI 工作台 | 客户端侧可用，服务端慎用 |
| qwibitai/nanoclaw | 容器隔离型替代实现 | 条件推荐（安全导向） |
| hesamsheikh/awesome-openclaw-usecases | 用例库 | 不直接上线（资料库） |
| openclaw/clawhub | 技能注册与分发 | 生产可用（需内容治理） |
