# 2026-10-22 治理实施与验收

来源：[已接受SPEC](spec.md)、[27项任务](tasks/README.md)。本轮实现起点为 `2aa64bd`，沿用 `main` 分批提交；历史评审是改造前快照，当前操作以[教程](tutorial.md)和[整体设计](design.md)为准。用户已授权按 Matt implement/TDD 实施、升级和提交，账号本人授权。

## 根因与交付范围

| 问题 | 根因与实现 | 对外验收 |
|---|---|---|
| G01：Go回归退出后Python仍等输出 | lualine diff 启动 Scoop Git shim；旧 jobstop 停止包装程序后真实 Git 仍持有输出句柄。Windows bootstrap 解析 `.shim` 并把真实 Git 目录放入本进程PATH，所有插件共享 | `git_lifecycle_smoke.py` 快速切换15次并通知写入，连续3轮退出、输出可释放；旧配置红测 WinError32；`process_runner_smoke.py`成功/失败/超时且不杀无关进程 |
| Go导航、Python/Lua、Vue服务 | 缺少专用Coc扩展、Lua安装器不支持Windows ZIP、Go局部键覆盖已关闭的vim-go LSP | [语言能力与部署](language-services.md)，真实定义/引用/重命名/补全/诊断/构建分项记录 |
| 终端与Git误操作 | Esc发送exit，]c重置全buffer，帮助描述与动作分裂 | Esc/fj只回普通模式；Ctrl+E明确停止；]c/[c只导航；`hR`明确确认且检查buffer与修改版本；`keys_smoke.py` |
| 编辑后超长单行漏保护 | 旧增长判定没覆盖每次编辑的单行字节 | on_lines记录变化行，TextChanged/I只查脏范围；超过20000字节仍保护。撤销缩小后保存、bwipeout、重开恢复；`large_file_growth_smoke.py` |
| 状态栏不一致 | globalstatus=true被末尾laststatus=2覆盖 | 最终laststatus=3，主题后初始化一次；四种UI场景 |
| 搜索扫描与路径误伤 | live_grep绕过ignore且事后Lua目录过滤；lib/build泛化为产物 | rg扫描端glob排除真实依赖，默认尊重ignore；合法src/lib、rebuild保留；默认Unicode，GrepPCRE显式探测能力；`search_smoke.py`含正反路径、中文、PCRE2 |
| fzf加载失败被吞 | pcall结果未显示 | `SearchHealth`显示实际启用；故障包含原始异常与显式构建命令；`native_extension_smoke.py`成功/失败注入 |
| 归档Legendary/Tutor | 上游不维护；旧Tutor语言与进度变量未被插件使用 | 保留Legendary命令入口，由Telescope发现动作、持久化排序；内置Tutor使用独立练习副本保存内容与位置；对应真实picker/练习测试 |
| 空首页加载代码依赖 | NormalFile误包含空buffer；Neorg rockspec间接spec被当顶层插件加载 | 严格普通代码事件；Telescope按命令加载；Neorg明确依赖懒加载；空首页/纯文本不加载四项Neorg依赖，首次Telescope可用 |
| 项目识别仅看启动cwd | 无活跃buffer项目根与DirChanged机制 | 无同步Git进程的根解析、worktree/monorepo优先级、特殊buffer保留主题；`project_theme_smoke.py` |

## 插件分组维护

完整前后SHA保存在 [升级选版清单](plugin-upgrade-plan-2026-10-22.json)，当前精确版本以 `lazy-lock.json` 为准。Gitsigns、Fugitive、nvim-tree、lualine、surround、plenary逐组更新；which-key已是本次选定分支提交，保持版本。测试覆盖真实blame/hunk、文件定位/分屏/创建/重命名/取消删除、包围符编辑以及其消费者。

Legendary、vim-tutor-mode、其独占sqlite.lua从配置和锁文件移除；磁盘插件、原数据库和旧练习保留，不执行Lazy clean。plenary新版README明确进入维护终止阶段，当前消费者仍依赖它；本轮更新固定提交并验证，不自行删除公共依赖。后续搜索器及语言栈取舍见 [候选评估目录](evaluations/)。Copilot、rest、Lua/LuaRocks和Treesitter架构保持已验证版本，避免把全部分支更新混成一次迁移。

恢复时从上述JSON取本组before SHA，恢复对应配置与lock后显式部署该锁；涉及平台原生库应在该平台重建。不要复制Windows DLL到macOS。

## 原命令面板数据迁移

本机排查未发现旧Legendary SQLite，因此本机没有待导入记录。其他机器若存在旧数据，新配置会提示。原配置 `db_root` 无末尾斜杠，上游直接拼接文件名，需同时检查：

- `stdpath(data)/legendary/legendary_frecency.sqlite3`
- `stdpath(data)/legendarylegendary_frecency.sqlite3`

显式执行（将占位路径换为 `:echo stdpath('data')` 的实际值）：

```sh
python scripts/import_palette_history.py --source "旧SQLite完整路径" --target "数据目录/command-palette/usage.json"
```

脚本只读源库，保留原文件，按旧自定义动作id导入7项命令的次数与最近10条时间戳；新面板沿用旧时间衰减权重。未知id完整输出到 `legacy-unmapped.json`，不会猜测空格分隔的命令及描述。自定义额外命令可通过 `--mapping mappings.json` 提供原item_id到命令字符串的映射。目标存在时拒绝覆盖和重复累加；需要合并时先备份两份记录并确认映射，不能直接重复执行。原快捷键及命令发现分别提供 `Telescope keymaps` / `Telescope commands`，没有把快捷键使用次数冒充命令次数。

`palette_migration_smoke.py` 用上游实际SQLite表结构验证次数/Julian时间转换、未知项保全、源文件哈希不变和重复导入拒绝。`command_palette_smoke.py`验证七动作、实际执行、排序和新进程持久性。

## 部署和重载

配置仓库不存平台二进制；Python部署脚本使用动态源码根与 `stdpath(data)` 数据目录。启动不安装依赖；Coc扩展、Go/Lua工具、HTTP rocks、norg parser与fzf原生构建均为显式部署。具体命令见 [安装指南](../WINDOWS-SETUP.md) 和 [语言服务](language-services.md)。

Coc配置更新可 `:CocRestart`；Lua、插件、环境、宿主和原生产物变化必须退出所有相关Neovim进程再启动。`:source $MYVIMRC`不等价于这条链路。

## 验证口径与接续

功能总回归入口：`python tests/run_all.py --output docs/evaluations/final-regression.json`。它顺序运行已有功能测试和11类真实语言服务场景，不运行安装器或账号授权。交付前最终结果、性能数据、三入口与macOS边界分别写入 [任务20](tasks/20-performance-baseline.md)、[任务21](tasks/21-platform-acceptance.md)，不以脚本返回0代替实机TUI与云端AI建议。

现有Windows PowerShell、Git Bash、zsh使用同一配置/数据契约；默认PowerShell、bash和zsh真实闲置TUI均已完成Esc保留任务、恢复输入和命令实际输出验证；早期zsh等待失败还受测试相对路径影响，登录脚本切换cwd后应使用绝对fixture路径，纠正后默认zsh约4.76秒完成本项测试。未修改用户shell配置。macOS无实机；Copilot账号由用户完成，这两项必须保留待验。


## 双轴审查与修正

Standards轴发现共享命令频率文件的并发覆盖和run_all顶层超时不清后代。四个真实Neovim同时写记录复现ENOENT；增加跨进程排他锁，锁内重读、写入和原子替换，80次操作精确保留。崩溃遗留锁明确提示路径与进程id，只有确认其他编辑器已关闭后手动处理，不自动抢锁。run_all复用同一有界进程树边界，避免PIPE句柄等待重现。

Spec轴发现增长保护仅设置coc_enabled不能解除已有Coc文档跟踪，追加真实文档附加/解除/其他buffer继续服务的回归，再修逐buffer通知链路。最终结论以新增测试和总回归为准，不能仅断言禁用变量。

显式ParserInstall首次实测还暴露TSInstallSync对已有parser逐个交互询问；现改调用锁定版Treesitter的ensure_installed_sync，只补缺失且无交互。真实14语言部署/加载检查已通过。

## SPEC审查追加：Coc增长后的真实逐buffer解除

审查发现旧大文件增长验证只断言禁用变量，未证明已附加Coc停止跟踪。新增真实Coc公共API观察扩展红测复现；`lua/large_file.lua`现通过Coc原生CocAutocmd BufUnload通知，只关闭该buffer Document。该链释放lines监听和缓存、发close，后续BufEnter仍受coc_enabled=0约束；不触发Neovim BufUnload，不调用全局CocDisable/detach。

`tests/coc_large_growth_smoke.py`已在Windows PowerShell/Git Bash/zsh全部通过：增长后恰好一次close、attached=false、lines=0，后续多次编辑/切换无change；另buffer定义与编辑继续工作；缩小保存关闭重开恢复附加。源码版本与链路行号、红绿及边界详见[任务05追加记录](tasks/05-large-line-growth.md)。macOS仍待实机，最终整合测试由主任务执行。

## 最终完整回归

运行配置c4493af，`python tests/run_all.py --output docs/evaluations/final-regression.json` 顺序完成 **37/37**。覆盖所有本地功能、11类语言场景（含Python未激活venv）、进程成功/失败/超时、命令面板并发、Coc真实逐buffer解除、Parser部署边界、Neorg、HTTP和AI本地初始化。原始输出见 [最终JSON](evaluations/final-regression.json)。此前首轮32/33的目录fixture失败原样保留在 [首次整合](evaluations/integration-first-run.json)，测试改用真实TS文件后通过，未放宽NormalFile规则。

Windows入口矩阵为分阶段27/27，并非所有测试都在三个入口重复；旧revision、修正后zsh补验和完整回归各自记录范围。三默认shell真实TUI以及Coc增长保护另有针对性三入口证据。macOS实机与账号云端建议仍未执行，任务21保持开放。

## 最终测量与交付范围

独占性能窗口先运行三搜索器三轮9进程，81项行为及9个UI flush均通过；随后当前配置与2aa64bd源配置交替三轮6进程，42项就绪/时序值均有效。两边共用当前插件与服务，只对照配置源。当前内部首屏中位632ms，对照558ms，慢13.2%；文件搜索首次结果207/233ms、grep102/133ms，分别快11.1%/23.5%。全部波动和不利样本保留，详见 [性能记录](evaluations/performance.md) 与 [picker比较](evaluations/pickers.md)。本轮没有整体启动提速的证据，后续优化可直接复用此基准。

最终全套后仅补充文件树验收测试（生产配置不变）：真实展开/收起、tab及隐藏项来回切换通过，详见任务15。27票中Windows实现与候选比较已形成交付回执，任务21仍保留macOS实机和账号后的Copilot云端建议。恢复方式、旧数据保留及按平台重建要求见上文。

## 本轮本地提交

- `2aa64bd`：规格及已确认独立任务。
- `e3d80f6`：功能修复、语言工作流、懒加载与安全键位。
- `c4493af`：评审修正、真实Coc解除、频率并发与Windows工具发现；最终完整回归对应此运行代码。
- `4fae373`：候选原型、独占性能基准与全部原始证据，含文件树最终补测。
- 本文与设计、教程、任务状态及双轴审查作为最后一批文档提交；未push。后续仅文档变更不改变上述运行代码指纹。

## 接续实施：provider同步探测与最后整合

用户再次明确授权Matt implement/TDD后，从d1b08f2继续任务18/20/21及关联回归。新增根因：Python内置ftplugin的has('python3')会同步扫描PATH解释器。官方host配置与独立venv部署修复此链，不关闭Python集成、不借用benchmark环境或污染全局包；用户显式host优先。部署中断补齐、complete标记提示、源码目录/平台命令均以真实公共边界先红后绿。详细[根因与审查记录](issues/2026-10-22-python-provider-startup.md)。

生产与测试提交：ce2dfb1（provider）、97e87e0（中断恢复/提示与测量进程边界）、02ac5ff（Windows频率锁竞争）、dfa43ac（异步Git观察器三态）。独立双轴审查及复核无剩余可行动问题，见[评审](review-2026-10-22.md)。

最终 `python tests/run_all.py --output docs/evaluations/provider-final-regression.json` 在dfa43ac **39/39通过**，见[原始报告](evaluations/provider-final-regression.json)。此前两轮37/39、38/39分别保留provider-integration-first.json和provider-integration-second.json；Go定义曾出现默认3000ms超时，未扩大超时或改配置，定点及最终全套均通过。部署中断测试另显式执行（会联网安装固定包），未加入日常不联网总回归。

同环境Python项目完整服务A/B三轮6样本：内部首屏433/653ms，UI flush482/690ms，42个必需指标全部有效；两边使用同一ext_messages UI与当前插件/服务，B仅还原d1b08f2配置源。详细波动与失败采样保留在[性能记录](evaluations/performance.md)，不沿用旧632/558ms直接计算本轮收益，也不将Python场景推广为全语言提速比例。

本机provider已部署，完整退出后重启即可使用；其他机器按更新后的WINDOWS-SETUP显式部署，平台二进制仍在各自数据目录。macOS无目标宿主、用户账号后的云端AI仍归任务21开放。三Windows入口补验在平台记录另列，历史矩阵不覆盖成新revision通过。

本轮三Windows入口受影响路径最终9/9通过，源码dfa43ac；完整命令、输出和边界见provider-windows.json。最终代码之后仅同步文档/原始证据，无插件或运行设置追加变更。
