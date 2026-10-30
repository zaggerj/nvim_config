# AIPaaS Go 工作区加载失败与下载 EOF

## 结论与状态

截至 2026-10-23，**AIPaaS 的 Go 语言服务因项目模块模式缺失而加载失败**的修复由个人 Neovim 的 `lua/languages.lua` 承担。此前在 AIPaaS 新建 `backend/.vim/coc-settings.json` 的方案已撤回；个人工具配置不再写入业务仓。按 Go module 身份识别项目，在 Coc 初始化前合并 `g:coc_user_config`，保持普通 Go 项目的环境和已有设置。

截图中的 **下载 EOF 网络根因仍待确认**：未复现，也没有取得完整的历史下载目标。它与已确认的 vendor 加载错误分开跟踪。本记录保存排查和验收证据；当前运行行为的事实源为个人配置仓的 `lua/languages.lua`。

## 现场与已确认根因

用户在 `backend/internal/domain/image/build_upload.go` 收到 `[coc.nvim] Error loading workspace folders (expected 1, …): EOF`，尾部包含被截断的签名下载 URL。报错由 gopls 工作区加载路径产生，经 Coc 显示。签名参数不收录到文档。

真实项目的定义请求曾返回 `no package metadata for file`。直接运行托管 gopls 的 `check`，输出明确包含 `inconsistent vendoring`：项目 go.mod 与本地旧 vendor/modules.txt 不一致。该命令即使返回码为 0，日志仍可能表示加载失败，不能只验返回码。

项目后端 Makefile 已明确默认模块模式，并向子 Go 进程 export `GOFLAGS=-mod=mod`；仓库根 Makefile 默认 `GOPROXY=https://goproxy.cn,direct`。从编辑器直接启动 gopls，不经过 Makefile，不会自动继承这两个设置。缺少模块模式是本次可稳定复现的语义失效原因。

宿主 Go 为 1.26.3；项目要求 1.26.9，自动工具链缓存已有完整版本，在 backend 执行 `go version` 实际为 1.26.9。因此没有通过升级宿主、删工具链缓存或改 go.mod 来处理。

## 对照与修复

2026-10-22 先仅在测试子进程设置 `GOFLAGS=-mod=mod`，原真实文件即恢复定义、悬浮与引用。随后曾在 AIPaaS 仓库新增 `backend/.vim/coc-settings.json`。2026-10-23 用户指出这污染业务主检出树，已将下面的环境设置迁入个人配置，并保全迁出旧目录：

```json
{
  "go.goplsOptions": {
    "env": {
      "GOFLAGS": "-mod=readonly",
      "GOPROXY": "https://goproxy.cn,direct"
    }
  }
}
```

当前使用 Coc 官方支持的 `g:coc_user_config` 初始化入口，以及 gopls 官方 `env` 设置，作用于本次 gopls 的外部 Go 命令。启动参数首个文件优先于 cwd；由该入口向父目录查找 `go.mod` 或 `backend/go.mod`，module 必须精确为 `github.com/aipaas/aipaas`，独立嵌套 module 停止向外继承。环境设置合并进已有 `go.goplsOptions.env`，不覆盖其他键。一项目一进程，更新配置后完整退出重开。

最终编辑器使用 `-mod=readonly`：与 Makefile 一样绕过 vendor、按模块解析，但不自动更新 go.mod。初版 `-mod=mod` 验证期间曾自动补写149条 go.sum 的 /go.mod 校验记录，已经撤回本次新增并恢复原换行；收紧为 readonly 后真实导航仍通过，go.mod/sum内容不再变化。不设置全局 `go env -w`，不修改 Neovim 进程的 GOFLAGS/GOPROXY，其他 vendor 项目继续使用自己的策略。识别不依赖仓库目录名、个人盘符、临时目录或 Windows 专属路径。

最终交付未保留 vendor、go.mod、go.sum 的改动，也没有改 TLS 校验或插件锁版本。迁移个人配置后完整重启 Neovim，同一项目后续服务重启可执行 `:CocRestart`。

## 排查与收敛过程

