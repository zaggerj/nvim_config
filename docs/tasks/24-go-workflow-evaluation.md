# 24：评估Go插件替代的完整工作流

**What to build（交付行为）：** 明确vim-go保留、原生LSP加任务命令或go.nvim哪个方案能覆盖现有Go工作流，并给出证据。

**Blocked by（阻塞依赖）：** [02 恢复Go语言导航并保留构建测试](02-go-language-navigation.md)；[20 建立可复用的启动与搜索性能基线](20-performance-baseline.md)；[23 评估原生LSP与blink的功能等价性](23-native-lsp-evaluation.md)。

**Status：** evaluated-retain-current（固定go.nvim原型成功/失败/格式化与退出通过；保留vim-go）

**归属：** 候选评估；[治理SPEC](../spec.md) ID02、ID06；验收 AC02、AC08、AC10。

## 验收标准

- [x] 以23的语言服务取舍为前提，列出构建、测试、格式化、诊断、文本对象和已有导航能力。
- [x] 选择具体候选提交核实实际宿主及Treesitter要求，解决go.nvim文档历史矛盾后再做原型。
- [x] 隔离module验证成功/失败、项目工具链、异步任务与退出路径，保留01的启动回归。
- [x] 只对当前已有调试能力要求等价；未有的新增调试功能单独记为需求，不扩大本票。
- [x] 比较真实操作、依赖与响应成本，给出保留或迁移方案及实施票，不直接删vim-go。

## 范围与交付记录

23选择继续Coc时，可据此淘汰仅支持原生LSP的候选，不强行完成替换。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

### 2026-10-22 评估与结论

以23保留Coc为前提，仍实际评估固定go.nvim提交5622d97078b30d853a0dfaf8cba204263a60c99a。核实README新旧段落和源码：当前master需Neovim0.12，nvim-treesitter不是强制setup依赖，lsp_cfg默认false；本机0.12.6满足。隔离原型使用实际module及Go1.26.3，GoFmt、GoBuild/GoTest成功、故意构建失败错误列表、测试失败、修复后构建、无重复LSP与退出全部通过。结果在tests/go_candidate_evaluation.py及docs/evaluations/go-candidate.json。

go.nvim任务部分可以独立使用，但导航/默认格式化面向原生gopls，工具缺失会隐式安装，迁移需额外适配显式工具策略、现有键位与文本对象。已修复的Coc+vim-go全工作流通过，未发现足以抵消迁移成本的收益，保留当前插件。没有凭未使用DAP调试阻塞评估。完整比较、依赖矛盾证据、后续迁移步骤及恢复方案见[语言栈评估](../evaluations/language-stack.md)，不会直接删除vim-go。

[返回任务索引](README.md)
