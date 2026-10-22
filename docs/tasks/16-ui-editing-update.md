# 16：定点维护状态栏按键提示和文本包围

**What to build（交付行为）：** 状态栏、which-key和surround在明确兼容版本上保持原有可见行为及编辑动作。

**Blocked by（阻塞依赖）：** [09 统一状态栏模式并保持单次初始化](09-statusline-contract.md)。

**Status：** done（Windows最终功能回归通过；跨平台实机验收独立归任务21）

**归属：** D；[治理SPEC](../spec.md) M02 / ID06；验收 AC04、AC08。

## 验收标准

- [x] 为三个组件分别选定提交和阅读API变化；无需更新的组件给出保留依据。
- [x] 状态栏模式与09一致，空启动、文件启动和多窗口初始化正确。
- [x] which-key分组、搜索及窗口前缀可用；surround新增/删除/修改包围动作在fixture中通过。
- [x] Coc与Copilot插入键仍可用，记录前缀等待变化，不吞掉有效键位。
- [x] 本批锁定和恢复可审查，更新键位教程和维护记录。

## 范围与交付记录

只处理这三个紧密相关的交互组件；不更新所有主题或其他插件。

依赖说明：09先确定状态栏最终模式，本批以该契约验证API升级。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)


## 2026-10-22 实施回执

更新lualine和surround；which-key已在选定提交保持。真实添加/替换/删除包围符、插入模式前缀和帮助动作一致性通过。

验证入口：`ui_startup_smoke.py / surround_smoke.py / keymap_inventory_smoke.py`，在当前Windows Neovim0.12.6配置下执行。完整SHA、根因、恢复与数据迁移见 [实施回执](../implementation-2026-10-22.md)，最终平台/revision见 [21](21-platform-acceptance.md)。macOS无实机，跨平台验收不提前勾选。

## 最终整合回执

运行配置 `c4493af` 的完整回归37/37通过，原始命令/输出见 [最终报告](../evaluations/final-regression.json)。三Windows入口27/27及逐项修订范围见 [平台回执](../platform-acceptance-2026-10-22.md)。本票完成口径为当前Windows目标；macOS原生产物/实机仍归任务21待验。
