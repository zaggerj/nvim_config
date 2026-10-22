# 当前 Neovim 配置评审与维护建议

后续接受记录：用户已接受本评审的治理方向，正式目标与验收标准固化在 [治理 SPEC](spec.md)。本文保留评审时快照；最新 Go 回归超时另见 SPEC 的 G01 及故障记录。

评审日期：2026-10-22。对象为本仓库当前工作树，宿主 Neovim 0.12.6；39个 Git 插件的已安装提交与 `lazy-lock.json` 及同日官方审查快照全部一致。本次新增运行探针、评审和教程，**没有修改运行配置、升级或替换插件**。

## 1. 对五个问题的结论

| 问题 | 结论 | 建议 |
|---|---|---|
| 是否存在性能问题 | 仍有长单行增长保护缺口、搜索扫描范围过大，以及启动后加载较多无关插件的问题 | 优先修共享路径，再对冷启动、首次补全和大仓搜索做对照测量 |
| 插件是否老旧，能否换更快的 | 2个已归档；部分功能可由现有插件或内置能力承担；尚无候选在本机优于当前组合的实测 | 先迁移归档组件，不为了追新一次替换语言服务和搜索系统 |
| 是否全部升级 | 不建议一次全量升级 | 兼容插件分批更新；Treesitter架构和语言服务迁移单独验收 |
| 能否每个项目不同主题 | 可以；当前仅启动时按cwd中的 `_oem`/`_bug`分三类，尚未实现完整项目识别与自动切换 | 复用已有主题，按项目根配置；一个项目一个进程最清楚 |
| 如何学习当前配置 | 已建立 [完整教程](tutorial.md) | 先按buffer找文件、按window对照、按tab保存布局，再学插件与高级编辑 |

配套材料：[逐项插件审查](plugin-review-2026-10-22.md)、[本轮运行证据](configuration-review-evidence-2026-10-22.json)、[问题台账](issues/README.md)、[整体设计](design.md)。教程说明当前可用行为；本报告的建议不应读成已经实施的功能。

## 2. 优先处理的问题

### R01：Go定义跳转进入已关闭的服务（高优先）

**代码事实与运行验证。** 全局 `gd` 是Coc定义跳转，但Go ftplugin注册buffer-local `gd -> :GoDef`、`gD -> :GoDefType`、`Ctrl+] -> :GoDef`、`K -> :GoDoc`。运行映射探针确认局部映射优先；`gr`和F2仍是全局Coc。

当前关闭了vim-go的gopls，未关闭它的定义映射。锁定vim-go源码的 `go#config#DefMode()` 默认是gopls，`go#def#Jump()` 在gopls关闭时明确报 `go_def_mode is 'gopls', but gopls is disabled` 并返回。同时现有14项Coc清单没有coc-go，不能只恢复Coc映射就宣称Go语言服务完成。

建议：保留vim-go的构建、测试、格式化；统一语言服务和跳转职责，补齐gopls/Coc服务或独立迁移到原生LSP，再关闭冲突映射。验收真实module的定义、引用、重命名、跨包跳转、保存格式化和GoBuild/Test，继续保留停滞工具链启动回归。

来源：[plugins.lua](../lua/plugins.lua) 的vim-go规格、[maps.vim](../mysettings/maps.vim)，锁定上游 `ftplugin/go.vim`、`autoload/go/config.vim`、`autoload/go/def.vim`。本轮没有在用户项目执行GoDef或下载工具链；错误路径由源码闭环确认。

### R02：终端Esc与Git按键具有容易误触的行为（高优先）

**运行映射已验证。** `basic.vim` 先将终端Esc映射为离开终端输入，后载入的 `maps.vim` 又改成发送 `exit<CR>`。在空闲shell中会退出shell；前台运行其他程序时，则把这串文本送给程序。安全查看终端输出应使用 `fj` 或原生 `Ctrl+\ Ctrl+N`。

普通代码buffer中的 `]c` 被改成 `Gitsigns reset_buffer`，会重置整个文件的未暂存修改；`[c` 是暂存整个buffer。它们覆盖原生diff前后跳转习惯。另一个已确认的可发现性问题是 `空格 gd` 仅有which-key描述，没有实际映射。

建议：终端Esc统一为离开输入，退出/停止进程使用明确命令；Git重置改为有明确含义的组合，保留确认入口；统一diff与Git hunk导航。当前教程已特别标出这些现有行为，尚未修改键位。

### R03：编辑中增长为长单行时，未触发保护（高优先）

**运行验证。** 普通JS buffer从短行变为30000字节单行，总30001字节，触发 `TextChanged`、`TextChangedI` 后，仍是 `large_file=false`、`filetype=javascript`。这未超过1MiB或20000行，却超过既定单行20000字节阈值。

