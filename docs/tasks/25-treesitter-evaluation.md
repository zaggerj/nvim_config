# 25：验证Treesitter新架构迁移边界

**What to build（交付行为）：** 确认Treesitter新架构能否覆盖当前parser、高亮、缩进、HTTP与相关插件，形成单独迁移方案。

**Blocked by（阻塞依赖）：** [05 补齐长单行编辑增长保护](05-large-line-growth.md)；[08 建立Vue与React语言能力兼容矩阵](08-vue-language-matrix.md)；[20 建立可复用的启动与搜索性能基线](20-performance-baseline.md)。

**Status：** evaluated-retain-current（隔离比较已结束，保留现有插件；候选缺口留在后续迁移边界）

**归属：** 候选评估；[治理SPEC](../spec.md) ID04、ID06；验收 AC03、AC05、AC08、AC09、AC10。

## 验收标准

- [x] 选定明确提交及其API，记录与旧configs接口差异，不通过直接切branch冒充迁移。
- [x] 隔离配置覆盖JS/TS/JSX/TSX、Vue2/3、Go、Python、Lua及HTTP解析和高亮。
- [ ] 验证context、autotag、注释上下文、缩进及大文件读入/增长保护，与05和08矩阵一致。（context行为未通过，完整读入矩阵未覆盖，作为迁移阻塞）
- [x] Windows真实HTTP请求及parser构建可用，明确原生产物需按平台重建；macOS未实机验。
- [x] 记录适配与局部ready耗时，给出保持当前结论，不将候选ready耗时冒充整配置提速。

## 范围与交付记录

日常锁定保持不变直到选型与迁移票获确认。

2026-10-22：[候选试验报告](../evaluations/treesitter.md)、[构建与行为证据](../evaluations/treesitter-comparison.json)。新CLI实际构建隔离parser，普通样例、autotag真实键入、嵌套注释、HTTP请求与单行增长保护通过；context查询/浮窗未检出，完整矩阵待迁移票补齐。结论保持master，不能标为全面迁移可用。日常配置无需恢复。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)
