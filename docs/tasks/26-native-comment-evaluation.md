# 26：验证原生注释是否可替代Comment插件

**What to build（交付行为）：** 在实际多语言文件中验证原生gc及注释上下文能否保持当前操作，给出是否移除Comment的结论。

**Blocked by（阻塞依赖）：** [08 建立Vue与React语言能力兼容矩阵](08-vue-language-matrix.md)。

**Status：** evaluated-retain-current（隔离比较已结束，保留现有插件；候选缺口留在后续迁移边界）

**归属：** 候选评估；[治理SPEC](../spec.md) ID06；验收 AC03、AC08。

## 验收标准

- [x] 普通语言、JSX/TSX与Vue模板/脚本/样式分别验证正确commentstring。
- [x] 当前行、单语言选区和操作符组合验证；已确认原生 JSX/TSX 失败，因此不迁移。
- [x] 列出Comment当前默认键与原生行为差异，保留无等价动作。
- [x] 隔离原型可重复，记录维护收益及依赖关系，不以少一个插件直接宣称体感提速。
- [x] 给出保留建议。

## 范围与交付记录

本票不修改日常注释配置。

2026-10-22：[对照报告](../evaluations/comments.md)、[原始输出](../evaluations/comment-comparison.json)，`python tests/comment_evaluation.py` 通过。原生在React元素内部产生无效注释，保留现方案。隔离进程测试，无需恢复日常配置；macOS未实机验证，混合语言跨区域选区未覆盖。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)