原因是 [large_file.lua](../lua/large_file.lua) 的长单行检查仅在 `BufReadPost`，编辑事件中的 `check()` 只测行数和总字节。之前三种大文件打开回归覆盖读入场景，不能证明该增长场景已覆盖。

建议：让新增/变更行也经过长行阈值检查，避免每个按键扫描整个buffer；保护仍应在昂贵分析前触发，并验证Coc/Copilot/Treesitter/折叠解除。新增输入、粘贴、撤销、普通buffer切回回归。本次仅记录缺陷。

### R04：搜索扫描范围和路径过滤在双平台不一致（中优先）

**运行验证与上游源码。** `live_grep` 加 `--hidden --no-ignore-vcs`，绕过 `.gitignore`；临时Git fixture中，普通 `rg --files` 不列出忽略文件，而当前grep参数会搜索它。Telescope的 `file_ignore_patterns` 在结果到Lua以后逐条过滤，不能替代ripgrep扫描前的排除。

进一步使用锁定Telescope的entry maker与实际过滤配置验证：

| 输入路径 | 当前匹配结果 | 影响 |
|---|---|---|
| `src/lib/legitimate.ts` | 命中 `lib/` | 正常源码也被过滤 |
| `src\lib\legitimate.ts` | 无匹配 | Windows反斜杠路径行为不同 |
| `vendor/dependency.ts` | 命中 `vendor/` | 在Lua结果层丢弃，仍可能已被扫描 |
| `vendor\dependency.ts` | 无匹配 | Windows目录排除可能失效 |

此外 `--pcre2` 并非中文搜索所必需：ripgrep默认正则启用Unicode；PCRE2用于前后查找、反向引用等高级语法，还是可选编译特性。`debounce=100` 是刷新节流取舍，并不自动表示响应更快。

建议：普通搜索默认尊重gitignore；另设显式搜索忽略文件的入口。在rg层使用跨平台glob排除真正依赖/产物，不统一屏蔽所有 `lib/`、`build/`。规范后再公平比较Telescope与替代搜索器。验收大仓扫描时间、首次结果延迟、合法源码与Windows/macOS路径；本轮不对尚未测量的大仓开销给提速百分比。

来源：[plugins.lua](../lua/plugins.lua) Telescope defaults/live_grep/find_files，锁定Telescope `pickers.lua` 的结果处理和 `make_entry.lua` 的vimgrep解析。全部fixture与路径过滤结果见证据JSON。

### R05：语言服务缺口和残留设置（中优先）

Go/Python/Vue专用Coc服务尚未列入清单；自定义Lua服务调用本机不存在的 `lua-lsp`，并有 `Lua.completion.enable=false`。volar/vetur/snippets/rust/powershell设置残留不代表对应服务已安装。

建议先补齐实际项目需要的服务、解释器和TypeScript/Vue版本适配，再判断是否迁移整套Coc。Vue2.6、Vue2.7与Vue3不能未经验证都交给最新Volar。现有 [逐项审查](plugin-review-2026-10-22.md)记录官方候选和准确安装名，仍待真实项目验收。

### R06：状态栏选项与项目主题能力需统一（中优先）

运行探针同时得到 `lualine_globalstatus=true`、`laststatus=2`。插件配置要求全局状态栏，但setup后又将选项改为每个窗口有状态栏。教程按最终选项说明，不称它是已经统一的全局状态栏。

主题现在只在启动调用一次 `TrySwitchTheme()`；`DirChanged`自动命令被注释，且只匹配cwd子串。文件来自其他项目、tab切换、`:tcd` 后都不保证主题随项目变化。具体方案见第5节。

### R07：启动后仍加载较多非当前任务必需组件（后续优化）

已有实测基线为暖环境首屏约350ms、高亮和状态栏附加约512ms，详见 [性能记录](issues/2026-10-22-startup-performance.md)。它不包括shell启动和进程创建，也不等于所有语言服务器已准备好。

本轮空启动、触发UIEnter后约1秒，39项中29项已加载，包括搜索、命令面板、Coc、Treesitter及部分Neorg传递依赖。这个数量是该探针场景的启动后状态，不是首屏耗时分解。

`NormalFile`事件只排除大文件和特殊buftype，不要求非空文件名；空buffer也能触发代码插件。Neorg本身虽按norg/命令加载，但其rockspec导入的若干独立依赖没有延迟条件。建议先审查依赖归属、空首页和普通文本的真实工作流，再让Telescope/legendary等按命令或键位加载。不能为了首屏数字将必要高亮和补全推迟到更晚。

### R08：原生扩展失败路径与重载维护（后续优化）

