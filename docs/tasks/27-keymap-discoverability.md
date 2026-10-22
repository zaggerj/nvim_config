# 27：核对全部帮助入口与特殊模式键位

**What to build（交付行为）：** 完成前述键位变更后，用户从帮助即可找到实际可用动作，特殊文件类型和插入模式前缀不误导。

**Blocked by（阻塞依赖）：** [02 恢复Go语言导航并保留构建测试](02-go-language-navigation.md)；[03 让终端Esc只退出输入模式](03-terminal-escape.md)；[04 恢复Git差异导航和安全重置入口](04-git-safe-navigation.md)；[12 用现有能力接替归档命令面板](12-legendary-migration.md)；[13 让内置Tutor承接归档教程入口](13-tutor-migration.md)；[16 定点维护状态栏按键提示和文本包围](16-ui-editing-update.md)。

**Status：** done（Windows实现及回归、教程同步完成；macOS与账号后AI验收归21保留待验）

**归属：** 收敛；[治理SPEC](../spec.md) R02 / ID03、ID08；验收 AC04、AC11。

## 验收标准

- [x] 对照最终运行映射核实which-key所有描述均有实际动作，去除失效描述并保留有效入口。
- [x] 处理leader b/w作为动作与分组前缀的冲突，明确Neorg LocalLeader与全局反斜杠映射的职责。
- [x] 验证Copilot插入Ctrl+G与surround前缀、Coc相关键在真实模式下的等待与响应，不静默删除行为。
- [x] 覆盖普通代码、Go、norg、终端及大文件；Coc未加载时翻页映射是否报错作为待验证场景核查。
- [x] 完整教程和速查反映最终键位，记录变更而不把尚未实现的命令写成可用。

## 范围与交付记录

只收敛本轮受影响的帮助和键位契约，不重设计全部个人按键。

依赖说明：依赖票决定本次最终入口；本票负责整体验证和未被前票覆盖的冲突，不阻塞各票自身文档更新。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)

## 2026-10-22 实施与红绿证据

- `tests/keymap_inventory_smoke.py`通过配置后的Neovim检查普通Python及Go中17个自定义WhichKey描述的实际动作；内置preset和group单独排除，zR/zM通过真实折叠验证。`tests/keys_smoke.py`覆盖真实终端、真实Git、布局及首次大文件无Coc编辑。
- 红测发现非Git文件全局显示gb描述而不存在动作；删除全局虚假描述，保留Git buffer附加时映射自身的desc，WhichKey按buffer显示。
- 旧AI `<C-g>`与surround插入前缀冲突，恢复旧键可复现红测；隐藏建议迁至`<C-g>d`，接受仍为`<C-j>`；真实`i<C-g>s)<Esc>`得到`()`。
- Neorg初次打开因parser未部署，concealer先报nil parser且BufEnter同步下载编译。关闭上游install_parsers默认行为，增加`lua/neorg_setup.lua`和显式`python scripts/provision_neorg.py --apply`；norg/norg_meta已在本机重新编译通过。缺parser运行时测试给出明确部署提示，不初始化Neorg，不自动联网。
- 正常norg真实加载core.keybinds，验证12个逗号LocalLeader动作；测试无需创建默认笔记workspace，完整笔记工作区按用户目录配置。
- 教程所有旧终端退出、危险Git键、Go覆盖、分组前缀、AI前缀、搜索、主题和插件迁移描述已更新，正式入口见`docs/tutorial.md`。
- 源码基线HEAD `2aa64bd4f1ee6c91013385ab6f374f814398a728`加本轮工作树；最终提交revision与全平台整合由21记录。
