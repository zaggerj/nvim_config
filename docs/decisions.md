# 持续追加的配置决策与实施记录

本文件记录用户要求、实施取舍和验证回执。[整体设计](design.md)描述当前实现，[故障记录](issues/2026-10-22-startup-coc-tls.md)保留证据，[AI 方案](ai-completion.md)说明选型与授权。后续只追加历史记录；更改决定时新增条目并指明替代对象，不改写旧决定。

## 2026-10-22：要求与前轮基线

### UD-NV-001：根因修复、免费 AI 和双平台

用户要求 Windows 原生 Neovim（PowerShell、Git Bash、zsh）与 macOS 尽量使用同一配置；恢复语法高亮、blame、Windows rest.nvim，并为大文件关闭昂贵功能。不能依靠关闭 TLS 验证、临时目录或停用核心插件代替修复。

本轮新增：处理 Coc TLS 报错与启动黑屏，调研免费 AI，记录部署、启动、平台适配、重载链路及未完成事项。

### UD-NV-002：两仓库记录

用户原话：`是，两个仓库都记录`。nvim 仓库保存源码契约、测试和正式决策；`zagger_obsidian_gc` 保存整体设计导航、跨仓库解释与接续记录。知识库不复制易漂移的完整配置。

### D-NV-001：前轮已有修复

保留 Treesitter 兼容 Neovim 0.10 的锁定版本；修正 parser 清单；Gitsigns 行尾 blame；1 MiB/20000 行/读取时单行 20000 字节保护。Windows rest.nvim 使用隔离 Lua 5.1.5、LuaRocks 3.11.1、tree-sitter CLI 0.22.6，按锁定源码 rockspec 构建并显式加载 parser。Python/编译/终端使用 argv，Scoop shim 还原真实工具路径。此前已验证的结果详见整体设计。

历史 Tabnine 3.6.8 只能证明本地符号补全协议可执行，不作为现代服务修复方案。本轮不继续围绕失效上游构建下载器。

## 2026-10-22：复发纠正与实施

### D-NV-002：固定 Coc 数据与配置位置

根因：Coc 的默认数据选择优先使用 `XDG_CONFIG_HOME`。仅规范 Windows HOME 后，zsh 仍读取另一份扩展状态，那里 Tabnine 未禁用。前轮声称各终端共享 Coc 状态的结论被本次实际复现推翻。

当前契约：`g:coc_data_home = stdpath('data') .. '/coc'`，`g:coc_config_home = g:nvim_config_root`。Windows Neovim 子进程同时规范 HOME 和 XDG_CONFIG_HOME；后者为源码根的父目录，确保 Copilot 账号配置也不按 shell 分裂。系统和登录 shell 配置不改。

通过 `scripts/deploy.py` 复制已验证的旧 Coc 状态，保留原目录；目标已有内容时不覆盖。部署标记区分中断复制与完整部署。淘汰的 Tabnine 状态保留但禁用，默认清单不再安装它。

### D-NV-003：编辑启动不承担依赖下载和编译器等待

故障注入中，旧 GCC 探测阻塞首屏 5.68 秒；移除后同一测试为 0.58 秒。启动只发现真实编译器目录，目标检测留在明确构建阶段。

缺失 lazy.nvim 时显示部署指引，不在启动中同步 Git clone。Coc 扩展由版本清单 `coc-extensions.json` 与显式 `:CocProvision` 管理，`g:coc_global_extensions` 留空，避免缺失扩展在编辑启动中自动下载。

当次历史长黑屏没有原始计时，不能据此认定 GCC 是唯一原因。现已移除的两条同步外部等待路径与截图 TLS 原因分别记录。

### UD-NV-003 / D-NV-004：实施 Copilot Free

用户在调研后明确回复：`安装插件并配置，账号授权由我完成`。

采用官方 `github/copilot.vim`，固定提交 `a12fd5672110c8aa7e3c8419e28c96943ca179be`。Free 当前每月含 2000 次补全；推荐依据为免费资格、官方维护、平台支持和可避免启动下载，未进行模型质量横向实测。

