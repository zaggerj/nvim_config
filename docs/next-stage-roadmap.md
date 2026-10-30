# 插件性能现状与下一阶段路线

日期：2026-10-22。检查基线：运行代码dfa43ac、文档提交7598369，Neovim 0.12.6。本文是后续评估建议，**尚未安装候选插件，也未把建议升级为已接受的SPEC或已排期任务**。用户本轮授权记录与分析；现有27项状态保持其原验收口径。

当前操作见[完整教程](tutorial.md)，架构见[设计](design.md)，已接受要求见[SPEC](spec.md)，已完成候选试验见[evaluations](evaluations/)。本文汇总下一步取舍，不复制原始测试或改写旧评审快照。

## 当前性能：可用，仍需真实项目长时间测量

代码事实：lazy-lock.json目前锁定36个Git插件（含间接依赖），Coc清单17扩展。插件数不是运行负担；按文件类型和用户动作加载，比单纯减少数量更有意义。当前Python基准样本加载22个插件，不能把这个数字套到所有文件类型或空首页。

运行验证：dfa43ac的[完整回归](evaluations/provider-final-regression.json)39/39通过；本轮PowerShell/Git Bash/zsh[受影响路径补验](evaluations/provider-windows.json)9/9通过。高亮、语言语义、Git、HTTP、大文件及退出分别有真实行为检查。它们证明功能与回归状态，不是长时间CPU、内存或输入延迟报告。

| 指标 | 当前实测 | 读法 |
|---|---:|---|
| Python内部首屏 | 中位433ms，422–501ms | 同环境修复前653ms；含配置和宿主启动路径，不含shell启动 |
| 进程外首次UI flush | 中位482ms，471–539ms | 含Neovim进程创建和RPC，未测物理终端绘制 |
| 高亮/状态栏 | 中位578ms | 首屏可见和功能就绪是不同阶段 |
| Coc RPC就绪 | 中位578ms | RPC可用不等于某语言服务已初始化 |
| Python定义provider就绪 | 中位1991ms，1777–2775ms | 服务启动/项目分析仍是后续测量重点，不把它写成2秒一直黑屏 |
| 文件搜索首次结果 | 中位243ms | 当前1200文件生成项目；不是大型业务仓库结论 |
| grep首次结果 | 中位132ms | 记录首次结果，不是扫描全部文件完成 |

以上来自[三轮完整服务A/B](evaluations/provider-performance-final.json)及[测量口径](evaluations/performance.md)：A对应97e87e0的provider修复源码，B为d1b08f2配置源，使用相同当前插件与服务、相同ext_messages RPC UI；未清缓存。后续频率锁修复没有重测性能，不能把前后不同条件的历史数字拼成一条提速曲线。

尚未测量：典型大型Go/前端仓库、持续编辑的p95延迟、长时间Neovim与Node/gopls等进程的合计内存/CPU、真实终端绘制、登录shell启动、macOS实机，以及账号后的云端AI。当前不能给每个插件编造CPU排名。

## 现有插件是否值得替换

| 组合 | 现有证据与判断 | 下一步触发条件 |
|---|---|---|
| Coc + vim-go | 保留。原生LSP+blink十语言原型可用，但18个交替请求样本没有补全收益；vim-go构建/测试/格式化和Coc导航均通过 | 大型真实项目中确认Coc瓶颈，或明确需要原生LSP生态，再迁移完整消费者 |
| Telescope + fzf-native | 保留。隔离比较中Telescope的grep首次结果优于其他候选；Snacks文件过滤较快 | 完成预览、扫描集合、中文路径及双平台部署后再决定 |
| Treesitter master + context/autotag | 暂保留。main原型高亮/HTTP可行，context实际浮窗行为未通过；迁移不是只换分支 | 修复context等价性、完整大文件矩阵、本平台parser/CLI部署及性能对照后独立迁移 |
| Comment + context-commentstring | 保留。原生gc在JSX/TSX元素内部产生不正确注释 | 官方行为或上下文方案变化后再复评，不以少一个插件作为收益 |
| Gitsigns/Fugitive、nvim-tree、lualine、which-key、surround | 当前定点版本完成真实回归，未发现必须再替换的证据 | 有具体故障、上游兼容性变化或经测量确认的热点时定点更新 |
| plenary及其消费者 | 有维护风险，当前仍有Telescope/Neorg消费者，不应直接删除公共依赖 | 持续跟踪消费者的去依赖方案，优先隔离搜索器迁移 |
| Copilot/rest/Neorg | 按需使用且保留现有流程。AI账号后质量、macOS原生产物还未验 | 完成对应真实工作流，再判断体验与维护成本 |

语言补全请求中位数（Coc/原生原型）：Python23.4/51.2ms，Lua12.6/13.7ms，Go189.3/212.2ms。这是含服务请求的本机小样本，不是插件内部匹配耗时，也不表示Coc在所有项目更快。详见[语言栈评估](evaluations/language-stack.md)。

