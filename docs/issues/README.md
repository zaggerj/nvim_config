# Neovim 问题台账

更新时间：2026-10-22。当前 Windows 宿主版本 **0.12.6**。本表合并用户历次问题；历史调查快照保留，当前状态以本表和各记录的最新回执为准。

| 用户问题 | 已核实原因与处理 | 验证 / 剩余事项 |
|---|---|---|
| JS/TS/Vue2/Vue3/React 高亮缺失 | Treesitter parser 清单拼写与加载配置修正 | editor_smoke 覆盖 JS/TS/JSX/TSX/Vue2/Vue3 的真实查询；不等于完整语言服务 |
| Go/Python 高亮缺失 | 同上，补齐 parser 路径 | editor_smoke 两类高亮通过；专用 Coc 服务仍缺，见插件审查 |
| git blame 不显示 | 修正 Gitsigns 逐 buffer 附加与映射 | 临时真实 Git 仓库断言 blame 作者通过 |
| 大文件启动慢/卡死 | 读取前识别 >1MiB、>20000行、单行>20000字节；关闭昂贵分析附加 | 三类读取保护通过；总字节/行数增长已有回归，长单行编辑增长漏保护，见最新评审R03 |
| Windows rest.nvim rocks 缺失 | 恢复插件，隔离固定 Lua/LuaRocks/CLI；原生构建与显式 DLL parser 加载 | 三入口真实 HTTP 请求通过；工具构建见安装指南 |
| Tabnine 下载 TLS 失败 | 旧官方更新域名无可用 DNS，官方插件归档；未恢复该上游服务 | 已按用户选择切换官方 Copilot Free；未关闭 TLS。详见 AI 选型 |
| 启动 Coc TLS 再报错 | zsh XDG 读到另一份仍启用 Tabnine 的状态 | 固定 canonical Coc 目录、保留源目录复制部署；三入口含重启回归通过 |
| 黑屏需 Ctrl+C：同步启动等待 | GCC 同步探测和启动 clone 路径 | 移出首屏；停滞 GCC 故障注入通过。它不足以解释后续 Go 黑屏，见下一项 |
| 原 Go 文件仍黑屏 | vim-go 关闭 gopls 后残留事件同步 go env，按 buffer 目录触发项目工具链下载 | go_compat 清除残留 LSP 事件；保留构建/测试；真实 TUI 和停滞 fixture 均通过 |
| Go首屏1.39秒能否再优化 | 状态栏在主题前加载导致重复setup；文件启动也加载首页 | 本轮交替A/B首屏中位数437→350ms，高亮/状态栏就绪619→512ms；详见启动性能记录 |
| `_bug`目录主题报E185 | 旧forest-night仓库当前提供的主题名为everforest | 修正主题调用，默认/`_oem`/`_bug`真实回归通过 |
| 免费 AI 最佳选择与安装 | 选择官方 Copilot Free，固定提交、使用内嵌服务、Ctrl+J 接受 | 本地服务、键位和保护通过；用户执行 Copilot setup，云端建议待验 |
| 重载后行为不一致 | require 缓存、lazy 和事件的进程状态无法由 source 完整重置 | Coc 设置用 CocRestart；环境、Lua、插件、宿主变化完整退出重开 |
| 升级 Neovim | Scoop 全局 0.10.2 → 0.12.6，旧版保留 | 发现并修复 rest 隐式 parse 兼容问题，见升级记录 |
| 插件是否合适/是否更新替换 | 审查39个 Git 插件、14个 Coc 扩展；2个归档、语言服务有缺口 | 本轮不批量升级/替换；见分批建议与官方证据 |
| Go定义跳转实际失效 | buffer-local gd进入vim-go，默认gopls路径但服务已关闭；Coc专用Go服务尚缺 | 新评审R01确认调用链，待统一服务和映射 |
| 终端Esc、Git ]c容易误操作 | 终端发送exit；]c重置全buffer未暂存修改；空格gd仅有描述 | 运行映射已确认，待改键位；教程已明确提醒 |
| 搜索性能和双平台结果不同 | live_grep绕gitignore且Lua后过滤；目录模式不匹配反斜杠，正斜杠又会过滤合法lib源码 | fixture与Telescope entry maker已确认，待修R04 |
| 状态栏选项冲突 | lualine globalstatus=true，实际laststatus=2 | 已运行确认，待统一期望和配置 |
| 每个项目不同主题 | 当前仅启动cwd三分类，未启用DirChanged | 综合评审第5节给出项目根识别及进程级主题方案，尚未实施 |
| 缺少完整操作教程 | 旧速查不足以解释插件局部映射与buffer/tab/window关系 | 已建立tutorial.md，源码和运行映射核对，链接见证据入口 |
| Windows/macOS 通用与文档持续接续 | 源码与各平台运行产物分离；两个仓库分别保存正式契约和导航回执 | 三种 Windows 入口已验，macOS 无实机；部署不依赖诊断临时目录 |

## 证据入口

- [整体设计](../design.md)、[持续决策](../decisions.md)、[安装指南](../../WINDOWS-SETUP.md)。
- [Coc TLS 与首屏等待](2026-10-22-startup-coc-tls.md)。
- [真实 Go 文件黑屏根因与回归](2026-10-22-go-toolchain-startup.md)。
- [Go启动耗时优化与测量口径](2026-10-22-startup-performance.md)。
- [0.12.6 升级及 rest 兼容](2026-10-22-neovim-012-upgrade.md)。
- [免费 AI 选择和账号边界](../ai-completion.md)。
- [全量插件审查与待实施事项](../plugin-review-2026-10-22.md)。
- [最新综合评审与已确认缺陷](../configuration-review-2026-10-22.md)。
- [完整教程与所有自定义快捷键](../tutorial.md)。

后续新问题追加本表、对应故障证据和 decisions；不得把历史合成测试结果替代用户现场复现。正式配置不引用测试临时产物。