| 阶段 | 操作及观察 | 得出的结论或后续动作 |
|---|---|---|
| 确认影响 | 对截图真实文件请求定义，返回 no package metadata；直接 gopls check 日志显示 inconsistent vendoring | 问题已影响语言服务，不能只消除报错提示 |
| 核对环境 | 项目内实际 Go 为1.26.9，工具链已缓存；Makefile 与编辑器启动环境不同 | 优先验证模块模式差异，未将工具链缺失当作根因 |
| 单变量对照 | 只向测试进程加入 -mod=mod，定义、悬浮、引用恢复 | 确认缺少模块模式导致当前语义失效 |
| 比较下载路径 | 两个代理在全新缓存中均成功下载小依赖 | 当前网络可用；历史EOF仍需当次日志，速度样本不能证明历史失败原因 |
| 落项目配置 | backend工作区配置覆盖从仓库根/backend启动；初版mod模式自动补写149条校验记录 | 将编辑器收紧为readonly，撤回本次校验新增并恢复原换行 |
| 最终验收 | 三Windows入口、CocRestart、真实查询及现有Go功能回归通过 | 保留项目级修复；探针额外检查go.mod/go.sum前后字节一致 |

## 验证与证据边界

`tests/go_workspace_probe.py` 是可重复的只读真实项目探针。自动定位函数调用与声明，验证定义目标、悬浮内容、至少两处引用，校验探针前后 go.mod/go.sum 字节一致，并读取 `go` 输出频道检查工作区加载及 vendor 错误；退出前停止本次服务。只终止测试自身的后代进程，签名 URL 查询参数在输出前脱敏。

```sh
python tests/go_workspace_probe.py --root D:/code/aipaas --file D:/code/aipaas/backend/internal/domain/image/build_upload.go --symbol writeBuildFileUploadMeta --restart
```

本机定义解析到第 251 行声明，引用为 3 处，悬浮有效。从 backend 和仓库根正常启动均已通过；修正探针后 CocRestart 的相同行为和输出频道检查也通过。以上是服务可用结果，不是首屏耗时测量。

另用全新临时 GOMODCACHE，通过真实 `go mod download github.com/google/uuid@v1.6.0` 比较两代理：proxy.golang.org 成功约 10.85 秒，goproxy.cn 成功约 1.56 秒，均保持默认校验。样本仅代表本次小依赖下载，不能推广为所有依赖的固定速度。

**历史截图中的 EOF 本轮没有复现**，被截断的 URL 无法确定当时具体下载目标。已确认并修复工作区构建环境不一致；将下载路由与项目构建策略对齐，但不把 vendor 错误等同于网络 EOF，也不声称已经证明当时 EOF 的底层网络原因。若再次发生，保留当次 `:CocOpenLog` 与 `:CocCommand workspace.showOutput go`，先脱敏 URL query，再按具体下载目标调查。

测试开发时曾误读 Coc 初始化变量、误用 `gopls` 作为输出频道名，及同步调用打开输出频道引发 RPC 同步错误；探针已按当前源码改为直接读取变量、使用 `go` 频道和异步 RPC。它们属于测试装配问题，未作为用户故障根因。CocRestart 前后台模块检查仍在运行时，首次探针发现退出后子进程；探针改为通过 Coc 服务接口停止后再退出，保留严格后代检查。

一次与真实大项目探针同时执行的既有 Go 回归在默认 3000ms 定义请求超时；顺序重新执行 `python tests/language_services_smoke.py --language go` 全部通过，包含跨包定义、引用、重命名、悬浮、补全、保存格式化、GoBuild/GoTest、类型错误诊断与失败列表，以及外部真实 go build/go test。未修改测试超时或共享语言配置。macOS 本次没有实机结果。

## 维护依据

