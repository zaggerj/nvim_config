# Windows 与 macOS 安装、迁移和验证

设计说明见 [docs/design.md](docs/design.md)。源码可以跨平台同步；插件、parser、Lua rocks 和编译工具需要在目标机器安装，不复制 Windows DLL 到 macOS。

## 1. 工具与入口

当前 Windows 验证基线为 Neovim 0.12.6（由 Scoop 全局 0.10.2 升级，旧版保留）。升级证据与回退见 [升级记录](docs/issues/2026-10-22-neovim-012-upgrade.md)。需要 Git、Node.js 22+/npm（Copilot 的要求）、Python 3.9+、curl、tar、ripgrep、C 编译器和 make；HTTP parser 的固定版本 CLI 由 Cargo 构建，因此还需 Rust/Cargo。

- Windows：使用原生 Neovim 与原生 MinGW-w64 GCC 或 Visual Studio 开发者环境。从 Git Bash/zsh 启动也要能发现编译器。Rust GNU target 需要 MinGW，MSVC target 需要相应的 Visual Studio Build Tools。
- macOS：安装 Xcode Command Line Tools（`cc`/`make`）、Neovim、Git、Node.js、Python、ripgrep 和 Rust。

推荐源码放在用户目录下的 `.config/nvim`。macOS 默认读取这里；Windows 原生 Neovim 默认读取 `%LOCALAPPDATA%/nvim`，可用目录联接指向同一份源码。已有目标目录时先核对并保留内容，不能直接覆盖。Git Bash 与 MSYS2 zsh 的 HOME 可能不同，需要分别核对实际入口：

```vim
:echo $MYVIMRC
:echo stdpath('config')
:echo stdpath('data')
:echo g:nvim_config_root
:echo exepath('python')
:echo exepath('gcc')
```

`bootstrap.init()` 解析源码真实位置，固定锁文件位置。Coc 显式使用 `stdpath('data')/coc` 保存扩展状态，使用源码根读取配置；Windows Neovim 子进程的 HOME 设为 USERPROFILE、XDG_CONFIG_HOME 设为源码根的父目录，使 Coc 与 Copilot 不随启动 shell 分裂。仅统一 HOME 不能覆盖 Coc 的 XDG 分支；本次错误与修复见 [故障记录](docs/issues/2026-10-22-startup-coc-tls.md)。不修改 shell 登录配置。

## 2. 安装依赖

缺失 lazy.nvim 时先在终端进入源码目录，执行下列命令；`--data` 用上述实际 `stdpath('data')` 替换，先预览再加 `--apply` 安装：

```sh
python3 scripts/deploy.py --data "<实际数据目录>" --bootstrap-lazy
python3 scripts/deploy.py --data "<实际数据目录>" --bootstrap-lazy --apply
```

迁移已有 Coc 时，可用 `--coc-from "<旧 Coc 目录>"` 替换 `--bootstrap-lazy`，同样先预览再执行；脚本复制并保留源目录，不覆盖已有不同目标。新机器无需旧状态，后续执行 `:CocProvision` 即可安装清单中的扩展。

正常编辑不自动安装缺失的 Git 插件或检查远程更新。首次配置或迁移后，重新打开 nvim，主动执行以下命令，等待每一步完成后再执行下一步：

```vim
:Lazy restore
:Lazy install
:CocProvision
:Lazy build hererocks
:Lazy build rest.nvim
:ParserInstall
```

rest.nvim 构建也会先检查并准备隔离工具链。构建只在安装、明确重建或更新时执行，不在每次编辑 HTTP 文件时编译。

工具链固定为 Lua 5.1.5、LuaRocks 3.11.1、tree-sitter CLI 0.22.6（生成适配 Neovim 0.10 的 ABI 14 parser）。脚本为 `scripts/bootstrap_rocks.py`，路径通过参数传入，数据位置由 `stdpath('data')` 计算：

| 数据目录内的相对路径 | 内容 |
|---|---|
| `lazy/hererocks` | 插件锁文件固定的 hererocks 源码 |
| `lazy-rocks/hererocks` | 隔离 Lua/LuaRocks |
| `tools/tree-sitter` | 固定版本的 tree-sitter CLI |
| `bootstrap/downloads` | 校验后的 Lua archive、固定提交的 LuaRocks 源码 |
| `lazy-rocks/rest.nvim` | HTTP 所需的 Lua rocks 与 parser |

Lua 官网证书曾晚于客户端日期生效。引导器保持 TLS 验证，允许使用 Buildroot 保存的相同源码并核对固定 SHA-256；LuaRocks 从官方 Git 源固定提交构建；tree-sitter CLI 从官方 crates.io 包及锁定依赖构建。缺少前置工具会明确报错，安装后重试。

升级前检查 Neovim 最低版本与插件 API，再使用 `:Lazy update` 并审查锁文件。固定工具版本需随兼容性验证一起更新。

## 3. 高亮、补全与 Git blame

支持语言清单在 `lua/parser_setup.lua`，通过 `:ParserInstall` 显式构建；日常 `ensure_installed={}`、`auto_install=false`，打开代码不安装。JSX使用JavaScript parser，React TSX使用TSX parser，Vue2/3共用Vue parser。高亮与Coc语言服务分别验收。

Git 跟踪文件停留约 1 秒后显示行尾 blame。`空格 gb` 查看当前行详情，`空格 tb` 切换行尾 blame。无提交历史的文件没有历史作者信息。

`:CocInfo`、`:CocList extensions` 用于检查 Coc。UnoCSS 需要它自己目录内的运行依赖，不能只依赖顶层 npm hoist。

