# Neovim 问题台账

更新时间：2026-10-22。当前 Windows 宿主版本 **0.12.6**。本表合并用户历次问题；历史调查快照保留，当前状态以本表和各记录的最新回执为准。

| 用户问题 | 已核实原因与处理 | 验证 / 剩余事项 |
|---|---|---|
| JS/TS/Vue2/Vue3/React 高亮缺失 | Treesitter parser 清单拼写与加载配置修正 | 真实高亮与JS/TS/JSX/TSX、Vue2.6/2.7/3服务分别回归，见语言服务矩阵 |
| Go/Python 高亮缺失 | 同上，补齐 parser 路径 | 高亮及Go/Python真实语言服务通过，见语言服务矩阵 |
| git blame 不显示 | 修正 Gitsigns 逐 buffer 附加与映射 | 临时真实 Git 仓库断言 blame 作者通过 |
| 大文件启动慢/卡死 | 读取前识别 >1MiB、>20000行、单行>20000字节；关闭昂贵分析附加 | 三类读取及编辑增长、粘贴、撤销、切buffer和保存重开恢复均已回归 |
| Windows rest.nvim rocks 缺失 | 恢复插件，隔离固定 Lua/LuaRocks/CLI；原生构建与显式 DLL parser 加载 | 三入口真实 HTTP 请求通过；工具构建见安装指南 |
| Tabnine 下载 TLS 失败 | 旧官方更新域名无可用 DNS，官方插件归档；未恢复该上游服务 | 已按用户选择切换官方 Copilot Free；未关闭 TLS。详见 AI 选型 |
| 启动 Coc TLS 再报错 | zsh XDG 读到另一份仍启用 Tabnine 的状态 | 固定 canonical Coc 目录、保留源目录复制部署；三入口含重启回归通过 |
| 黑屏需 Ctrl+C：同步启动等待 | GCC 同步探测和启动 clone 路径 | 移出首屏；停滞 GCC 故障注入通过。它不足以解释后续 Go 黑屏，见下一项 |
| 原 Go 文件仍黑屏 | vim-go 关闭 gopls 后残留事件同步 go env，按 buffer 目录触发项目工具链下载 | go_compat 清除残留 LSP 事件；保留构建/测试；真实 TUI 和停滞 fixture 均通过 |
| Python打开波动大、首屏仍慢 | 内置ftplugin调用has('python3')，同步启动多个解释器检测pynvim；未配置provider时没有等待上限 | 显式部署隔离provider并固定host，保留真实Python能力；新增停滞PATH及部署中断红绿回归，见[详细证据](2026-10-22-python-provider-startup.md) |
| Go首屏1.39秒能否再优化 | 状态栏在主题前加载导致重复setup；文件启动也加载首页 | 本轮交替A/B首屏中位数437→350ms，高亮/状态栏就绪619→512ms；详见启动性能记录 |
| `_bug`目录主题报E185 | 旧forest-night仓库当前提供的主题名为everforest | 修正主题调用，默认/`_oem`/`_bug`真实回归通过 |
| 免费 AI 最佳选择与安装 | 选择官方 Copilot Free，固定提交、使用内嵌服务、Ctrl+J 接受 | 本地服务、键位和保护通过；用户执行 Copilot setup，云端建议待验 |
| 重载后行为不一致 | require 缓存、lazy 和事件的进程状态无法由 source 完整重置 | Coc 设置用 CocRestart；环境、Lua、插件、宿主变化完整退出重开 |
| 升级 Neovim | Scoop 全局 0.10.2 → 0.12.6，旧版保留 | 发现并修复 rest 隐式 parse 兼容问题，见升级记录 |
| 插件是否合适/是否更新替换 | 审查39个 Git 插件、14个 Coc 扩展；2个归档、语言服务有缺口 | 本轮分组定点升级并迁移两个归档插件；候选评估和锁SHA见实施回执 |
| Go定义跳转实际失效 | buffer-local gd进入vim-go，默认gopls路径但服务已关闭；Coc专用Go服务尚缺 | 部署固定gopls与coc-go，由Coc负责导航；保留vim-go构建/测试及goimports保存格式化 |
| 终端Esc、Git ]c容易误操作 | 终端发送exit；]c重置全buffer未暂存修改；空格gd仅有描述 | Esc只回普通模式；]c/[c导航；hR确认重置；真实键位回归通过 |
| 搜索性能和双平台结果不同 | live_grep绕gitignore且Lua后过滤；目录模式不匹配反斜杠，正斜杠又会过滤合法lib源码 | 已修扫描端glob、默认ignore和显式入口；真实picker验证合法lib/中文/PCRE2/正反路径 |
| 状态栏选项冲突 | lualine globalstatus=true，实际laststatus=2 | 最终laststatus=3，与globalstatus一致；四类UI回归通过 |
| 每个项目不同主题 | 已按活跃普通文件项目根和DirChanged切换，支持worktree及monorepo | project_theme_smoke验证根识别、规则优先级、特殊buffer保留及进程级主题 |
| 缺少完整操作教程 | 旧速查不足以解释插件局部映射与buffer/tab/window关系 | 已建立tutorial.md，源码和运行映射核对，链接见证据入口 |
| Windows/macOS 通用与文档持续接续 | 源码与各平台运行产物分离；两个仓库分别保存正式契约和导航回执 | 三种 Windows 入口已验，macOS 无实机；部署不依赖诊断临时目录 |
| 最新Go启动回归超时 G01 | lualine diff通过Scoop Git shim启动；终止shim后真实Git仍持有输出句柄，已统一解析真实Git路径 | 快速切buffer/写通知三轮退出及输出句柄释放通过；成功/失败/超时清理只针对本测试进程树 |

后续修复按用户已接受的 [治理 SPEC](../spec.md)实施，规格验收与历史结果分别记录。

本轮新增：Neorg首次打开同步安装parser已改为显式部署；Copilot隐藏键改为Ctrl+G d，保留surround的Ctrl+G s/S前缀。详见 [实施回执](../implementation-2026-10-22.md) 与 [语言能力](../language-services.md)。

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
