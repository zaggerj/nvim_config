# 04：恢复Git差异导航和安全重置入口

**What to build（交付行为）：** 使用]c和[c导航diff或Git hunk，不修改文件；暂存和重置改为明确的操作并与帮助一致。

**Blocked by（阻塞依赖）：** 无（可开始）。

**Status：** done（Windows实现及回归、教程同步完成；macOS与账号后AI验收归21保留待验）

**归属：** A；[治理SPEC](../spec.md) R02 / ID03；验收 AC04、AC09。

## 验收标准

- [x] 真实临时Git仓库有多处修改时，]c与[c只移动焦点；原生diff窗口中的对应行为正确。
- [x] 暂存、撤销暂存和重置使用明确入口；重置前确认，取消时内容和暂存区不变。
- [x] 空格gd绑定真实可用的差异动作，which-key描述与运行映射一致。
- [x] 保留真实blame、行尾blame开关和大文件保护；未跟踪文件给出清楚行为。
- [x] 记录新旧键位差异，更新Git教程、速查及R02台账。

## 范围与交付记录

先修键位契约，不升级Gitsigns/Fugitive。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)

## 2026-10-22 实施回执

- 红：旧`]c`映射运行真实两hunk仓库，失败为 `]c did not navigate to first hunk`；重置会改动buffer。另新显式暂存测试在无动作时失败为 `explicit stage-buffer key did not stage changes`。
- 绿：`]c`/`[c`在普通Git文件调用hunk导航，diff窗口执行原生导航；真实两hunk验证前后跳转和内容不变。`空格 gd`打开真实diff。
- 新动作：`空格 hs`暂存hunk、`空格 hu`撤销最近hunk暂存、`空格 hS`暂存文件、`空格 hU`撤销文件暂存、`空格 hR`确认后重置未暂存内容。使用明确取消/重置选项，默认取消；确认回调保存buffer和changedtick，文件有变化时要求重新确认。
- `python tests/keys_smoke.py --case git`在PowerShell、Git Bash、MSYS2 zsh均通过：hunk/native diff导航、真实Git索引暂存/撤销、取消不改内容/索引、确认恢复、真实diff窗口。选择操作只模拟用户UI边界，Git和gitsigns动作均为真实执行。
- 运行日志写入测试自己的文件，避免继承PIPE掩盖退出状态；fixture只修改临时仓库。未升级Git插件，后续任务14需用本测试复验。
- 真实blame与大文件保护沿用整体回归由主实施复跑；教程、速查与which-key描述统一整合后勾选余项。
