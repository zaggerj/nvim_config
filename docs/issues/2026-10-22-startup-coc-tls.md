# 2026-10-22：Coc TLS 异常与启动黑屏

**后续更新**：用户再次提供 Go 文件黑屏截图，本轮已真实复现并定位工具链下载的同步等待，见 [Go 启动故障记录](2026-10-22-go-toolchain-startup.md)。本文保留先前调查过程，最新黑屏验收以新记录为准。

状态：配置修复与 Windows 回归已实施；账号授权及 macOS 实机验证待完成。关联 [设计](../design.md)、[决策](../decisions.md)、[AI 方案](../ai-completion.md)。

## 现象与调查方法

用户从项目目录打开 nvim 后看到：

```text
[coc.nvim]: UnhandledRejection: Client network socket disconnected before secure TLS connection was established
```

另一次启动长时间黑屏，Ctrl+C 后才能进入。TLS 异常发生在 Node 网络请求中，黑屏是否阻塞在进入主循环之前需要独立计时，不能只凭截图归为同一故障。

反馈回路：从实际 zsh 打开目录，等待 Coc 激活并查询扩展状态；用 `--startuptime` 测量首屏。控制实验通过只在 Neovim 子进程 PATH 中放入停滞的 GCC，验证同步探测是否阻塞界面。测试不更改系统 PATH、代理、证书或登录 shell。

## 证据与根因

1. 在 zsh 使用同一配置打开目录，复现截图中相同 TLS 文本。Coc 实际数据目录是 MSYS2 用户 `.config/coc`，其中 `coc-tabnine` 仍启用；Windows 默认 LocalAppData 的另一份 Coc 状态已禁用它。
2. Coc 源码 `autoload/coc/util.vim::coc#util#get_data_home()` 先读显式 `g:coc_data_home`，未设置时再检查 `XDG_CONFIG_HOME`。统一 HOME 无法覆盖第二个条件。两份配置源指向同一仓库，不代表扩展状态一致。
3. Tabnine 激活在二进制缺失时请求 `https://update.tabnine.com/bundles/version`。前轮已查明公共 DNS 无可用记录、官方插件归档；zsh 从未禁用的另一份状态再次进入失败下载链。
4. 普通无文件启动约 0.37 秒，zsh 打开目录约 0.65 秒，后续目录复验约 0.93 秒。没有复现用户当次原始长黑屏。
5. `bootstrap.init()` 原来在首屏前执行 GCC 并同步 `wait(5000)`。`python tests/startup_smoke.py` 修复前明确失败：`Stalled compiler blocked startup: 5.68s (budget 3s)`；修复后通过，约 0.58 秒。证明该路径有阻塞能力，但历史会话无计时，唯一归因仍无法还原。

## 修复范围

- `bootstrap.lua` 固定 Coc 数据/配置位置，Windows 子进程规范 HOME/XDG_CONFIG_HOME；GCC 仅发现真实路径，不在启动时运行探测。
- `scripts/deploy.py` 将已验证的约 84 MB Coc 扩展状态复制到 `stdpath('data')/coc`；保留两个旧目录，重复部署健康目标不写入。部分复制留下标记，禁止静默覆盖。
- `init.vim` 移除 Tabnine 自动扩展声明；Coc 扩展安装改为显式 `:CocProvision`，版本在仓库清单管理。缺失 lazy.nvim 时显示部署说明，不阻塞 Git 下载。
- AI 由官方 Copilot Free 接替；固定插件和内嵌服务，不使用 npx 下载。详细选择和账号步骤见 AI 文档。
- `large_file.lua` 为 Copilot 设置 buffer 禁用，并解除已附加 LSP，覆盖首次打开及普通文件增长两条路径。

没有关闭 TLS 验证、屏蔽未处理异常或改系统网络设置。保留的旧目录用于回溯，不再由当前入口读取。

## 可重复检查

```sh
python3 tests/startup_smoke.py
python3 tests/coc_smoke.py
python3 tests/ai_smoke.py
python3 tests/rest_smoke.py
```

startup 测试验证停滞编译器不阻塞首屏；Coc 测试使用真实 Node/扩展，断言统一数据目录、无自动安装清单、Tabnine 未激活且无同一 TLS 异常；AI 测试运行真实内嵌服务，检查初始化、保留 Coc Tab、AI 接受键及大文件初始/增长保护；HTTP 测试检查真实请求。测试临时文件不参与运行配置。

## 重载、回滚与续作

本轮数据目录和插件变化需要完整退出并重新打开 nvim。`:CocRestart` 只负责语言服务进程，不能刷新整个配置或改变既有进程环境。没有建立 `:source $MYVIMRC` 的完整热重载保证。

回滚时按 Git diff 分别恢复本轮文件，不覆盖前轮或用户改动；旧 Coc 目录仍在，可通过明确的 `g:coc_data_home` 临时选择。不要删除已部署目录、迁移标记或账号文件来掩盖失败，应先核对内容及归属。

开放项：用户完成 `:Copilot setup` 后验证真实建议；macOS 实机部署/编译/交互；若原环境再次长黑屏，保留该次 `--startuptime` 和 `:CocOpenLog` 日志，并核对实际入口，不能用已通过的合成测试替代新证据。

## 2026-10-22：最终回执

PowerShell、Git Bash、zsh 的 Coc 测试均退出 0，输出 `CocRestart rechecked; no TLS rejection`，即首次启动及真实重启后检查都通过。三个入口的 AI smoke 和 stalled GCC smoke 均已通过；后者修复后约 0.58–0.75 秒。HTTP smoke 本轮 PowerShell 再次通过，其他两个入口此前已通过且 HTTP 实现未再变化。

用户授权范围内的插件安装、配置和两仓库记录已完成。账号未授权、未进行真实云端补全测试；macOS 没有实机验收。安装与重载操作见 [安装指南](../../WINDOWS-SETUP.md)，设计边界见 [整体设计第 13 节](../design.md#13-部署启动平台适配与重载链路)。
