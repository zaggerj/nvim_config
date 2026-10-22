# 2026-10-22：Go 文件启动黑屏、Ctrl+C 后才显示

状态：已复现同一文件和终端入口，修复后真实终端及故障注入通过。关联 [此前故障记录](2026-10-22-startup-coc-tls.md)、[设计](../design.md)、[决策](../decisions.md)。本记录补正此前只验证 GCC 合成阻塞、未覆盖真实 Go 项目的验收缺口。

## 现场证据

用户截图是在 Git Bash/zsh 从项目根打开 `backend/internal/domain/image/build_upload.go`。本轮在相同项目和入口、使用原生 TUI 复现黑屏；进程链为 Neovim → `cmd.exe /s /c ""go" "env" "GOBIN""` → Scoop Go shim → 原生 Go。发送 Ctrl+C 后出现 `vim-go: 'go env GOBIN' failed`，随即显示文件和退出提示，与用户截图吻合。

项目 `backend/go.mod` 要求 Go 1.26.9，本机基础 Go 为 1.26.3，`GOTOOLCHAIN=auto`。在文件所在目录直接执行 `go env GOBIN`，捕获 `go: downloading go1.26.9 (windows/amd64)`，7 秒仍未完成；项目根目录的同一查询很快返回。`vim-go` 会切换到 buffer 目录，故只在项目根运行命令会漏掉触发条件。

Go 官方源码 `cmd/go/internal/toolchain/select.go` 与 [工具链选择文档](https://go.dev/doc/toolchain)解释了版本选择和自动下载。下载会进入 Go 自身缓存；诊断过程中工具链已下载完成，所以仅重开文件变快不能作为根因修复证明，必须加入不依赖缓存的测试。

本机诊断计时文件在 `stdpath('data')`：`tui-zsh-20261022.log` 记录人工中断前等待约 68 秒，`tui-go-fixed.log` 记录修复后首屏 1108.96 ms。日志中的等待时长受人工发送 Ctrl+C 时刻影响，不是固定超时。

## 本次改动与责任边界

`vim-go` 原先已在插件清单中，不是本轮新增。前轮修改了它的 init，设置 `go_code_completion_enabled=0`、`go_gopls_enabled=0`，意图由 Coc 统一负责语言服务。但锁定版本只在创建 LSP 进程时检查关闭选项；FileType 的 DidOpen 与 buffer 的 DidChange 等回调仍然注册，仍会进入 `ensureWorkspace → ModuleRoot → ExecInDir → CheckBinPath → go env GOBIN` 的同步查询。

因此前轮对关闭语言服务后的实际行为检查不足，也没有测试此项目的 TUI 启动。已有证据不能将 Go 自动工具链选择归因于 HOME/XDG 修改；新旧 HOME/XDG 对照最终都选择相同版本。此前的 GCC 测试解决另一条阻塞路径，没有覆盖本次问题。

## 修复

新增 `lua/go_compat.lua`，仅在 vim-go 的 gopls 已关闭时移除该插件的残留 LSP 自动事件。全局 FileType 注册解除，逐 buffer 的 LSP 回调在 ftplugin 载入后清理。Vimscript autocmd 没有 API id，因此按当前 buffer 和事件重建，保留同事件中的格式化、检查和其他非 LSP 回调。

保留 vim-go 的 GoBuild/GoTest/格式化等命令和 Coc 的语言服务。不改项目 go.mod、不关闭 Go 自动工具链、不设置全局 GOTOOLCHAIN=local、不停用 vim-go。明确执行 Go 构建/测试仍可按项目要求选择或下载工具链；这不再由已关闭的重复语言服务在打开文件时同步触发。

## 验收

`python3 tests/go_startup_smoke.py` 在临时 Go module 中放入会停滞 8 秒且记录调用的 Go fixture，禁用 Coc 启动，仅隔离待测 vim-go 路径：

- 修复前实际失败：`Disabled vim-go LSP ran Go before/after first screen (17.96s)`。
- 修复后检查首次打开、两份 Go buffer 来回切换、CursorHold/CursorHoldI、写后通知、文件变化与删除事件，不调用 fixture；GoBuild 命令、格式化与检查事件保留。
- PowerShell、Git Bash、zsh 三入口执行结果追加到决策回执。真实 zsh TUI 打开原始 Go 文件约 1.11 秒显示，无需 Ctrl+C；该真实场景与故障注入共同作为验收依据。

临时文件只用于测试，运行配置不引用它们。用户已有 nvim 会话未操作；只关闭本轮创建的诊断进程。修改需完整退出并重开 nvim，已有进程不会自动应用新事件配置。macOS 仍待实机验证。

最终回执：多 buffer/后台事件版本在 PowerShell 1.59 秒、Git Bash 2.69 秒、zsh 1.79 秒通过；三个入口均未调用停滞 Go。Coc 启动与重启回归再次通过，Python 语法与 diff 空白检查通过。


## 分批提交前复核（2026-10-22）

本次未改运行配置，复跑 `tests/go_startup_smoke.py` 在30秒处超时。排查发现该次测试启动期间生成的 `git diff --no-color --no-ext-diff -U0 -- main.go` 子进程在父 Neovim 退出后仍存活；终止该测试遗留的Git进程后，Python回传 `subprocess.TimeoutExpired`。当前未核实Git停滞的具体原因，也未证实它与此前的Go工具链下载阻塞相同，不能将本次回归记为通过。后续应检查Git子进程生命周期和Windows管道句柄继承。

同批复核通过：Python脚本语法、JSON解析、editor_smoke（高亮/blame/大文件读取）、ui_startup_smoke（四场景）、ai_smoke、coc_smoke（含重载/TLS）、rest_smoke（四类本地HTTP请求）。macOS本次未实机复核。