本机Telescope fzf扩展实际加载成功，sqlite Lua模块也能require；没有证据说明当前缺失。现配置对fzf加载仅pcall，迁移或升级后若构建失败会静默退化，建议显示明确诊断并检查实际扩展状态。sqlite模块加载不等于数据库读写和所有DLL路径均通过。

继续保留显式部署与完整重启契约，不在编辑首屏自动下载/编译；升级平台原生产物后重新验证。已有go_compat/rest_compat分别绑定上游事件结构与0.12行为，相关插件升级必须重新核对适配模块，不能永久假设其仍有必要或仍正确。

## 3. 老旧插件与替代方案

官方仓库同日快照：legendary.nvim、vim-tutor-mode已归档。其余插件不能仅按最后提交时间认定失效。39项当前分支、提交、维护状态见 [完整表](plugin-review-2026-10-22.md)；本轮已复核安装状态没有漂移。

| 当前组件 | 建议与候选 | 具体收益依据 | 迁移代价/验收 |
|---|---|---|---|
| legendary.nvim + sqlite.lua | 优先用已有Telescope commands/keymaps和which-key接替 | 减少归档维护点及可能独占的数据库依赖 | 自定义命令、使用频率排序不能无声丢失；先确认sqlite没有其他使用者 |
| vim-tutor-mode | 优先评估内置Tutor | 去除归档组件，宿主已有教程入口 | 现有进度保存/语言默认需迁移或明确取舍 |
| Comment.nvim | 可评估原生gc | 少维护一个通用注释插件 | Vue/JSX多语言commentstring必须保留；不保证可感知提速 |
| Coc | 近期保留并补服务；长期候选native LSP + blink.cmp | blink有异步补全及可选Rust matcher；可统一宿主LSP生态 | blink只是补全前端，还要部署语言服务器、诊断/格式化、扩展等价能力，并迁移Vista和快捷键 |
| vim-go | 近期保留构建测试；候选原生LSP +明确任务命令，或go.nvim | go.nvim官方描述使用libuv异步任务 | 工具链、构建、测试、调试、text objects都要逐项覆盖；不能只恢复gd就删插件 |
| Telescope + fzf-native | 先修搜索策略；候选fzf-lua或Snacks picker | fzf-lua调用外部fzf；Snacks finder/matcher异步 | 新依赖、Windows支持、预览、quickfix、多选、所有pickers和键位需对照；先测公平数据集 |
| Neorg与传递依赖 | 核实实际norg工作流后再决定范围 | 当前空启动加载部分依赖，有明确收敛空间 | 用户已有norg笔记，不能因同时用Obsidian而删功能 |
| Treesitter master | 暂保留已验锁；单独规划main迁移 | 新架构与当前0.12生态相符 | 旧configs API不能直接沿用；parser/query/indent/http/context/autotag需联合验收 |
| Gitsigns/Fugitive/文件树/状态栏/Surround/Sneak/Which-key | 保留主体，按兼容性定点更新 | 当前功能已有使用与回归基础 | 不因存在新项目就换成熟组件；先处理实际缺陷 |
| Copilot/rest/rocks工具链 | 保持当前固定版本，按明确上游变化评估 | 用户已选官方免费AI与Windows HTTP能力，当前已验 | 账号云端建议、macOS、HTTP原生构建仍需对应验证 |
| 多个主题 | 保留实际使用的；Tokyonight可选纳入项目配色 | 主题多数按需加载，数量本身不是主要开销 | 项目识别与切换规则比单纯删主题更重要 |

候选性能尚未在本机与当前组合做A/B，不能声称“换了必然更快”。blink上游给出的0.5–4ms是其补全组件自述，不能与这里的完整编辑器启动时间比较。