设置 `g:copilot_version = false` 使用内嵌服务，首次 InsertEnter 或 `:Copilot` 才加载；显式补上延迟加载错过的初始化。AI 用 Ctrl+J 接受，保留 Coc Tab。只允许代码文件类型，大文件设置 buffer 禁用并解除 Copilot LSP 附加。Node.js 需要 22+。

账号授权由用户通过 `:Copilot setup` 完成。本轮不启动付费订阅，也不把本地服务初始化计为已收到云端建议。

### D-NV-005：重载以进程边界为准

修改 `coc-settings.json` 后可 `:CocRestart`（空格 cr）；它只重启 Coc。修改 bootstrap、环境、插件、AI 或 Lua 模块后退出并重新启动 Neovim。`require` 缓存、lazy 的加载状态及自动命令使 `:source $MYVIMRC` 无法作为完整重载契约。本轮不新增通用热重载器。

## 最新验收与开放项

验收回执将在全部入口检查后追加。当前已通过真实 Coc 状态/TLS 回归、stalled GCC 首屏测试、内嵌 Copilot 初始化/键位/大文件保护测试，以及 HTTP 请求回归。账号授权与真实 AI 建议、macOS 实机运行仍待完成。

### 2026-10-22 最终回执

PowerShell、Git Bash、zsh 的 Coc 检查全部通过，包含真实 `:CocRestart` 后再次检查 canonical 数据目录、扩展状态与原 TLS 错误。三个入口的 AI 内嵌服务与大文件保护、停滞 GCC 首屏检查通过。HTTP 本轮从 PowerShell 重跑通过，另两个入口此前通过，源码未再变化。部署脚本对当前已部署 Coc 重复执行未改写文件。

源码、安装指南、AI 说明与知识库接续文档已关联；完整重载边界见整体设计第 13 节。没有把 `:source $MYVIMRC` 的进程内幂等性计为完成项。用户下一步是完整重启后执行 `:Copilot setup`；真实云端建议和 macOS 实机验证保留开放。若原始黑屏再次发生，采集该次启动计时，不用合成测试结果替代现场证据。

### D-NV-006：修复关闭 vim-go gopls 后的残留同步工作区探测

用户再次报告同一黑屏，本轮已在真实 zsh TUI 与原 Go 文件复现。此前“历史黑屏未还原”的状态由新证据推进：vim-go 切换 buffer 目录同步执行 `go env GOBIN`，项目 Go 1.26.9 高于本机基础 1.26.3，触发工具链下载；Ctrl+C 后报查询失败并显示文件。

前轮新增的 gopls 关闭选项并未阻止插件的 DidOpen/DidChange 进入工作区探测，之前的 headless 空文件/GCC 测试未覆盖。新增 `go_compat.lua` 精确解除已关闭 LSP 的残留事件，保留构建、测试、格式化和检查功能，不改变项目或全局 Go 工具链策略。新测试修复前约 17.96 秒失败，修复后通过；真实 TUI 首屏约 1.11 秒。完整证据见 [Go 启动故障记录](issues/2026-10-22-go-toolchain-startup.md)。

最终回执：扩展后的多 buffer/后台事件测试在 PowerShell 1.59 秒、Git Bash 2.69 秒、zsh 1.79 秒通过；未调用停滞 Go fixture。Coc（含真实重启）回归再次通过。两仓库追加根因和验证更正，Python 语法与 diff 空白检查通过。

## 2026-10-22：宿主先升级与插件审查

### UD-NV-004 / D-NV-007：先升级 Neovim

用户原话：`升级一下neovim 吧，先`。沿用 Scoop 全局安装，将0.10.2升级到官方稳定0.12.6，保留旧安装目录，不顺带升级全部插件。必要兼容修复为 rest 请求定位前显式解析，避免0.12 get_node 行为变化导致实际请求失败。未修改用户项目、TLS策略或跨平台源码入口。

宿主与三入口、真实TUI、HTTP及编辑器回归见 [升级记录](issues/2026-10-22-neovim-012-upgrade.md)。完整重启生效。macOS、账号云端建议仍待验。