## 4. HTTP 请求

Windows 与 macOS 均启用 rest.nvim。打开 `.http` 文件后执行 `:Rest run`，或普通模式按 `go`。HTTPS 默认验证证书。

运行 `python3 tests/rest_smoke.py` 可启动回环地址 HTTP 服务，检查 Lua 依赖、GET、JSON/XML POST、外部 body 文件和 `.env` 变量。若 Windows 只提供 `python` 命令，则确认版本为 3.9+ 后使用它。测试临时目录仅保存一次性样例，配置与安装产物均不依赖它。

## 5. 大文件保护

满足任一条件即启用：超过 1 MiB、超过 20000 行、读取时单行超过 20000 字节。体积检查在读取前执行，行数和长行检查在读取后执行，阈值见 `lua/large_file.lua`。

当前 buffer 改为 `bigfile`，关闭 Treesitter、Coc 补全和自动格式化、Copilot、blame、折叠、缩进线及相关装饰；文件增长触发保护时也会解除 Copilot 附加。首次直接打开大文件时不加载分析插件，普通文件仍按需加载。`:LargeFileInfo` 显示判定结果。保护在当前 buffer 生命周期中保持；缩小文件并关闭后重新打开可恢复语法分析。

## 6. Tabnine 调查结论

coc-tabnine 开源免费，AI 服务的授权和套餐另行计算。旧官方更新域名 `update.tabnine.com` 在两个公共 DNS 的 A/AAAA/CNAME 查询中均无可用记录；本机代理 fake-IP 使错误表现为 TLS 握手失败。官方源码仍引用该域名，多个官方插件仓库已归档。重试、换证书或关闭 TLS 校验无法恢复分发服务。

官方 Git 历史中的 3.6.8 引擎已验证能做本地标识符补全，但过旧，未恢复云服务、账户和更新功能，因此未作为默认安装方案。当前统一 Coc 目录中 coc-tabnine 已禁用，自动安装声明已移除，由用户授权安装的 Copilot Free 接替。

Copilot 插件已固定版本，使用内嵌服务，首次插入或 `:Copilot` 才加载。完整重启 nvim 后，由你执行 `:Copilot setup` 完成账号授权，再用 `:Copilot status` 检查。插入模式 Ctrl+J 接受建议，Alt+] / Alt+[ 切换，Ctrl+G 隐藏，Coc 的 Tab 保留。Free 当前每月 2000 次补全，选型依据与限制见 [AI 方案](docs/ai-completion.md)。

证据入口：[coc-tabnine](https://github.com/neoclide/coc-tabnine)、[官方 tabnine-vim](https://github.com/codota/tabnine-vim)、[官方 tabnine-nvim](https://github.com/codota/tabnine-nvim)。

## 7. 验证范围

Windows 已验证 JS/TS/JSX/TSX/Vue 2/Vue 3/Go/Python 实际高亮、真实 Git blame、三种大文件条件及普通/大文件切换；Git Bash 与 zsh 通过同组检查。约 2.5 MB TypeScript 样例约 0.44 秒进入主循环。平台模块已验证含空格和 `&` 路径的 Python 运行与 GCC 编译执行。

HTTP 最终结果见设计文档。macOS 已审查平台分支，本轮没有 macOS 实机编译与交互记录。

本轮新增 `tests/startup_smoke.py`、`tests/coc_smoke.py`、`tests/ai_smoke.py`，分别验证停滞 GCC 不阻塞首屏、Coc 统一目录及重启后状态、真实内嵌 AI 服务初始化与大文件保护。测试不代替用户账号授权后的真实建议验收。

## 8. 修改后如何生效

Go 文件黑屏的后续修复见 [工具链启动记录](docs/issues/2026-10-22-go-toolchain-startup.md)。Coc 接管 Go 语言服务时，配置解除 vim-go 仍注册的 LSP 自动事件；编辑启动不再因此等待工具链下载。明确构建/测试继续遵循项目 Go 版本要求。可运行 `python3 tests/go_startup_smoke.py` 验证，修改后完整退出重开 nvim。

`coc-settings.json` 的语言服务设置可用 `:CocRestart`（空格 cr）重启 Coc；bootstrap、环境、插件和 Lua 模块变化需要完整退出再启动 nvim。`:source $MYVIMRC` 不能刷新全部 Lua 缓存、插件事件和进程环境。完整链路与重载边界见 [设计第 13 节](docs/design.md#13-部署启动平台适配与重载链路)。

## 2026-10-22 治理后的补充部署

语言服务不依赖shell临时目录。先按 [语言服务部署](docs/language-services.md) 显式部署固定的Coc扩展、LuaLS、gopls及goimports；其二进制在各平台自己的 `stdpath(data)` 中。日常打开文件不安装工具。

使用Neorg前，在配置目录执行 `python scripts/provision_neorg.py --apply`，本机编译norg/norg_meta；打开笔记不自动联网安装。搜索原生库在本平台显式运行 `:Lazy build telescope-fzf-native.nvim`，完成后重启，用 `:SearchHealth` 确认。

升级采用锁定提交，清单见 [分组选版](docs/plugin-upgrade-plan-2026-10-22.json)。原Legendary SQLite不会被清理，跨机器迁移步骤见 [实施回执](docs/implementation-2026-10-22.md#原命令面板数据迁移)。安装完成后运行 `python tests/run_all.py --output docs/evaluations/final-regression.json`；macOS必须使用自己的运行产物执行相同回归。
