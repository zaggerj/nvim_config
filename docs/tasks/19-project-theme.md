# 19：按活跃项目根自动切换主题

**What to build（交付行为）：** 项目切换时自动使用相应主题，帮助、文件树和终端保留最近活跃项目主题。

**Blocked by（阻塞依赖）：** [09 统一状态栏模式并保持单次初始化](09-statusline-contract.md)。

**Status：** done（Windows最终功能回归通过；跨平台实机验收独立归任务21）

**归属：** E；[治理SPEC](../spec.md) R06 / ID07；验收 AC07。

## 验收标准

- [x] 识别普通文件项目根、Git worktree及明确的非Git标记；空首页用cwd，不在每次BufEnter同步调用Git。
- [x] 路径规则兼容Windows与macOS、重名仓库、monorepo和从外部目录打开绝对路径。
- [x] 提供可移植的项目主题映射，具体仓库配色由配置表表达；未指定项目用现有默认主题。
- [x] BufEnter与DirChanged只在目标主题变化时应用，特殊buffer不误切，失效主题给诊断。
- [x] 多窗口/tab验证进程级主题和状态栏一致，不声称tab永久独立主题；记录切换成本并更新教程。

## 范围与交付记录

不新增项目/主题管理插件，不为每个tab实现独立整套配色。

依赖说明：09提供状态栏模式和单次初始化契约，主题切换以此做联合验收。

## 2026-10-22 实施回执

采用配置后Neovim子进程和临时文件系统作为公共集成边界，先写失败场景再实现。原配置红：绝对路径文件和同名仓库不会按项目切换，无法表达monorepo/非Git项目，重复BufEnter会重新加载主题，无效主题会中断BufEnter。

新增项目主题模块：按普通文件解析Git/worktree根，按明确 workspace marker（package.json、go.work、go.mod、pyproject.toml、Cargo.toml）回退；配置表支持绝对根、可移植根后缀及monorepo subdir，Windows路径规范化。BufEnter/DirChanged跳过特殊buffer，仅主题变化时应用；无效主题转为一次性可操作警告并保留上次主题；保留TrySwitchTheme接口和_oem/onelight、_bug/everforest默认规则。

回归：`python tests/project_theme_smoke.py`通过，覆盖绝对路径、同名Git/worktree根、monorepo、非Git marker、重复事件、特殊buffer、tab全局主题、无效主题诊断；`python tests/ui_startup_smoke.py`四场景通过。未实机验证macOS，主题映射需要用户在真实项目中填写；运行配置已提交c4493af。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)

## 最终整合回执

运行配置 `c4493af` 的完整回归37/37通过，原始命令/输出见 [最终报告](../evaluations/final-regression.json)。三Windows入口27/27及逐项修订范围见 [平台回执](../platform-acceptance-2026-10-22.md)。本票完成口径为当前Windows目标；macOS原生产物/实机仍归任务21待验。
