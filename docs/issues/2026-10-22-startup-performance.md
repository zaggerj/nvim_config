# Go 文件启动耗时优化

2026-10-22，用户追问 Go 文件首屏1.39秒能否继续优化。本轮保持现有插件版本、语言能力与大文件保护，调整 UI 初始化顺序并修正特殊目录的主题入口。

## 测量口径与结果

Windows 原生 Neovim 0.12.6，从 MSYS2 zsh 启动，打开此前复现黑屏的 `backend/internal/domain/image/build_upload.go`。保留真实 Coc、Treesitter、Gitsigns、Go 插件与用户配置，不使用 clean 模式。zsh 命令 PATH 明确包含已有 Node.js、Scoop shims 和编译器目录，避免登录环境缺工具干扰结果。

原1.39秒是前轮单次记录，本轮未修改前已复测到约0.40秒；未做操作系统文件缓存清空，不能把两次环境下的差额都算作本轮收益。最终采用同一环境三组交替 A/B：基线通过进程内探针恢复原 lualine/alpha 加载规格，优化组读取最终配置；其余源码、文件、工具、探针一致。断言基线状态栏setup为2次且首页已加载，优化组为1次且不加载首页，确认比较变量生效。

| 指标 | 原加载顺序，三次 | 最终配置，三次 | 中位数变化 |
|---|---|---|---|
| 首屏绘制 | 436.730 / 397.054 / 454.388 ms | 350.287 / 353.866 / 348.903 ms | 436.730 → 350.287 ms，减少约20% |
| Treesitter高亮与状态栏均已附加 | 619.202 / 614.453 / 648.231 ms | 506.812 / 512.202 / 520.990 ms | 619.202 → 512.202 ms，减少约17% |
| Coc RPC就绪 | 619.219 / 614.474 / 648.254 ms | 506.838 / 512.263 / 521.030 ms | 619.219 → 512.263 ms，减少约17% |

首屏来自 `--startuptime` 的 `first screen update`；就绪时间从初始化前探针计时，10ms间隔检查，包含部分插件同步工作的排队等待。Coc RPC就绪不表示所有语言服务器已初始化；高亮附加不测每个像素渲染。shell启动、进程创建及用户终端绘制耗时不包含在首屏数字中。本轮没有冷缓存启动基准或macOS实机数据。

结构化数值见 [测量证据](../startup-performance-2026-10-22.json)。完整本机原始日志位于 `stdpath(data)` 的 `perf-final-{baseline,optimized}-{1,2,3}.json.log`，临时探针只用于诊断，正式配置不引用它。

## 根因与修改

1. **状态栏早于主题初始化，导致重复setup。** lualine原本作为启动插件加载，随后 `ngconsole.vim` 设置主题，触发插件自己的 `ColorScheme` 回调再次setup。真实调用计数为2。改为 `VimEnter`，在最终主题确定后、首屏前初始化，计数降为1。没有删除状态栏、buffer、tab、Git或诊断组件。
2. **打开文件仍加载首页。** alpha原本每次 `VimEnter` 都加载，尽管文件启动不显示首页。现在只有参数列表为空时挂 `VimEnter`；保留显式 `:Alpha` 命令，空启动首页与按钮不变。
3. **特殊目录主题入口已过时。** `_bug` 分支调用 `colorscheme forest-night`，但锁定插件实际只提供 `everforest.vim`。新回归真实触发E185后，将调用修正为 `everforest`；插件仓库别名和锁文件不变，`_oem` 的onelight保留。

依据为当前安装的官方源码：lualine `lua/lualine.lua` 的 `setup_theme()` 注册 `ColorScheme` 和 `OptionSet background`；lazy的事件加载契约；主题插件实际 `colors/everforest.vim`。不通过停用功能或关闭TLS换取速度。

曾比较将lualine移到 `VeryLazy`：首屏中位数约250ms，但高亮与状态栏就绪约808ms，反而晚于原约616ms。最终采用 `VimEnter`，不把延后必要功能造成的首屏改善当成完整优化。

## 回归与接续

- 新增 [tests/ui_startup_smoke.py](../../tests/ui_startup_smoke.py)：修改前实际失败，提示setup为2次；修改后验证setup为1次、状态栏生效、文件启动不载首页、`:Alpha`可用、空启动首页和默认/`_oem`/`_bug`主题。Headless显式触发UIEnter走lazy事件入口，真实TUI另外测量。
- [editor_smoke.py](../../tests/editor_smoke.py)通过：8类语言高亮、真实Git blame、3类大文件保护。
- [go_startup_smoke.py](../../tests/go_startup_smoke.py)通过，约1.18秒；这是测试进程总耗时，不是首屏时间。关闭vim-go LSP后仍不调用停滞Go fixture，构建与格式化事件保留。
- 新UI回归在PowerShell、Git Bash、zsh均通过四种场景；zsh测试命令补入现有Scoop/Python/Node路径，不修改登录配置。macOS需实机验证。修改需完整退出重开nvim。

后续继续优化，应同时测首屏和功能就绪，先用同文件同环境重复测量；不得仅据上次单个数字认定回退。完整语言服务缺口与归档插件迁移仍沿用 [插件审查](../plugin-review-2026-10-22.md)，本轮没有更新插件或迁移Treesitter架构。
