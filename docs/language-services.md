# 语言服务、工具部署与验证

本页记录当前实际使用的语言栈。总入口见[整体设计](design.md)、[治理规格](spec.md)、[教程](tutorial.md)和[任务索引](tasks/README.md)。高亮由 Treesitter 提供；补全、诊断和导航由 Coc 提供。看到颜色并不能证明语言服务已连接。

## 固定版本与职责

|语言|Coc 扩展|底层工具及职责|
|---|---|---|
|Go|`coc-go@1.3.35`|`gopls v0.23.0`：定义、引用、重命名、悬浮、补全、诊断；vim-go 保留构建、测试、保存时格式化和整理导入|
|Python|`coc-pyright@1.1.414`|扩展自带 Pyright；按项目 `.venv` 解析导入，可用项目 `.vim/coc-settings.json` 的 `python.pythonPath` 明确选择解释器|
|Lua|`coc-lua@2.0.6`|官方 `LuaLS 3.19.2`；启用补全、LuaJIT 运行时与 Neovim 的 `vim` 全局|
|JS/TS/JSX/TSX|`coc-tsserver@2.4.1`|TypeScript 服务；优先使用项目 TypeScript|
|Vue 2.6/2.7/3|`@yaegassy/coc-volar@0.37.4`|内置 `@vue/language-server`、`@vue/language-core` 和 TS 插件均为 `2.2.8`；hybrid 模式下 HTML/CSS 由 Vue 服务处理，脚本及模板表达式由 coc-tsserver 的 Vue TS 插件处理|

扩展版本来源是 `coc-extensions.json`，工具版本来源是 `scripts/provision_languages.py`。`coc-vetur` 不与 Volar 并行运行；没有安装已过时的额外 `coc-typescript-vue-plugin`。现有 Vetur 配置设置为禁用，避免历史安装干扰。

`gopls v0.24.0` 的官方 go.mod 要求 Go 1.27；本机 Go 1.26.3 无法用本地工具链构建。采用要求 Go 1.26 的 `v0.23.0`，没有在编辑器启动时下载或升级宿主工具链。`goimports` 固定为该 gopls 使用的 x/tools 模块版本 `v0.47.1-0.20260707181000-a299dadba899`。

## 新机器部署

先按[部署说明](../WINDOWS-SETUP.md)准备 Neovim、Node.js、Git、Python 和 Go。启动后运行 `:CocProvision`，由 Coc 自身安装器安装仓库中的准确版本，避免 npm 顶层 hoist 改变扩展嵌套依赖。普通启动不执行安装。

运行 `:echo stdpath('data')` 得到当前平台的数据目录，在配置仓库根目录执行：

```sh
python scripts/provision_languages.py --data "上一步输出的目录" --lua --go --apply
```

不加 `--apply` 只预览。Windows 可以使用 `py -3`，macOS 可以使用 `python3`；脚本支持 Python 3.9 及以上，不依赖 MSYS 路径语法。`--go` 需要本机兼容的 Go 工具链，设置 `GOTOOLCHAIN=local` 防止自动升级宿主。首次构建下载模块可能较久，属于显式部署阶段。

工具位置全部由 `stdpath('data')` 动态计算：

- `tools/languages/bin/gopls[.exe]` 和 `goimports[.exe]`。只在 Neovim 子进程 PATH 中加入此目录，不修改系统环境变量。
- `coc/extensions/coc-lua-data/lua-language-server/bin/lua-language-server[.exe]`，遵守 coc-lua 的官方存储布局。

LuaLS 下载官方 Windows x64、macOS arm64 或 macOS x64 发布包，按平台固定 SHA256，校验后解压，替换前保留 `-previous` 备份；已有备份时拒绝覆盖。本轮另行下载核对两个 macOS 官方 tar.gz，SHA256 均匹配，成员均为普通文件或目录，Python 3.9 解包路径不依赖 Python 3.12 的 filter 参数；这只验证分发产物，不代表 macOS 运行验收。Windows 内置 coc-lua 安装器明确不支持 ZIP 解包，这是先前 Lua 服务不能部署的根因。通过显式部署脚本修复这一链路，无需关闭 TLS 校验、改全局 Lua 环境或引用临时目录。

部署后完整重启 Neovim；`:LanguageToolsInfo` 查看工具实际路径和缺失项，`:CocList extensions` 看扩展状态，`:CocInfo`、`:CocOpenLog` 定位服务问题。工具未部署时会提示，Lua 扩展不会落回其失败的 Windows 自动安装路径。

## Python 项目解释器

