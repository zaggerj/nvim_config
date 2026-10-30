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


### UD-NV-004 / D-NV-011：接受评审结论并固化为治理SPEC

用户原话：`总结出问题来和结论来。然后接受上述结论`，并明确要求加载 `matt /to-spec` 收纳到spec文档。本条承接D-NV-010的评审，后续从建议晋级为接受的治理方向，不改写历史快照。

正式契约见 [docs/spec.md](spec.md)：先修功能/性能缺陷，再修搜索、迁移归档组件、分批维护插件；近期保留Coc并补齐服务，候选替换与Treesitter/语言服务/Go迁移独立验证；项目主题复用现有主题并按活跃项目根切换。保留双平台、显式部署、免费AI与既有工作流要求。测试复用配置后Neovim子进程这一既有集成边界。

同时纳入分批提交前Go回归30秒超时G01：遗留Git进程为已观察事实，Git停滞及管道继承原因仍待调查，不以旧通过记录覆盖。候选插件具体选型、真实项目配色和未量化性能指标仍待对应证据，不标为已确定。

本轮只新增规格、接受记录和关联入口，未修改运行配置，未实施升级或修复。使用本地安装的Matt to-spec模板，按用户指定本地落点适配，不发布外部工单、不运行setup。


### D-NV-012：以独立交付行为拆分治理任务

用户要求加载Matt /to-tickets，将新增问题和设计内容规划成独立任务文档。本轮完整读取已安装to-tickets正文，以 [任务索引](tasks/README.md)及27份一票一文档承接SPEC。每票包含交付行为、Blocked by、验收、范围和同步文档要求；优先级不伪装成依赖。

G01、Go导航、终端Esc、Git键位、长行增长、各语言服务、状态栏、搜索、原生诊断、归档迁移、维护分组、懒加载、项目主题、测量、跨平台验收和帮助收敛分别成票。搜索器、原生LSP、Go插件、Treesitter及原生注释为独立评估票，不预定替换结果。未发现必须先做宽泛重构的证据，不增加机械预重构层。

按用户长期文档要求，将上游默认临时目录适配为本仓库正式任务目录；不发布工单或创建对话线程。技能要求先确认拆分，当前均为draft-awaiting-review，尚未转ready-for-agent、尚未实施；后续确认粒度与依赖后再转状态，真实执行仍受Blocked by约束。SPEC的已接受方向不因此回退。


D-NV-012确认回执：用户明确回复`确认当前拆分和依赖`。27份任务已转为ready-for-agent，任务索引记录当前无阻塞前沿；未满足Blocked by的任务仍不能提前执行。本轮仅完成规划与确认，未开始修改运行配置、更新插件或执行迁移。


### D-NV-013：按已确认任务实现，保留独立平台边界

用户确认按Matt implement和严格TDD执行27项任务，授权必要修复、优化、定点升级与当前分支提交。本轮起点2aa64bd；实际源码在e3d80f6首批提交，审查修正和文档另行追加，不push。正式回执见[本轮实施](implementation-2026-10-22.md)，各任务正文记录实际状态。

语言服务补齐固定Coc扩展、官方LuaLS、兼容本机Go的gopls和goimports；导航由Coc负责，vim-go继续构建/测试/保存整理imports。终端Esc只回普通模式、Git导航与重置分开；长行增长按变化范围判定；状态栏统一全局模式；搜索输入端控制扫描、默认Unicode和ignore、PCRE2及忽略文件显式选择。主题按活跃项目根切换，完整主题仍为进程级。

G01确认lualine diff通过Scoop shim启动Git，结束shim后真实Git仍持有输出句柄；bootstrap统一解析原生Git，测试只追踪自己后代。另在最终zsh矩阵发现其POSIX PATH包含无扩展名Node副本，不能稳定供原生插件字面node调用；优先原生.exe，按ProgramFiles/LOCALAPPDATA的标准Node/WinGet根后备发现，禁止固定个人盘符或修改shell登录配置。

归档Legendary由现有Telescope和JSON频率/时间排序接替，原命令入口不变，SQLite只读显式导入，未知记录保留。Tutor旧变量从未被上游读取，改宿主内置教材与独立练习副本，保留中英入口和进度。Neorg parser及普通语言parser改显式部署，编辑启动不下载安装；未删除笔记工作流。

Gitsigns、Fugitive、文件树、lualine、surround和plenary按[选版清单](plugin-upgrade-plan-2026-10-22.json)维护，which-key已到所选提交保持。新版plenary宣布停止维护，仍有现存消费者，暂保留并纳入后续picker选型；不因此跳过兼容验证。

### D-NV-014：候选通过不等于立即迁移

隔离原型已真实验证原生LSP+blink的10语言及go.nvim构建/测试/格式化/失败路径；18个交替补全样本没有显示替换性能收益，保留Coc+vim-go。原生gc在JSX/TSX输出无效注释，保留Comment及语法上下文插件。Treesitter main的实际parser、高亮、嵌套注释、HTTP等已试验，context真实行为尚有迁移缺口，保留master。搜索器三候选全部行为可用，按重复样本和部署成本判断，不凭单次速度换插件。详见[evaluations](evaluations/)。

运行产物留在各平台stdpath(data)，官方macOS LuaLS下载包的哈希与结构已核对，不能替代macOS运行验收。任务21继续保留macOS及用户账号后的AI建议；Windows各入口的真实结果与最终revision单列，历史红测、错误试验装配和后续修正均保留。

### D-NV-015：显式Python provider与部署中断恢复

用户再次授权Matt implement/TDD接续未闭环事项。本轮在d1b08f2之后定位Python ftplugin的has('python3')同步解释器探测，采用官方支持的python3_host_prog，保留Python集成及用户显式host。默认provider在stdpath(data)/tools/python-provider中显式部署，不借用benchmark环境、全局包或项目venv，不关闭provider掩盖等待。Coc/Pyright继续独立负责项目语言服务。

管理标记记录部署是否完成；解释器存在而依赖未装完仍显示指引。已管理venv用标准venv/ensurepip原地补齐，保留已有内容；未知同名目录拒绝修改。部署命令说明先进入源码目录，Windows与macOS使用对应Python命令。详细根因、审查红绿与最终结果见[provider故障记录](issues/2026-10-22-python-provider-startup.md)。

### 2026-10-22追加：后续插件与优化建议的记录范围

用户要求评估当前插件性能、记录下阶段推荐和配置优化方向。本轮只核对已有证据与官方说明，形成[下一阶段路线](next-stage-roadmap.md)，不安装、不升级、不改变锁文件或键位。会话恢复优先、调试与格式化按需、Snacks及语言栈保留为迁移候选，均为建议而非用户已接受的实施决定；既有D-NV-014及27项任务状态不变。未来确认具体范围后再形成任务与兼容验收，不提前将候选写成当前可用功能。

### 2026-10-22追加：落实指定项目配色

用户明确指定aipaas使用Tokyonight、zagger_obsidian_gc使用Catppuccin Latte，并要求推荐后配置。已在mysettings/ngconsole.vim按项目根名称设规则；推荐将Tokyonight固定为tokyonight-night/dark，Latte固定light，跨平台不写绝对路径。真实往返发现深色切回Latte会被Catppuccin自动选成Mocha，因此项目规则增加可选background，先切深浅模式再应用主题；默认Latte同样明确light。扩展现有project_theme_smoke先复现错误变体再修正，往返、重复BufEnter、默认回退及现有项目规则验证通过；UI启动四场景另复验。当前同进程主题仍为全局，未改变tab的语义，未安装新主题插件。
