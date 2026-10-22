# 25：验证Treesitter新架构迁移边界

**What to build（交付行为）：** 确认Treesitter新架构能否覆盖当前parser、高亮、缩进、HTTP与相关插件，形成单独迁移方案。

**Blocked by（阻塞依赖）：** [05 补齐长单行编辑增长保护](05-large-line-growth.md)；[08 建立Vue与React语言能力兼容矩阵](08-vue-language-matrix.md)；[20 建立可复用的启动与搜索性能基线](20-performance-baseline.md)。

**Status：** ready-for-agent（用户已确认拆分与依赖，未开始实施；执行前须满足Blocked by）

**归属：** 候选评估；[治理SPEC](../spec.md) ID04、ID06；验收 AC03、AC05、AC08、AC09、AC10。

## 验收标准

- [ ] 选定明确提交及其API，记录与旧configs接口差异，不通过直接切branch冒充迁移。
- [ ] 隔离配置覆盖JS/TS/JSX/TSX、Vue2/3、Go、Python、Lua及HTTP解析和高亮。
- [ ] 验证context、autotag、注释上下文、缩进及大文件读入/增长保护，与05和08矩阵一致。
- [ ] 真实HTTP请求及parser按平台构建规则可用，明确哪些原生产物需重建。
- [ ] 记录性能和适配差异，给出保持当前或独立迁移票，不与语言服务/Go替换叠加。

## 范围与交付记录

日常锁定保持不变直到选型与迁移票获确认。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)
