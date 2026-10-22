# Coc、原生 LSP + blink 与 Go 插件的实测选型

2026-10-22；任务 [23](../tasks/23-native-lsp-evaluation.md)、[24](../tasks/24-go-workflow-evaluation.md)。结论：当前保留已修复的 **Coc + vim-go**。原生方案具有可行性，当前证据没有显示替换收益足以覆盖接口迁移和验证成本。日常配置没有安装或启用候选插件。

## 基线与隔离范围

宿主为 Windows 11、Neovim 0.12.6、Node 26.7.0、Go 1.26.3。日常语言栈见[语言服务说明](../language-services.md)，代码基线为 `e3d80f6` 及本次候选测试文件。完整首屏与搜索基线见[性能记录](performance.md)；本页的初始化与补全耗时采用自己的口径，不能和首屏时间互换。

候选固定为：

- [blink.cmp v1.10.2](https://github.com/Saghen/blink.cmp/tree/v1.10.2)，明确使用 Lua matcher。关闭隐式 Rust 二进制下载，避免把独立原生依赖引入编辑启动。
- `typescript-language-server@6.0.2` + TypeScript 5.7.3。官方 npm engines 要求 Node >=22.22.2，本机满足。blink 本身只做补全，不负责安装语言服务器。
- Vue、Python、Lua、Go 复用已经显式部署的相同底层服务版本；隔离进程通过 `-u NONE` 启动，不加载 Coc。
- [go.nvim 5622d97078b30d853a0dfaf8cba204263a60c99a](https://github.com/ray-x/go.nvim/tree/5622d97078b30d853a0dfaf8cba204263a60c99a)。这不是模糊的跟随 master，后续评估必须继续固定提交。

源码和 npm 候选位于 `stdpath('data')/evaluations`，运行配置不引用这里。测试项目自动清理。候选显式部署入口：

```sh
python tests/language_stack_evaluation.py --data "数据目录" --prepare --language python
python tests/language_stack_evaluation.py --data "数据目录" --language vue26
python tests/go_candidate_evaluation.py --data "数据目录"
```

前端项目先通过 `language_services_smoke.py --language <类型> --prepare` 建立固定依赖 fixture。候选脚本只在显式调用时下载；删除候选不会影响编辑器。无需修改 lazy-lock 或系统 PATH 来恢复日常方案。

## 功能矩阵

|真实项目|原生定义/引用/重命名|服务补全与真实诊断|blink 候选菜单|
|---|---|---|---|
|Python 跨文件 import|通过|通过|菜单回调和 `greet` 候选通过|
|Lua 函数|通过|通过|同上|
|Go module|通过|通过|`Greet` 候选通过|
|Vue 2.6.14 / 2.7.16 / 3.5.13|三组均通过|模板表达式与未知绑定诊断通过|三组均通过|
|JS / TS / JSX / TSX 跨文件导入|四组均通过|四组均通过|四组均通过|

原始结果为同目录 `native-*.json`，脚本是 `tests/language_stack_evaluation.py`。没有只验证服务器 initialize 就写成完成：每组实际请求定义位置、至少两处引用、包含新名称的 rename 编辑、含目标符号的 completion，等待非空诊断，并检查 blink 的 `BlinkCmpShow` 公共回调与候选列表。

原生 Vue 原型明确使用固定 Vue server 的 `vue.hybridMode=false` 和本项目 tsdk，单客户端负责模板及脚本；日常 Coc 保留 hybrid 模式。这证明该固定版本有独立原型路径，不能把此选项直接套用到未来升级的 Vue server。真实业务项目更复杂的 tsconfig 继承、monorepo、多版本工作区仍需迁移票覆盖。

## 同环境请求成本

对 Python、Lua、Go 各采 3 组交替 Coc/native 样本。两者在同类最小项目中依次完成定义、引用、rename 请求后，测量相同位置的补全请求；Lua 使用末尾 `gre` 补全点。没有删除用户缓存。原始样本见 [language-timing-comparison.json](language-timing-comparison.json)。

|语言|Coc 补全中位数 ms（范围）|原生补全中位数 ms（范围）|
|---|---:|---:|
|Python|23.43（21.03–24.06）|51.18（49.22–52.68）|
|Lua|12.60（12.29–13.51）|13.66（12.07–14.39）|
|Go|189.30（177.13–196.61）|212.22（204.55–213.20）|

这些值包含请求分发、语言服务器和响应等待，不含物理终端绘制或进程创建。原生原型更精简，仍未在这些样本显示补全收益；样本小，不据此宣称 Coc 在所有项目都更快。两边 readiness 分别使用原生 `client.initialized` 和 Coc definition provider：它们不表示同一个阶段，因此原始 JSON 中的初始化耗时分列保留，不计算二者的提速百分比。blink README 的 0.5–4ms 是插件内部更新路径宣传值，不能与服务器请求、首屏或整机启动直接比较。

## 迁移尚需覆盖的接口

|现有行为|迁移要求|
|---|---|
|`gd`、`gD`、`Ctrl+]`、`K`、`gh`、`gr`、F2|改为对应 `vim.lsp` 公共接口，重新验收模式、位置列表和跳转栈|
|`if` / `af` 函数文本对象|Coc 的函数文本对象不随 blink 提供，需单独选择语义或 Treesitter 实现并保留操作符/可视模式|
|诊断列表、上下诊断、code action、organize imports、格式化|CocList 和 CocAction 调用均需迁移，不只替换补全菜单|
|Vista|当前 `vista_default_executive='coc'`，需选择真实支持当前原生客户端的符号后端并验收|
|17 个 Coc 扩展|JSON/CSS/HTML/ESLint/Emmet/UnoCSS/字典/列表/片段等不是五个后端服务器的同义词，需逐项证明等价或取得弃用决定|
|大文件与重载|需把 Coc 的缓冲区保护接到每个原生客户端及 blink；当前原型没有改写日常保护链路|
|CocRestart / CocProvision|需新的显式工具部署、重连、诊断入口，避免启动时自动联网|

因此任务 23 的交付是完成候选验证并保留当前方案，不是假装已完成全栈迁移。未来若出现明确 Coc 故障、可复现的大项目延迟或必须依赖原生 LSP 的需求，应另建迁移票；按上表建立回归后，再在单独分支实现，可直接回退到已验证的锁文件与 Coc 配置。

## go.nvim 的实际要求与原型

固定提交的 README 安装段前文仍写 nvim-treesitter main，紧随其后的说明明确 **master 要求 Neovim 0.12，0.11 应使用 v0.11 发布版，master 不再强制依赖 nvim-treesitter**。源码 `lua/go.lua` 探测 `nvim-treesitter.config` 但不以它作为 setup 成功的前提；`lsp_cfg` 默认 false。当前宿主 0.12.6 满足要求，不能仅凭旧段落判定它不可用。

隔离原型关闭当前不需要的 textobjects、codelens 和 LuaSnip，保留异步 Go 任务，明确 `gofmt='gofmt'`，不启动原生 LSP。`tests/go_candidate_evaluation.py` 实际验证：

- `:GoFmt` 更新文件；`:GoBuild`、`:GoTest` 成功。
- 注入编译错误后 GoBuild 失败且产生错误列表，修复后再次构建成功。
- 写入失败断言后 GoTest 以失败状态结束。
- 使用项目 Go 1.26.3、本地工具链，全部任务及 Neovim 正常退出，无重复语言客户端。

结果见 [go-candidate.json](go-candidate.json)，setup 单次约 45ms，只包含该插件 setup，不作为整机性能排名。日常 vim-go 的同类真实动作和跨包服务测试见 `tests/language_services_smoke.py --language go`。

|方案|当前判断|
|---|---|
|Coc + vim-go|现有导航共享 Coc；构建、测试、goimports 保存格式化已修复并通过回归，保留|
|原生 LSP + 自定义任务命令|基础能力成立，但要自行维护错误解析、异步生命周期、键位、函数文本对象和显式工具部署；当前缺少迁移收益|
|Coc + go.nvim 任务部分|隔离构建/测试/格式化可行，但默认格式化/导航面向原生 gopls；需另做命令兼容和工具策略适配|
|原生 LSP + go.nvim|功能面较全；依赖任务 23 的完整接口迁移，没有直接替换授权或必要性|

go.nvim 的 `go.install` 会在工具缺失时尝试安装，现有日常设计要求安装显式发生。未来采用它时必须先补受控工具清单、缺失提示及阻止隐式安装的策略，不能仅关闭 vim-go 就称为升级。当前没有已有调试流程需迁移，未把新增 DAP 调试当成本票的阻塞条件。

后续若决定迁移：先固定候选提交与宿主要求，在独立配置中覆盖上述全部命令和失败路径，迁移文本对象及导航消费者，确保不隐式下载，再以相同项目采样首屏、服务和请求耗时。通过后才改日常插件与锁文件；回退保留当前 vim-go 配置、Coc 扩展清单和工具固定版本。
