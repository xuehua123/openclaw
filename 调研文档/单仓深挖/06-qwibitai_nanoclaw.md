# qwibitai/nanoclaw

仓库地址：https://github.com/qwibitai/nanoclaw  
快照要点：`stars 15385`，`open issues 202`，`default branch main`，`最近推送 1 天`

## 架构
- 形态：TypeScript 轻量替代实现，强调容器隔离。
- 顶层结构：`src`、`container`、`setup`、`skills-engine`、`scripts`、`config-examples`。
- README 明确主张“Agent 在独立容器运行”，核心卖点是隔离边界与简化代码规模。
- 更适合安全导向/自定义较强的团队路线。

## 依赖
- 包管理：Node 生态（根包无 packageManager 字段）
- 依赖规模：`dependencies 9`，`devDependencies 9`
- 关键依赖：
  - 通道：`@whiskeysockets/baileys`
  - 存储：`better-sqlite3`
  - 调度与日志：`cron-parser`、`pino`
  - 配置与校验：`yaml`、`zod`

## 风险
- 替代实现风险：与官方主线能力、插件、升级节奏可能不一致。
- 安全声明验证风险：隔离设计需结合真实部署配置验证，不可只看 README。
- 生态兼容风险：部分社区技能/工具可能默认面向官方主线。

## 上线建议
- 推荐在“安全优先场景”做灰度：
  1. 先验证容器边界与持久化策略。
  2. 建立兼容性回归用例（至少覆盖消息通道+技能调用）。
  3. 保留回切到官方主线的方案。
- 结论：`条件推荐（安全导向）`。
