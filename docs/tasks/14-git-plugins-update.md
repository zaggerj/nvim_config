# 14：定点维护Git插件并回归实际操作

**What to build（交付行为）：** Gitsigns和Fugitive在明确版本上继续支持安全导航、blame、暂存和差异，并可恢复原版本。

**Blocked by（阻塞依赖）：** [01 查清并修复Go回归超时与进程遗留](01-go-process-lifecycle.md)；[04 恢复Git差异导航和安全重置入口](04-git-safe-navigation.md)。

**Status：** done（Windows最终功能回归通过；跨平台实机验收独立归任务21）

**归属：** D；[治理SPEC](../spec.md) M02、R08 / ID06；验收 AC08、AC09。

## 验收标准

- [x] 核对官方兼容变更与当前锁，选定明确目标提交；已有版本合适则给证据并保留，不为更新而更新。
- [x] 临时Git仓库验证blame、hunk导航、暂存/撤销、确认重置与Fugitive差异入口。
- [x] 普通与大文件、多buffer和编辑器退出正常，不重现01的子进程遗留。
- [x] 审查本批锁文件差异，保存恢复说明并验证相关行为。
- [x] 同步插件审查、Git教程及维护回执，其他插件版本不混入本批。

## 范围与交付记录

仅Git组件及不可分割的必要适配。

依赖说明：01让Git生命周期回归可信；04先确立本批不能退化的Git键位契约。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)


## 2026-10-22 实施回执

按选版JSON更新Gitsigns和Fugitive；真实blame、hunk导航、暂存、确认重置、差异及退出通过。

验证入口：`keys_smoke.py --case git / editor_smoke.py / git_lifecycle_smoke.py`，在当前Windows Neovim0.12.6配置下执行。完整SHA、根因、恢复与数据迁移见 [实施回执](../implementation-2026-10-22.md)，最终平台/revision见 [21](21-platform-acceptance.md)。macOS无实机，跨平台验收不提前勾选。

## 最终整合回执

运行配置 `c4493af` 的完整回归37/37通过，原始命令/输出见 [最终报告](../evaluations/final-regression.json)。三Windows入口27/27及逐项修订范围见 [平台回执](../platform-acceptance-2026-10-22.md)。本票完成口径为当前Windows目标；macOS原生产物/实机仍归任务21待验。
