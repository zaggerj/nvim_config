# 22：公平比较搜索器并给出保留或迁移结论

**What to build（交付行为）：** 使用相同扫描策略和数据集比较Telescope、fzf-lua及Snacks，得出有证据的选型结论。

**Blocked by（阻塞依赖）：** [10 修正搜索扫描范围与跨平台结果](10-search-scope.md)；[11 让原生搜索扩展失败可诊断](11-native-extension-diagnostics.md)；[20 建立可复用的启动与搜索性能基线](20-performance-baseline.md)。

**Status：** evaluated（真实RPC UI同fixture交替三轮全部通过，本轮保留Telescope；正式预览与双平台部署留作迁移验收）

**归属：** 候选评估；[治理SPEC](../spec.md) ID05、ID06；验收 AC06、AC08、AC10。

## 验收标准

- [x] 复用已修正的扫描策略并加载fzf扩展；不以异步快照计数宣称结果集合完全等价。
- [x] 候选仅在隔离配置中运行，记录Windows依赖、SQLite下载路径、预览与可移植性。
- [x] 覆盖find_files、live_grep、buffers、oldfiles、help、commands/keymaps、多选及quickfix。
- [x] 按20口径同fixture交替三轮，测量启动首UI flush墙钟、首次结果与输入过滤，报告9样本中位数及波动。
- [x] 明确保留Telescope，记录plenary停止维护和候选部署成本；未经选型不替换日常配置。

## 范围与交付记录

交付可复现评估和决策材料，不预先承诺某候选更快。

2026-10-22：[隔离比较报告](../evaluations/pickers.md)、[原始UI输出](../evaluations/picker-comparison.json)。运行代码c4493af、独占性能窗口、同fixture按Telescope/fzf/Snacks交替三轮，9进程81项行为ready及首UI flush均断言通过，实际双选quickfix均2条。Windows比较完成，完整预览及双平台部署留作迁移验收，本次不改变日常配置。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)
