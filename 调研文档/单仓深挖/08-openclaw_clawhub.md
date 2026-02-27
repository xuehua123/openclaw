# openclaw/clawhub

仓库地址：https://github.com/openclaw/clawhub  
快照要点：`stars 3021`，`open issues 324`，`default branch main`，`最近推送 1 天`

## 架构
- 形态：官方技能注册与分发平台（Web 应用）。
- 顶层结构：`src`、`server`、`convex`、`packages`、`e2e`、`docs`。
- 从依赖看是前后端一体化应用，承担技能检索、发布、版本管理等功能。
- 在 OpenClaw 生态中属于“分发生态基础设施”。

## 依赖
- 包管理：Node 生态（根包未显式 packageManager）
- 依赖规模：`dependencies 33`，`devDependencies 19`
- 关键依赖方向：
  - 应用框架：`@tanstack/react-start`、`react`
  - 后端/状态：`convex`
  - 渲染与编辑：`@monaco-editor/react`、`react-markdown`
  - 测试与 e2e：`@playwright/test`、`vitest`

## 风险
- 内容治理风险：作为技能入口，第三方内容质量差异大。
- 平台风险：一旦直接信任并自动装载技能，供应链风险较高。
- 运维风险：Issue 体量不小，版本升级需做回归。

## 上线建议
- 若作为生产能力使用：
  1. 对“技能发布/拉取”建立签名校验与审核流程。
  2. 生产环境只允许白名单技能自动同步。
  3. 按租户/环境隔离技能来源与权限范围。
- 结论：`生产可用（需内容治理）`。
