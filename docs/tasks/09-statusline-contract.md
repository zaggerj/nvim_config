# 09：统一状态栏模式并保持单次初始化

**What to build（交付行为）：** 多窗口下状态栏模式与插件配置一致，主题确定后只初始化一次。

**Blocked by（阻塞依赖）：** 无（可开始）。

**Status：** done（Windows最终功能回归通过；跨平台实机验收独立归任务21）

**归属：** A；[治理SPEC](../spec.md) R06 / ID07；验收 AC07、AC10。

## 验收标准

- [x] 明确选择全局或逐窗口状态栏，记录依据并消除globalstatus与laststatus冲突。
- [x] 空启动、带文件启动、默认/_oem/_bug主题下最终选项和可见状态栏一致。
- [x] 多窗口、tab切换和手动换主题可正常更新，无重复setup或状态丢失。
- [x] 复用现有UI回归记录初始化次数与实际状态栏，保留显式首页命令。
- [x] 同步状态栏设计、教程和R06台账。

## 范围与交付记录

不在本任务中实现自动项目主题或更换状态栏插件。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)


## 2026-10-22 实施回执

globalstatus=true与laststatus=3统一；默认、_oem、_bug及空启动均只初始化一次。

验证入口：`ui_startup_smoke.py`，在当前Windows Neovim0.12.6配置下执行。完整SHA、根因、恢复与数据迁移见 [实施回执](../implementation-2026-10-22.md)，最终平台/revision见 [21](21-platform-acceptance.md)。macOS无实机，跨平台验收不提前勾选。

## 最终整合回执

运行配置 `c4493af` 的完整回归37/37通过，原始命令/输出见 [最终报告](../evaluations/final-regression.json)。三Windows入口27/27及逐项修订范围见 [平台回执](../platform-acceptance-2026-10-22.md)。本票完成口径为当前Windows目标；macOS原生产物/实机仍归任务21待验。