优先在项目根目录创建 `.venv`。不需要先激活 shell；Pyright 能发现项目环境。使用其他环境时，在项目 `.vim/coc-settings.json` 中设置 `python.pythonPath`。不要把个人绝对路径写进此公共配置仓库。

2026-10-22 的真实测试创建未激活的 `.venv`，仅向其 site-packages 放入测试模块，验证定义确实解析到该环境。系统环境场景另行覆盖导入、类型错误、引用、重命名和补全。语言服务不是 Python 包运行器，运行程序仍使用项目自身的解释器与依赖管理方式。

## Vue 兼容矩阵

|项目依赖|示例形态|Windows 真实验证|
|---|---|---|
|Vue 2.6.14 + TS 5.7.3|`Vue.extend` Options API|模板变量定义定位、表达式补全、引用、重命名、未知绑定诊断|
|Vue 2.7.16 + TS 5.7.3|`script setup lang="ts"`|同上|
|Vue 3.5.13 + TS 5.7.3|`script setup lang="ts"`|同上|
|JS/TS/JSX/TSX + TS 5.7.3|跨文件导入与 React JSX|定义、诊断；最终回归包含补全、引用与重命名|

版本边界依据固定的 language-core 2.2.8 源码：读取项目 Vue 版本，2.7 及以上使用 `defineComponent` 包装，2.6 使用 `Vue.default.extend`，并包含 Vue 2 模板编译支持。测试 fixture 显式设置 `vueCompilerOptions.target` 为 2.6、2.7 或 3.5；业务项目可以让服务从本项目依赖自动推断，也可以在本项目 tsconfig 明确 target。未升级任何用户业务项目依赖。

不要直接只向名为 `vue` 的 LSP 客户端请求 TS 模板表达式补全来判断功能失效：hybrid 模式的该能力属于 coc-tsserver。验收通过官方 `typescript.tsserverRequest` 聚合路径以及 Coc 的引用/重命名公共接口完成，模板重命名会同时更新脚本和模板。

## TDD 证据与可复现命令

初始失败包括 Python 无 definition provider、自定义 `lua-lsp` 命令不存在、Lua 补全关闭、coc-lua 在 Windows 上不能解 ZIP、Go 缺服务，以及保留 vim-go 保存事件但缺少 `goimports`。先用实际配置与真实项目复现，再补固定扩展、显式工具部署和平台适配。

```sh
python tests/language_services_smoke.py --language python
python tests/language_services_smoke.py --language python-venv
python tests/language_services_smoke.py --language lua
python tests/language_services_smoke.py --language go
python tests/language_services_smoke.py --language vue26 --prepare
python tests/language_services_smoke.py --language vue27 --prepare
python tests/language_services_smoke.py --language vue3 --prepare
python tests/language_services_smoke.py --language typescript --prepare
```

JS/JSX/TSX 分别使用 `javascript`、`javascriptreact`、`typescriptreact`。`--prepare` 显式安装固定的 fixture npm 依赖，之后测试不隐式安装。fixture 位于数据目录，仅测试使用；日常配置不会引用它们。后端测试项目为自动清理的临时 module，不向用户项目写入示例。

Go 强化验收实际执行跨包定义、引用、重命名、悬浮、成员补全和格式编辑，随后保存并与真实 gofmt 输出比较。通过 `:GoBuild!`、`:GoTest! ./...`，注入类型错误后验证 Coc 诊断及 GoBuild 失败错误列表，修复后重新成功，再由外部 `go build ./...` 和 `go test ./...` 复核。Lua 覆盖未知全局诊断、`vim` 识别和 `CocRestart`。进程由 `tests/nvim_process.py` 有界管理，服务未退出会导致测试失败。

大文件通过共享 `bigfile` filetype 与 `b:coc_enabled=0` 阻止全部语言服务附加，普通缓冲区保持启用；边界测试见 `tests/large_file_growth_smoke.py`。大文件重新变小后保存、关闭并重新打开恢复完整服务。macOS 的路径、平台包和命令按同一实现提供，真实宿主回归仍需在 macOS 执行，不能以 Windows 成功替代。

## 更新与恢复

插件更新和工具更新分别评审。修改扩展清单后重新 `:CocProvision`；修改工具固定版本及官方哈希后重新显式部署。coc-lua/coc-go 自动检查更新关闭，避免启动阶段网络请求。

若新工具回归，退出 Neovim 后检查 LuaLS 的 `-previous` 备份，保留当前目录再恢复旧目录；Go 工具按上一个已验证版本显式 `go install` 到同一个托管目录。不要删除整个 nvim-data 或用户 Coc 状态来排障。候选替换与恢复方案见[语言栈候选评估](evaluations/language-stack.md)。
