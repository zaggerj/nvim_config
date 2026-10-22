# 07：恢复Lua服务与补全

**What to build（交付行为）：** 编辑Lua和Neovim配置时可获得正常补全及导航，不再调用不存在的服务命令。

**Blocked by（阻塞依赖）：** 无（可开始）。

**Status：** done（真实导航、补全、诊断、vim识别与CocRestart通过；macOS归21待验）

**归属：** A；[治理SPEC](../spec.md) R05 / ID02；验收 AC03。

## 验收标准

- [x] 明确现有Coc Lua扩展与自定义服务的唯一职责，移除失效命令路径或替换为已部署服务。
- [x] Lua补全开关与预期一致，服务命令通过工具发现获得，不硬编码机器安装路径。
- [x] 普通Lua与Neovim配置示例验证补全、定义、诊断及vim全局识别。
- [x] 缺依赖时给清楚提示，CocRestart后设置有效，大文件保护仍生效。
- [x] 同步Lua服务说明、部署及教程，不修改指令或Skills。

## 范围与交付记录

不将本任务扩大为所有Lua风格重构。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

### 2026-10-22 实施与证据

初始红灯：自定义lua-lsp命令ENOENT、Lua.completion.enable=false；coc-lua官方安装器在Windows明确不支持ZIP解包。移除失效自定义服务，仅保留 coc-lua 2.0.6；显式部署SHA256校验的官方LuaLS3.19.2到该扩展的标准storage，开启补全并声明LuaJIT/vim全局。动态路径来源为stdpath(data)，不硬编码本机目录。缺工具时提示:LanguageToolsInfo，不退回失败的Windows自动安装。

`python tests/language_services_smoke.py --language lua`真实通过定义、引用、重命名、补全、故意缺失全局的诊断、vim识别和CocRestart。共享bigfile机制继续阻止服务附加。原工具保留-previous备份，回退前保留新目录。完整部署、版本及恢复见[语言服务](../language-services.md)，操作见[教程](../tutorial.md)。macOS包有明确平台哈希与路径，但未冒充实机验证。

[返回任务索引](README.md)