官方参考：[blink.cmp](https://github.com/Saghen/blink.cmp)、[fzf-lua与Windows说明](https://github.com/ibhagwan/fzf-lua)、[Snacks picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)、[go.nvim](https://github.com/ray-x/go.nvim)。go.nvim当前README包含Treesitter要求的历史不一致，选择具体提交后需读实现；Snacks picker部分数据库功能在Windows可能下载SQLite库，应核对实际启用功能，不能称为零部署依赖。

## 4. 是否全部升级与推荐批次

**不建议全量执行 `Lazy update`。** 23项与锁定分支head不同只说明提交不同，未逐个比较祖先；Telescope锁定0.1.x与该分支head相同，也不代表默认分支没有变化。14项Coc固定扩展与npm latest相同，盲目CocUpdate不会补上缺失的语言服务。

建议按以下顺序实施，每批选择明确提交并审查锁文件差异：

1. **先修功能与保护缺陷。** R01–R03、R05–R06优先；这批不依赖追最新版本。不要把一次插件更新当作所有配置问题的修复。
2. **搜索单独一批。** 修R04的扫描/路径/合法源码问题，记录大仓响应和实际fzf加载；再决定是否值得替换搜索器。
3. **迁移两个归档插件。** 保留命令与进度/频率行为后再清独占依赖，并复测启动后工作量。
4. **兼容插件分小批更新。** 先Gitsigns/Fugitive和文件树，再状态栏/Which-key/Surround/主题，再共享依赖。每批验实际命令、映射和大文件切回，不只检查能启动。
5. **重大迁移分开做。** Treesitter新架构、Coc→native LSP、vim-go→其他Go工作流分别建验证范围，不叠加在一次变更中。

更新前保留 `lazy-lock.json`、Coc版本清单与原生构建说明；恢复使用明确锁定版本，而不是拷贝Windows DLL到macOS。`:Lazy restore`恢复Git提交后，parser、rocks和fzf等产物仍可能需要对应平台重建。当前工作树含既有修改，不适合用整仓reset作为回退方法。

## 5. 不同项目使用不同主题

### 5.1 当前已有能力与限制

启动cwd包含 `_oem` 时onelight，包含 `_bug` 时everforest，其余catppuccin-latte。它匹配的是整个cwd字符串而非项目身份：父目录包含这些字符也会匹配；从通用目录 `nvim /另一项目/file.go` 启动时，也可能仍用通用目录的主题。

可以手动 `:colorscheme catppuccin-mocha`、`:colorscheme onelight`、`:colorscheme everforest` 或 `:colorscheme tokyonight`；已有插件按主题请求加载。若手动 `:cd`/`:tcd` 后希望暂时复用现有三分类规则，可执行 `:call TrySwitchTheme()`。这些操作修改整个进程的主题。

### 5.2 推荐设计（尚未实施）

不必安装项目管理或主题切换插件，使用现有主题即可：

1. 从当前普通文件解析项目根，优先Git根（兼容worktree的 `.git` 文件），没有Git再按明确的workspace/package标记回退；空首页使用cwd。不要每次BufEnter同步运行 `git rev-parse`。
2. 用仓库根标识或受控相对路径配置主题映射，避免在运行源码里硬编码当前Windows盘符。Windows路径规范分隔符和大小写；macOS保留实际文件系统语义。仓库重名、多个worktree、monorepo子项目应有明确匹配规则。
3. `BufEnter`、`DirChanged`时解析活跃项目；跳过终端、帮助、quickfix和文件树等特殊buffer，保持刚才项目主题。必要时处理文件改名与项目重定位。
4. 只在目标主题改变时执行colorscheme，避免相同主题反复触发lualine重建；失效主题名应给清楚提示。项目名/分支可同时显示在状态栏，让色弱或浅深主题偏好不影响识别。
5. 在真实Windows三个入口及macOS验证：从外部目录打开绝对路径、多项目切换、worktree、空启动、特殊buffer、大文件和主题反复切换的耗时。

映射可以按角色规划，例如主开发项目catppuccin-latte、客户定制项目onelight、排障项目everforest，其他项目按实际喜好分配。这里只给策略，尚未替用户决定每个真实仓库的颜色。

### 5.3 与buffer/tab/window的关系

标准 `:colorscheme` 是进程级全局设置。一个进程内两个tab可以在激活时切换全局主题，但切换会影响该进程所有窗口，并不能同时保留两套完整插件主题。Neovim的window highlight namespace可做局部高亮，文件树、状态栏和浮窗等还需单独适配，复杂度明显更高，不作为当前首选。

最方便的组合是：**一个项目一个nvim进程；文件用buffer，左右对照用window，任务布局用tab。** 同一项目的不同tab共享buffer集合，不把tab当浏览器式文件标签。确需同进程多项目时，使用tab-local cwd与活跃项目识别，但搜索、buffer列表和插件状态是否按tab隔离仍需分别配置。详细操作见 [教程](tutorial.md)。

## 6. 已完成、未完成与接续

本轮完成：源码与运行映射审查；39项锁定一致性复核；长单行增长、状态栏选项、fzf/sqlite模块、跨分隔符过滤与临时Git搜索fixture探针；详细教程、问题及双仓库导航记录。

本轮未实施：插件升级/替换、R01–R08修复、项目主题自动识别。未测量候选插件速度、冷缓存启动、大型项目实际搜索或macOS实机。Copilot账号后的真实建议和完整语言服务验收沿用既有开放项。

维护时先确认当前源码是否仍与 [证据JSON的source_sha256](configuration-review-evidence-2026-10-22.json)一致；相同文件和环境下的有效证据复用，发生变化才重验受影响路径。将实施回执追加 [decisions.md](decisions.md)，并同步教程中实际行为与按键清单。
