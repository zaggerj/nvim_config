# 免费 AI 补全选型与当前配置

核验日期：2026-10-22。选型标准是免费资格、Neovim 官方支持、Windows/macOS 可用性、维护状态、Coc 共存和启动行为；没有完成相同代码样本的模型质量横向测试。

## 结论与比较

当前安装 **Copilot Free + 官方 copilot.vim**。用户已授权安装配置，账号授权由用户完成。它不是无限免费：当前 Free 每月含 **2000 次补全**，超出后以账号当期额度规则为准，不自动转为付费。

| 方案 | 官方核验结果 | 本次取舍 |
|---|---|---|
| Copilot Free | 官方 Neovim README 明确支持 Free，插件未归档，内嵌服务可避免 npx 下载 | 当前选择；有每月额度，需要 GitHub 账号 |
| Windsurf/Codeium | 云套餐有免费 Tab，但官方 vim/nvim 仓库均已归档 | 不用归档插件替换另一套归档插件 |
| Supermaven Free | 免费档与 Neovim 支持存在；插件未归档，但最后 pushed 为 2024-10-07 | 当前首次二进制下载同步调用 shell，Windows 用 PowerShell，未设置请求超时；不作为本次默认 |
| Ollama + Minuet | 本地推理无按次云 API 费用；插件支持 Neovim 0.10+ | 离线备选，模型、硬件和延迟需另行实测；不能把下载体积当运行内存需求 |

来源：[Copilot 官方 README](https://github.com/github/copilot.vim/blob/release/README.md)、[官方免费额度](https://docs.github.com/en/copilot/get-started/plans-for-github-copilot)、[Windsurf 套餐](https://windsurf.com/pricing)、[Windsurf Neovim 仓库](https://github.com/Exafunction/windsurf.nvim)、[Supermaven 套餐](https://supermaven.com/pricing)、[同步下载源码](https://github.com/supermaven-inc/supermaven-nvim/blob/main/lua/supermaven-nvim/binary/binary_fetcher.lua)、[Minuet](https://github.com/milanglacier/minuet-ai.nvim)、[Ollama](https://github.com/ollama/ollama)。套餐和维护状态会变化，下次选型需要重核。

## 已实施的配置

入口为 [lua/ai.lua](../lua/ai.lua) 和 [插件规格](../lua/plugins.lua)。官方插件固定提交 `a12fd5672110c8aa7e3c8419e28c96943ca179be`，内嵌语言服务版本 1.408.0，需要 Node.js 22+。

- `g:copilot_version = false`：官方支持的内嵌服务选项，启动不调用 npx。
- 首次 InsertEnter 或 `:Copilot` 加载；代码文件上显式补上延迟加载错过的初始化。
- `g:copilot_no_tab_map` 与 `g:copilot_no_maps` 避免覆盖既有 Coc 键位。
- 只启用 JS/JSX、TS/TSX、Vue、Go、Python、Lua、C/C++、Java、Rust、Shell、PowerShell。其他类型默认关闭。
- 大文件启用 buffer 禁用，已有 Copilot LSP 附加会解除。先打开大文件不会启动 AI 服务；普通文件增长后也停止附加。
- Windows 子进程的 XDG_CONFIG_HOME 与 HOME 由 bootstrap 固定，避免不同 shell 分裂授权状态。凭据保留在本机，不提交、不记录到文档。

普通代码会按服务协议发送上下文到 GitHub；若项目要求完全离线，先 `:Copilot disable`，另行采用本地方案。HTTPS 保持证书验证；需要代理时遵循官方 `g:copilot_proxy` 或 HTTPS_PROXY，不能照抄关闭证书校验的例子。

## 授权与使用

重启 nvim，执行：

```vim
:Copilot setup
:Copilot status
```

按提示由本人完成 GitHub 设备授权，选择 Free，不需要开通付费方案。随后打开普通代码文件并进入插入模式，等待灰色行内建议：

| 按键 | 行为 |
|---|---|
| Ctrl+J | 接受当前 AI 建议；没有建议时不插入内容 |
| Alt+] / Alt+[ | 下一个 / 上一个建议；终端需能传递对应组合键 |
| Ctrl+G | 隐藏当前 AI 建议 |
| Tab | 保留原 Coc 补全行为 |

`:Copilot disable` / `:Copilot enable` 控制当前 Neovim 会话。当前配置的文件类型和大文件限制仍然生效。插件、环境和版本变更后完整重启 nvim；只修改 Coc 设置时才使用 `:CocRestart`。

## 验收状态

`python3 tests/ai_smoke.py` 已运行真实内嵌服务并确认初始化、无 npx、Coc Tab 未被替换，以及大文件首次启动/增长保护。此检查不申请设备授权，也不读取或输出账号凭据。

用户授权后的云端真实补全与实际建议质量仍需验收；macOS 只有代码分支审查，没有本轮实机记录。未验证事项见 [故障记录](issues/2026-10-22-startup-coc-tls.md)；后续结果追加到 [决策记录](decisions.md)。