### D-NV-008：插件评审结论，后续变更待实施

审查39项Git插件和14项Coc扩展，官方证据JSON与 [逐项结论](plugin-review-2026-10-22.md)入库。2项归档；23项与锁定分支head不同不直接等于落后；14项Coc版本清单与npm latest相同。优先补Go/Python/Vue语言服务与Lua命令，再迁移归档插件；Treesitter新架构独立处理。

本条记录维护建议，不将评审视为批量更新/移除授权，尚未实施上述插件变更。全部历次问题统一收录 [问题台账](issues/README.md)，两仓库关联并追加回执，保留先前调查快照。

### D-NV-009：按主题完成顺序初始化UI，同时比较首屏与就绪时间

用户追问Go文件1.39秒是否可以优化，本轮继续处理。原计时不是稳定基线；最终同环境三组交替A/B，首屏中位数436.730→350.287ms（约20%），高亮/状态栏就绪619.202→512.202ms（约17%），Coc RPC约619→512ms。完整测量口径与证据见 [启动性能记录](issues/2026-10-22-startup-performance.md)。

lualine改在VimEnter、最终主题设置后初始化，实际setup从2次降为1次；alpha仅在空参数启动自动加载，保留:Alpha。曾试VeryLazy，虽首屏约250ms，但高亮/状态栏约808ms，放弃该方案。验证特殊目录时复现旧forest-night主题名E185，按锁定插件实际提供的everforest修正，保留_oem/onelight。

新UI回归修改前失败、修改后覆盖默认/_oem/_bug三主题及空启动/显式首页，PowerShell通过；editor和Go启动回归通过。宿主和插件版本不变，macOS未实机验证；修改后完整退出重开。

最终回执：新UI回归在PowerShell、Git Bash、zsh均通过四种场景，zsh测试命令补入现有Scoop/Python/Node路径，未改shell登录配置。Python语法、两仓库定点diff空白检查通过；已将测量数值和双仓库接续记录关联入库。

### D-NV-010：综合评审与教程按当前行为记录，改造另行实施

用户要求评审性能、插件老旧/替换/升级、项目主题，并基于实际配置创建最详细教程，覆盖全部快捷键及buffer/window/tab工作流。本轮范围为评审、运行取证与文档，不将是否可行或替代建议视为升级/换插件授权。

39项installed与锁文件和同日官方快照复核一致，沿用2项归档、23项分支head不同、14项Coc固定版本与npm latest相同的证据。综合结论：先修功能/保护与搜索共享路径，再迁移归档插件、分批更新；Treesitter架构、Coc/native LSP和Go工作流迁移分别验收。

新运行证据确认：Go局部gd覆盖Coc并指向已关闭gopls默认路径；终端Esc发送exit、]c重置整buffer；单行增长到30000字节仍未触发保护；Telescope正斜杠目录过滤误伤合法lib源码、反斜杠却不命中；live_grep确实扫描gitignore忽略目录；lualine全局状态栏意图与实际laststatus=2冲突。本轮未修这些配置，已在 [综合评审](configuration-review-2026-10-22.md) 与 [问题台账](issues/README.md)明确待办。fzf扩展加载成功、sqlite模块可require，不记为当前缺失。

项目主题可用现有主题实现，当前仅启动cwd三分类；自动按活跃项目根切换为待实施设计。标准colorscheme作用于进程，推荐一项目一进程，buffer管理文件、window对照、tab管理任务布局。教程以源码与运行映射为准，并明确Go/终端/Git按键现状和未验证的服务边界。两个仓库关联正式评审与教程，不复制整份易漂移键位表。


文档交付回执：完整教程已完成20章、1200行，覆盖全部显式自定义快捷键、39个Git插件、14个Coc扩展及buffer/window/tab工作流。教程与综合评审的相对链接、目录锚点、Markdown表格列数、证据JSON解析和两仓库定点diff检查通过；10个运行配置文件的SHA256与评审取证时一致。本轮未修改运行配置；缺陷修复、插件升级与自动项目主题仍按台账待办。
