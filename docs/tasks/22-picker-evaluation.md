# 22：公平比较搜索器并给出保留或迁移结论

**What to build（交付行为）：** 使用相同扫描策略和数据集比较Telescope、fzf-lua及Snacks，得出有证据的选型结论。

**Blocked by（阻塞依赖）：** [10 修正搜索扫描范围与跨平台结果](10-search-scope.md)；[11 让原生搜索扩展失败可诊断](11-native-extension-diagnostics.md)；[20 建立可复用的启动与搜索性能基线](20-performance-baseline.md)。

**Status：** ready-for-agent（用户已确认拆分与依赖，未开始实施；执行前须满足Blocked by）

**归属：** 候选评估；[治理SPEC](../spec.md) ID05、ID06；验收 AC06、AC08、AC10。

## 验收标准

- [ ] 复用已修正确的扫描/路径策略并确认当前fzf扩展启用，避免用不同搜索范围制造提速。
- [ ] 候选仅在隔离配置中运行，记录Windows依赖、SQLite下载路径、预览与可移植性。
- [ ] 覆盖find_files、live_grep、buffers、oldfiles、help、commands/keymaps、多选及quickfix。
- [ ] 按20的口径测量首次结果、输入延迟、启动和必要功能就绪，列出功能差异及维护成本。
- [ ] 提交保留或迁移的明确建议；如建议迁移，补充独立实施票及验收差异，未经选型不替换日常配置。

## 范围与交付记录

交付可复现评估和决策材料，不预先承诺某候选更快。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)
