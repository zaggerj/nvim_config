# 18：收敛空首页与普通文本的启动工作

**What to build（交付行为）：** 空首页和普通文本不加载无关代码组件，使用命令或文件类型时功能及时就绪。

**Blocked by（阻塞依赖）：** 无（可开始）。

**Status：** done（Windows最终功能回归通过；跨平台实机验收独立归任务21）

**归属：** E；[治理SPEC](../spec.md) R07 / ID07；验收 AC09、AC10。

## 验收标准

- [x] 复测NormalFile触发条件，明确空buffer、特殊buftype、无文件名和普通代码的行为。
- [x] Telescope及命令面板按真实命令/按键触发加载，首次使用可直接工作。
- [x] 核实Neorg传递依赖的实际归属，norg和Neorg命令仍可用，不因同时用Obsidian而删除工作流。
- [x] 覆盖空启动、指定代码文件、普通文本、大文件及从首页首次找文件。
- [x] 同环境比较首屏与必要功能就绪，不能只延后服务赢得首屏；记录依赖加载与教程影响。

## 范围与交付记录

基于执行时实际保留的插件实施，不把命令面板迁移设成假阻塞；与其他配置任务串行合并。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)


## 2026-10-22 实施回执

空/无名/text/特殊buffer不触发NormalFile；Telescope命令按需；Neorg间接依赖明确懒加载且norg/逗号动作可用；ParserInstall与provision_neorg显式构建，缺依赖首次打开不联网安装。

验证入口：`lazy_loading_smoke.py / parser_deployment_smoke.py / neorg_deploy_smoke.py / keymap_inventory_smoke.py`，在当前Windows Neovim0.12.6配置下执行。完整SHA、根因、恢复与数据迁移见 [实施回执](../implementation-2026-10-22.md)，最终平台/revision见 [21](21-platform-acceptance.md)。macOS无实机，跨平台验收不提前勾选。

## 最终整合回执

运行配置 `c4493af` 的完整回归37/37通过，原始命令/输出见 [最终报告](../evaluations/final-regression.json)。三Windows入口27/27及逐项修订范围见 [平台回执](../platform-acceptance-2026-10-22.md)。本票完成口径为当前Windows目标；macOS原生产物/实机仍归任务21待验。
