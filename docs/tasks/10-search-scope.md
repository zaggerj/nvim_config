# 10：修正搜索扫描范围与跨平台结果

**What to build（交付行为）：** 默认搜索只扫描应搜索的文件，显式搜索忽略文件，Windows和macOS路径规则一致且不漏正常源码。

**Blocked by（阻塞依赖）：** 无（可开始）。

**Status：** done（Windows最终功能回归通过；跨平台实机验收独立归任务21）

**归属：** B；[治理SPEC](../spec.md) R04 / ID05；验收 AC06。

## 验收标准

- [x] 临时Git fixture证明默认尊重gitignore，显式忽略文件入口可搜到目标，隐藏文件行为单独定义。
- [x] 真正依赖及产物在rg扫描输入层排除；合法src/lib和名称带build的源码不被统一屏蔽。
- [x] 正反分隔符经实际picker入口验证结果一致，find_files与live_grep策略可解释。
- [x] 普通中文搜索用默认Unicode引擎，高级PCRE2显式选择并提示缺失能力。
- [x] 记录现有Telescope下扫描范围、首次结果和输入延迟；按证据选择刷新节流。
- [x] 更新搜索入口、which-key、教程与R04证据，不替换搜索器。

## 范围与交付记录

与其他A批任务无技术阻塞，推荐优先完成A批后实施；优先级不写成假依赖。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)


## 2026-10-22 实施回执

默认gitignore、隐藏策略、显式ignored、依赖扫描端glob、合法lib/rebuild、中文、PCRE2及正反分隔符的真实picker均通过；节流与首次结果沿用20实测，不凭感觉新增延迟。

验证入口：`search_smoke.py`，在当前Windows Neovim0.12.6配置下执行。完整SHA、根因、恢复与数据迁移见 [实施回执](../implementation-2026-10-22.md)，最终平台/revision见 [21](21-platform-acceptance.md)。macOS无实机，跨平台验收不提前勾选。

## 最终整合回执

运行配置 `c4493af` 的完整回归37/37通过，原始命令/输出见 [最终报告](../evaluations/final-regression.json)。三Windows入口27/27及逐项修订范围见 [平台回执](../platform-acceptance-2026-10-22.md)。本票完成口径为当前Windows目标；macOS原生产物/实机仍归任务21待验。
