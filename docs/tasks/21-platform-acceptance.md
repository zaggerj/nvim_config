# 21：完成双平台部署和关键工作流验收

**What to build（交付行为）：** 在同一明确revision上从三种Windows入口及macOS完成部署、打开、编辑、重载和退出，形成真实平台矩阵。

**Blocked by（阻塞依赖）：** [02 恢复Go语言导航并保留构建测试](02-go-language-navigation.md)；[03 让终端Esc只退出输入模式](03-terminal-escape.md)；[04 恢复Git差异导航和安全重置入口](04-git-safe-navigation.md)；[05 补齐长单行编辑增长保护](05-large-line-growth.md)；[06 补齐Python解释器与语言服务](06-python-language-service.md)；[07 恢复Lua服务与补全](07-lua-language-service.md)；[08 建立Vue与React语言能力兼容矩阵](08-vue-language-matrix.md)；[09 统一状态栏模式并保持单次初始化](09-statusline-contract.md)；[10 修正搜索扫描范围与跨平台结果](10-search-scope.md)；[11 让原生搜索扩展失败可诊断](11-native-extension-diagnostics.md)；[18 收敛空首页与普通文本的启动工作](18-lazy-loading.md)；[19 按活跃项目根自动切换主题](19-project-theme.md)。

**Status：** in-progress（Windows完整回归37/37、三入口分阶段矩阵27/27及默认shell TUI通过；macOS实机与账号后云端AI待验）

**归属：** 验证；[治理SPEC](../spec.md) ID01、ID08；验收 AC01、AC03、AC05、AC07、AC09、AC11。

## 验收标准

- [x] Windows三个入口使用相同源码/Coc状态；带空格路径、显式部署和已有数据保留验证通过。
- [ ] macOS使用本机构建的parser、rocks和fzf产物，复用按键、服务和主题规则；无实机时保留未完成，不能以静态检查结案。
- [x] 分别验收语言服务、高亮、blame、大文件、终端、搜索及主题；服务能力和语法颜色不相互替代。（Windows）
- [x] 执行四类本地HTTP、CocRestart及AI本地初始化/保护；账号云端建议仅在用户授权完成的环境验证并单独列状态。（Windows本地通过；账号云端待验）
- [x] 环境/Lua/插件变更完整重启与Coc设置重载契约一致，测试退出无本次遗留进程。（Windows）
- [x] 按平台记录revision、命令与结果；同步设计、部署、教程、问题台账及两仓库接续。

## 范围与交付记录

不主动修改用户账号授权；后续插件变更只重验受影响平台路径，验收结果始终绑定revision。

依赖说明：依赖项目为本矩阵承诺的用户功能；归档迁移和后续候选未完成不阻止对当前revision验收。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)

## 2026-10-22 平台准备与子矩阵

详见[平台验收记录](../platform-acceptance-2026-10-22.md)。Windows三入口真实前台终端/Git/布局/大文件键位通过；真实默认PowerShell、bash、zsh闲置shell的Esc保留任务及恢复后实际命令写文件通过。新增17项WhichKey入口及Neorg真实加载回归已完成；完整回归37/37绑定c4493af，三入口27项为分阶段矩阵，分别记录真实修订范围。

只读检查本机SSH Host声明，仅有通配规则，无具体macOS宿主；macOS未执行，不能完成双平台票。账号后的Copilot建议仍由本人授权后验收。