三搜索器隔离样本中位数（Telescope/fzf-lua/Snacks）：files138/465/119ms，grep60/483/69ms，已加载后过滤31/46/14ms。这里是1000文件隔离配置，与上面整配置搜索数字属于不同实验。详见[picker评估](evaluations/pickers.md)。

plenary[官方README](https://github.com/nvim-lua/plenary.nvim#important-notice)声明不再积极维护、预告归档；这是本轮官网核查的维护信息，不据此声称所有消费者已失效，也不把仓库是否完成归档写成已核实事实。

## 新增能力候选：按收益顺序评估

以下均未在本仓库实装或实测性能。版本和支持条件在正式实施前重新固定；官方最低版本只说明初步兼容，不等于Windows/macOS验收通过。

### 1. persistence.nvim：优先评估会话恢复

用途：退出项目后恢复上次文件、window/tab布局，补齐buffer/window/tab工作流的跨次启动部分。[官方项目](https://github.com/folke/persistence.nvim)提供自动保存和显式恢复API，保存位置使用stdpath(state)/sessions，最低Neovim0.7.2；不需要引入另一套文件树或补全栈。

拟定边界：默认显式恢复，不覆盖本次命令行指定文件或未保存修改；排除终端任务、HTTP响应等临时buffer；先明确保存哪些布局。其默认按Git分支区分会话，需要评估分支发现的进程开销；源码可移植，绝对路径会话文件默认保留在各机器state目录，不承诺跨机器复制即可恢复。

验收：两个项目/不同分支、含空格中文路径、保存退出后恢复布局、带文件启动不误恢复、未保存文件提示、多编辑器并发、取消恢复；对照空首页/代码首屏，不因恢复会话重新启动一批昂贵服务或终端任务。

### 2. nvim-dap + nvim-dap-ui：需要调试时添加

用途：断点、单步、查看变量和调用栈。[nvim-dap](https://github.com/mfussenegger/nvim-dap)是调试协议客户端，[dap-ui](https://github.com/rcarriga/nvim-dap-ui)提供界面且依赖nvim-nio（当前已有该依赖）。官方dap文档支持0.12.x；其安装说明指向Codeberg源码，实施时按官方当时入口固定来源与提交。

拟定边界：只在调试命令/键位触发时加载；Go、Python先各一个适配器，前端调试另票。调试器不是插件自动附送的运行环境，适配器在显式部署阶段安装到本平台工具目录，不在第一次按F5时联网。按用户选择的具体调试场景引入，不为了插件清单完整一次装齐。

验收：临时本地程序断点命中、单步/变量、结束和再次调试、启动失败诊断、编辑器退出无后代；两个平台路径、端口及终端行为分别验证。先复核F5等现有运行键，不覆盖已有行为。调试进程与界面均不进入普通启动路径。

### 3. conform.nvim：有格式化一致性需求时评估

用途：统一各语言的外部formatter选择和执行入口，明确手动/保存触发及超时。[官方项目](https://github.com/stevearc/conform.nvim)要求Neovim0.10+，能以较小文本差异应用格式化结果。它不提供所有formatter可执行文件，也不能替代Coc语言服务。

拟定边界：先盘点Coc formatOnSave、ESLint修复、vim-go goimports保存链；每种语言只有明确的一条格式化主路径。首批可先评估Python/Ruff与Lua/StyLua等现有覆盖不足处，不直接再给所有语言叠加保存钩子。前端优先项目锁定工具版本，避免机器全局版本改变仓库风格。

验收：格式化结果、项目配置优先级、含空格路径、无工具时提示、错误/超时、光标与撤销、保存不会重复触发、超大文件保护。通过后才单独决定迁移哪些原入口。性能收益尚未实测。

### 4. flash.nvim：可选的导航体验替代

用途：标签跳转、多窗口移动及结构选择；[官方项目](https://github.com/folke/flash.nvim)要求Neovim0.8+和LuaJIT。现有vim-sneak已覆盖一部分移动，属于替代评估，不是缺失修复。

验收：普通/可视/操作符模式、重复操作、中文、多window、大文件。官方示例的s/S、r/R不能照抄，须核对Sneak、surround、替换和HTTP局部键位；新旧不能同时争抢同一映射。没有本机提速证据，优先级低于会话恢复。

### 5. neotest：统一多语言测试需求明确后再加

用途：最近测试、单文件/项目测试、结果树和失败定位。[官方项目](https://github.com/nvim-neotest/neotest)使用nvim-nio，多数语言适配器还依赖对应Treesitter parser；不同测试框架需要各自适配器和项目运行环境。

当前Go已有GoTest/quickfix，先明确是否需要Python/前端统一测试入口，再评估少量适配器。不要因安装框架顺带安装所有语言runner；也要评估plenary等实际依赖是否扩大维护面。

验收：发现测试的扫描范围、正确项目cwd、最近/单文件/全项目运行、失败定位、取消/退出进程、大仓内存与UI响应。尤其核对CursorHold和当前updatetime设置的交互。没有明确跨语言测试需求时继续用现有命令与终端。

## 之前推荐的迁移候选：保留记录，不现在换

- **Snacks picker**：下阶段最值得继续试的替代方向。仅评估picker，保留当前大文件模块、Alpha、nvim-tree与终端；不整包开启bigfile/dashboard/explorer。官方[Snacks](https://github.com/folke/snacks.nvim)需要显式启用模块，部分组件有提前setup要求，不能简单给整个套件套懒加载模板。补齐预览和大文件预览保护、结果集合、quickfix、命令面板频率迁移、中文路径以及Windows SQLite显式部署，再决定。
- **fzf-lua**：保留备选；本机现有样本慢于Telescope，不列为第一迁移目标。跨平台fzf二进制、辅助进程退出和预览需要单独验收。
- **原生LSP + blink.cmp**：保留长期方案。原型可用，但17扩展、Vista、CocList/Action、文本对象、显式工具部署、大文件解除都要迁移。不要仅凭补全插件宣传值动全栈。
- **go.nvim**：只有任务/调试等需求收益明确或语言栈迁移时再评估；当前构建/测试原型通过，但显式工具策略与现有键位仍需适配。
- **Treesitter main**：维护迁移事项，优先解决context缺口和parser部署，不与搜索器和语言栈一起替换。
- **Trouble.nvim**：当前不优先新增。官方[要求](https://github.com/folke/trouble.nvim#%EF%B8%8F-requirements)包括已配置的原生LSP客户端；quickfix用途可以独立考虑，但不能安装后假定自动获得完整Coc诊断/引用。先用现有CocList与quickfix；原生语言栈迁移后再统一选型。

## 不靠堆插件的优化方向

| 顺序 | 方向 | 具体工作及验收依据 |
|---|---|---|
| P0 | 补齐任务21 | macOS本地重建rocks/parser/fzf/provider；用户完成Copilot授权后验真实建议。Windows静态兼容不能代替实机 |
| P1 | 真实项目性能 | 选择日常Go与前端项目，分别记录shell/进程/首屏/高亮/服务/首次请求；同时观察Neovim和Node/gopls进程。未修改用户源码，复用现有测量与子进程守卫 |
| P1 | 服务就绪和持续编辑 | 分开观察gopls索引、TS/Volar项目范围、Pyright虚拟环境；以实际诊断/导航正确性和p50/p95输入/请求延迟验收。不要全局扩大超时、排除合法源码或降低保护阈值制造提速 |
| P1 | 部署一致性 | 复用现有部署脚本与checkhealth/LanguageToolsInfo/SearchHealth，补一个按顺序执行的部署与检查入口；支持预览/显式应用、阶段失败提示和中断恢复。先核对现有能力，避免重复造诊断层 |
| P2 | UI热点与Git重复工作 | 分别关闭lualine的branch/diff、context、缩进线、折叠做可逆对照；核对是否能复用已有Gitsigns数据。保留功能，只在测量证明收益后改实现，不先全关 |
| P2 | 维护风险 | 跟踪plenary消费者迁移、Treesitter master/main差异与原生构建链。只按依赖批次更新、固定版本和恢复步骤，不用一次Lazy update当作验收 |
| P2 | 工作流完整性 | 会话恢复优先；格式化先统一职责；调试按需加；每项同步which-key/教程并检查终端、可视、插入模式冲突 |
| P3 | 配置可维护性 | 按真实共享边界整理初始化幂等性、自动命令group和平台路径；完整重启仍是Lua/插件变更契约，不以热重载承诺所有插件安全重建 |

## 建议的下一阶段顺序

1. 先补平台/账号验收；真实项目基准可在当前Windows并行准备，但不要阻塞在没有macOS宿主的环境中反复空等。
2. 首个新增候选评估会话恢复；只有实测不损害启动及数据保留，再形成实施票。
3. 依据日常需要选择调试或格式化统一中的一个，单项验证后合入。
4. 再评估Snacks picker的完整迁移边界，以及Treesitter兼容性维护。
5. 原生LSP/blink、go.nvim、Flash和Neotest依据具体需求或瓶颈触发，避免同一阶段同时替换多个基础栈。

每次新增/替换都固定源码与依赖、在独立fixture先失败后修正、显式部署工具、验证大文件与按需加载、执行受影响工作流及必要完整回归。通过后才更新正式设计、教程和锁文件。本文不预分配快捷键，不把未经用户确认的候选写进现行教程。
