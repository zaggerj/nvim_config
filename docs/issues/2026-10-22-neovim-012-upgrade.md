# Neovim 0.12.6 升级与兼容回归

2026-10-22，用户要求“升级一下 neovim 吧，先”。Windows 原生 Neovim 从 0.10.2 升级为官方稳定版 **0.12.6**；不随此次升级批量更新插件。正式设计见 [整体设计](../design.md)，全部问题见 [台账](README.md)，插件取舍见 [审查](../plugin-review-2026-10-22.md)。

## 安装来源与回退

沿用现有 Scoop 全局安装，通过 `scoop update neovim --global --independent` 更新。Scoop 自身与 buckets 元数据随之更新，没有升级其他应用。当前 `D:/install/GlobalScoopApps/apps/neovim/current` 指向 `0.12.6`，全局 shim 保留。配置 junction、源码和数据位置不变。

- [官方发布 v0.12.6](https://github.com/neovim/neovim/releases/tag/v0.12.6)，发布于 2026-10-09，非预发布。
- [Windows 官方包](https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-win64.zip)。SHA256：`4e12b7103b601ffc8f25954b4da100f339faa73dccb69a5b135e897fa3d893ed`。
- 旧 `0.10.2` 安装目录保留，未执行 cleanup。必要时退出 nvim 后在管理员 PowerShell 执行 `scoop reset neovim@0.10.2`，再核对版本；已检查 Scoop reset 源码支持版本选择并自动识别全局安装，未实际回退。该命令不支持 `--global` 参数。
- PowerShell、Git Bash、zsh 均确认 `NVIM v0.12.6`。macOS 没有本次实机升级结果。

## 实际发现的 rest.nvim 不兼容

升级后真实 HTTP 测试失败：`Failed to find request at cursor position`。Neovim 0.12 的 `vim.treesitter.get_node()` 不再负责隐式解析；runtime `doc/treesitter.txt` 要求树尚未解析时先调用 parser parse。锁定 rest.nvim 的请求定位直接 get_node，首次请求因此拿不到节点。

诊断先得到 `NODE_BEFORE nil`；显式 parse 后生成 HTTP document，并取得 node 和请求节点。新增 [rest_compat.lua](../../lua/rest_compat.lua)，仅在 0.12+ 包装 rest 请求定位，在调用原函数前使用插件自己的 `ts_parse_source`。由插件配置显式初始化，不修改上游安装目录、全局 Treesitter API 或 TLS 行为。0.10/0.11 保持原路径。

修复后真实 GET、JSON/XML POST、外部 body 和 `.env` 回归通过，Windows 上继续保留 rest.nvim 的完整请求能力。

## 验证与边界

| 检查 | 本轮结果 |
|---|---|
| `tests/go_startup_smoke.py` | PowerShell / Git Bash / zsh 通过；停滞 Go fixture 不被残留 LSP 事件调用 |
| `tests/startup_smoke.py` | PowerShell 通过，停滞 GCC 不阻塞首屏 |
| `tests/coc_smoke.py` | PowerShell 通过，含真实 CocRestart |
| `tests/ai_smoke.py` | PowerShell 通过，真实内嵌服务初始化、键位和大文件保护 |
| `tests/rest_smoke.py` | 三个 Windows 入口通过，涵盖上述五类真实请求 |
| `tests/editor_smoke.py` | PowerShell / Git Bash / zsh 通过：JS、TS、JSX、TSX、Vue2、Vue3、Go、Python 高亮；真实 git blame；三类大文件保护 |
| 真实 zsh TUI 原 Go 文件 | 首屏约 1394.668 ms，无需 Ctrl+C |

TUI 日志保存在本机数据目录 `tui-upgrade-0126-verified.log`，不属于可移植配置依赖。新增 editor 测试使用临时 Git 仓库和实际解析查询、Git 作者断言；不改全局 Git 身份。三种大文件分别触发字节数、行数和长单行阈值，并断言 Treesitter/Coc/Copilot 保护。

补跑 editor 测试时，直接启动的 MSYS2 zsh 登录环境未发现 Python；测试命令临时将现有全局 Scoop shims 和 Python 安装目录加入该进程 PATH 后通过。没有修改登录 shell 配置；此项证明原生编辑器在该入口的行为，不计作 Python 在任意 zsh 登录环境中自动可发现的验收。

高亮验收不覆盖完整语言服务；Go、Python、Vue 专用 Coc 服务缺口见插件审查。Copilot 云端建议待用户账号授权，macOS 待实机验证。配置变化需要完整退出并重开，不依赖 source 热重载。
