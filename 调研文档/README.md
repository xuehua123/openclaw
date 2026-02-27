# OpenClaw 中文调研资料库

本目录用于系统化调研 `OpenClaw` 及其 GitHub 生态，覆盖：
- 官方仓库与入口
- 部署与运维方案
- 插件/技能生态
- 面板与可视化工具
- 安全与风控
- 仓库筛选方法和尽调标准

## 调研快照
- 快照时间：`2026-02-27 11:07:54 +08:00`
- 官方组织：`openclaw`（公开仓库 `20`）
- 主仓库：`openclaw/openclaw`（约 `233,477` stars / `44,885` forks）
- 最新 release：`v2026.2.26`（`2026-02-27` 发布）
- 主题规模：`topic:openclaw` 约 `1,827` 仓库
- 关键词规模：`openclaw in:name,description,readme` 约 `33,068` 仓库
- 高相关去重后样本：`238` 仓库（>=100 stars：`155`）

## 文档索引
- [00-快速结论.md](./00-快速结论.md)
- [01-官方资料与入口.md](./01-官方资料与入口.md)
- [02-部署方案与实践.md](./02-部署方案与实践.md)
- [03-插件与技能生态.md](./03-插件与技能生态.md)
- [04-面板与可视化生态.md](./04-面板与可视化生态.md)
- [05-生态项目分类总表.md](./05-生态项目分类总表.md)
- [06-安全与风险评估.md](./06-安全与风险评估.md)
- [07-尽调方法与筛选标准.md](./07-尽调方法与筛选标准.md)
- [08-后续调研任务清单.md](./08-后续调研任务清单.md)
- [09-第二层深挖总览.md](./09-第二层深挖总览.md)
- [10-Top50评分清单与推荐.md](./10-Top50评分清单与推荐.md)
- [11-Top8在线核验.md](./11-Top8在线核验.md)
- [单仓深挖（Top8）](./单仓深挖/README.md)

## 数据目录
- `data/summary.json`：核心统计汇总
- `data/org_openclaw_repos.json`：官方组织仓库原始数据
- `data/repo_openclaw_main.json`：主仓库元数据
- `data/repo_openclaw_releases_30.json`：最近 30 个 release
- `data/repo_openclaw_forks_top100.json`：主仓库 top forks（按 star）
- `data/search_topic_openclaw_p1.json` / `p2.json`：topic 检索前 200
- `data/search_keyword_openclaw_p1.json` / `p2.json`：关键词检索前 200
- `data/search_openclaw_*.json`：插件/技能/面板/部署/安全切片检索
- `data/openclaw_related_dedup_classified.json`：去重+分类后的相关仓库
- `data/openclaw_related_dedup_classified.csv`：同上 CSV 版
- `data/openclaw_related_top200.csv`：高相关 top200
- `data/openclaw_deepdive_top50_scored.json`：第二层深挖 Top50 评分
- `data/openclaw_deepdive_top50_scored.csv`：第二层深挖 Top50 评分（CSV）
- `data/openclaw_deepdive_category_summary.json`：分类平均分与风险
- `data/openclaw_deepdive_top8_live.json`：Top8 在线核验详情
- `data/openclaw_deepdive_top8_live.csv`：Top8 在线核验详情（CSV）

## 刷新方式
```powershell
cd OpenClaw_中文调研
powershell -ExecutionPolicy Bypass -File .\scripts\refresh_openclaw_data.ps1
```

执行后会自动更新 `data/` 原始数据与分类结果。

第二层深挖评分：
```powershell
cd OpenClaw_中文调研
powershell -ExecutionPolicy Bypass -File .\scripts\build_deepdive_top50.ps1
```
