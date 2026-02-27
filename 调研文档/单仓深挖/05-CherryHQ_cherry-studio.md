# CherryHQ/cherry-studio

仓库地址：https://github.com/CherryHQ/cherry-studio  
快照要点：`stars 40280`，`open issues 650`，`default branch main`，`最近推送 0 天`

## 架构
- 形态：TypeScript 桌面 AI 工作台（多包结构）。
- 顶层结构：`src`、`packages`、`tests`、`build`、`config`、`scripts`。
- 从依赖和脚本看，偏 Electron/桌面端 + 多模型接入 + 插件生态集成。
- 对 OpenClaw 更偏“协同工作台/上层工具”，不是官方核心网关替代。

## 依赖
- 包管理：`pnpm@10.27.0`
- 依赖规模（根包）：`dependencies 19`，`devDependencies 326`
- 关键依赖方向：
  - 多模型 SDK：`@ai-sdk/*`、`@anthropic-ai/*`、`@aws-sdk/*`
  - 桌面能力：`@expo/sudo-prompt`、`sharp`
  - 服务能力：`express`

## 风险
- 许可证风险：`AGPL-3.0`，商用分发/二次开发需严格合规。
- 依赖规模风险：dev 依赖体量大，供应链与构建链复杂。
- 产品边界风险：若把客户端工具误当作生产网关，会引入架构错位。

## 上线建议
- 建议定位为“开发者桌面工具/运营工作台”，非核心服务端。
- 若企业使用：
  1. 先做 AGPL 合规审查。
  2. 锁定版本并做 SBOM/依赖扫描。
  3. 与生产网关解耦，不给高危密钥全量权限。
- 结论：`客户端侧可用，服务端慎用`。