- [Coc 官方配置](https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file)：工作区 `.vim/coc-settings.json`；本机锁定版本 `:help coc-configuration` 同步核对。
- [gopls 官方设置](https://go.dev/gopls/settings)：`env` 传给外部命令。
- 本机 coc-go 1.3.35 的 `lib/extension.js`：`go.goplsOptions` 作为初始化选项；`lib/utils/config.js` 使用当前默认资源配置。
- [语言服务说明](../language-services.md)、[问题台账](README.md)、[持续决策](../decisions.md)。

## 2026-10-22 历史入口验收（旧项目配置）

以下均使用最终 `GOFLAGS=-mod=readonly`，且探针校验每次执行前后的 go.mod/go.sum **字节一致**：

| 入口 | cwd | 结果 |
|---|---|---|
| PowerShell | AIPaaS 根 | CocRestart 后定义251行、悬浮、3处引用、输出频道无工作区/vendor错误，通过 |
| Git Bash `-lc` | AIPaaS 根 | 同一真实文件三项查询和输出检查通过 |
| MSYS2 zsh `-lc` | backend | 同一真实文件三项查询和输出检查通过 |

zsh 非交互登录的默认 PATH 中没有 nvim；首次探针未启动编辑器，报 WinError 2。最终按既有平台验收方式，仅向测试入口补入 Scoop shims 和 System32 基础路径，没有注入语言服务/Node路径或修改用户shell配置。这一入口条件应随验证结果一并保留。

当时 AIPaaS 改动只有 backend/.vim 下的配置与说明；该目录已在 2026-10-23 保全迁出，不作为当前修复入口。go.mod/go.sum回到原内容及原CRLF换行。Windows保留设备名检查通过。没有提交或push，保留此前主题和路线文档的未提交改动。

## 2026-10-23 个人配置迁移验收

先迁出 `backend/.vim`，再使用个人配置执行以下验证；所有日志和诊断脚本位于仓外 `%LOCALAPPDATA%/Codex/Bugfix/tasks/aipaas/2026-10-23-workspace-artifacts/nvim/`。

| 检查 | 结果 |
|---|---|
| `python tests/go_project_env_smoke.py` | 修改前五个 AIPaaS 入口因缺少 module mode 失败；修改后八个入口全部通过，普通同名目录/独立嵌套 module 不注入，已有设置和进程 Go 环境不变 |
| 仓根真实探针 | 诊断变体验证定义第 251 行、悬浮、3 处引用及 gopls 实际 `GOFLAGS:-mod=readonly`；351 个 package 加载耗时 67.7 秒 |
| backend 真实探针 | 原版 `tests/go_workspace_probe.py` 退出 0，定义、悬浮、3 处引用及工作区日志检查通过 |
| 仓根 `--restart` | 原版探针在 `CocRestart` 后退出 0，同样三项查询和日志检查通过 |
| `python tests/language_services_smoke.py --language go` | 普通 Go module 的跨包定义、引用、重命名、悬浮、补全、保存格式化、GoBuild/GoTest、失败诊断与外部 go build/go test 全部通过 |

首次仓根原版探针的定义请求曾超时，失败日志保留；随后增加失败时也记录 gopls 输出的仓外诊断变体，未修改运行配置或测试超时即通过。日志确认大项目包加载需要约一分钟；首次超时的具体耗时来源没有进一步分解。所有真实探针均比较 go.mod/go.sum 前后字节，未产生改动；迁移后的验证没有重建 `backend/.vim`。macOS 实机仍待验证。

## 再次发生时如何接续

1. 在报错的同一个编辑器会话执行 `:CocCommand workspace.showOutput go` 和 `:CocOpenLog`，保留完整错误上下文；导出前删除签名URL的query参数。
2. 在对应Go模块目录核对 `go version`、`go env GOFLAGS GOPROXY GOTOOLCHAIN`；在 Neovim 执行 `:lua print(vim.inspect(vim.g.coc_user_config['go.goplsOptions']))` 检查启动时注入的 env，不创建业务仓 `.vim`。终端的 `go env` 显示的是终端环境，gopls 实际设置以上述个人配置和服务日志为准。
3. 若为vendor不一致或没有package metadata，先对照项目构建策略和Coc工作区，再运行本文真实项目探针；若为下载EOF，依据日志中的具体模块/工具链及下载主机做对照，不先清整个缓存。
4. 修正后执行 `:CocRestart`，复验真实定义、悬浮、引用、工作区日志和依赖文件是否变化；平台或启动入口改变时补验对应入口。

`-mod=readonly` 是Go模块解析策略，主要限制自动改写go.mod，不能作为所有Go命令永不补写go.sum的通用保证。本次项目的文件不变结论来自三次探针的字节比较；新项目或依赖变化后应重新验证。

待验证问题：历史下载EOF的具体目标及网络失败原因、macOS实机结果。zsh非交互PATH补入基础工具目录是本次测试条件，未作为已完成的用户shell配置修复。

## 维护记录

| 日期 | 变更 |
|---|---|
| 2026-10-22 | 记录现场、模块模式根因、代理对照、初版副作用、最终只读配置与三入口验证；补充结论状态、排查过程、四步接续和待验证问题，并关联两个仓库的设计及决策入口 |
| 2026-10-23 | 撤回在业务仓保存个人编辑器配置的方案；改为 Coc 初始化前按 module 身份注入 env，补充普通项目和多个启动入口的回归 |
