# 2026-10-22 平台验收记录

本记录关联[治理SPEC](spec.md)、[任务21](tasks/21-platform-acceptance.md)、[任务27](tasks/27-keymap-discoverability.md)和[完整教程](tutorial.md)。最新运行状态 `dfa43ac`，完整功能回归39/39、本轮三入口补验9/9通过；原c4493af的37/37及分阶段27/27保留历史。下文分别标注子矩阵时间与补验范围，保留早期失败证据。

## 源码与入口

本次键位子矩阵的基线为`2aa64bd4f1ee6c91013385ab6f374f814398a728`加2026-10-22实施工作树。配置使用同一个`C:/Users/zagge/.config/nvim`，Coc复用canonical数据目录，无另建shell专用配置。

| 入口 | 真实程序 | 当前证据 |
|---|---|---|
| PowerShell | 当前PowerShell宿主 | keys_smoke全套、真实闲置pwsh TUI通过 |
| Git Bash | GlobalScoopApps/apps/git/current/bin/bash.exe | keys_smoke全套、真实闲置bash TUI通过 |
| MSYS2 zsh | Scoop/apps/msys2/2026-03-22/usr/bin/zsh.exe | keys_smoke全套通过；真实默认登录配置闲置TUI通过（绝对响应fixture） |
| macOS | 无可用目标宿主 | 未执行；不能用Windows静态兼容检查代替实机 |

已只读检查本机SSH配置的Host声明：仅网络通配规则，没有能定位macOS的具体主机。没有读取密钥或扫描内网。

## 已完成的真实工作流

| 回归 | 用户行为与观测 | 结果 |
|---|---|---|
| `python tests/keys_smoke.py` | 带空格目录、当前/分屏终端Esc后job存活且不收到exit，再进入后真实接收输入；真实Git多hunk、diff窗口、index暂存/撤销与确认重置；分组前缀、resize；首次大文件无Coc翻页和编辑 | 三个Windows入口通过 |
| `python tests/keymap_inventory_smoke.py` | 普通Python和Go各17个自定义WhichKey描述具有运行时动作；zR/zM真实折叠；AI接受与隐藏/surround前缀；真实插入包围；norg真实加载12个逗号动作 | PowerShell完整回归通过；本项未单独在Bash/zsh重复 |
| `python tests/neorg_deploy_smoke.py` | 缺本平台parser的配置边界给出明确部署指引，不初始化Neorg、不触发自动安装 | PowerShell通过 |
| `python scripts/provision_neorg.py --apply` | 显式下载源码并使用本平台编译器重建norg/norg_meta，随后真实norg加载 | Windows通过；不是跨平台复制二进制 |
| `python tests/ai_smoke.py` | 内嵌Copilot服务初始化，Coc Tab保留，大文件首次启动及增长均禁用AI | 本地初始化通过；不包含账号后云端建议 |

真实闲置shell测试必须在有TTY的工具会话运行：`python tests/keys_smoke.py --case idle-tui`。Windows headless终端测试的前台fixture使用`CONIN$`读取真实控制台输入；普通管道stdin的EOF不作为编辑器退出证据。

默认zsh最终复验：Esc后job存活，i后命令真实写入绝对fixture成功，本次工具总耗时4.76秒。早期8秒测试只观察登录日志，后来采用相对响应文件又遇到登录shell切换cwd到HOME，造成测试假失败；现已使用绝对响应路径纠正，并清理核实属于本次测试的HOME响应文件。PowerShell5.1重定向采用UTF-16LE，由测试读取时规范化；生产配置未改动。30秒是命令等待上限，不是本轮测得的启动耗时。

## 最终整合与未完成边界

`c4493af` 完整回归已顺序运行启动、进程生命周期、高亮/blame、大文件增长、真实语言服务、四类HTTP、搜索、主题、重载和新入口，**37/37通过**，见 [原始报告](evaluations/final-regression.json)。键位清单与Neorg缺parser指引均在此完整回归通过；这两项没有额外在Bash/zsh重复运行，不能计入下述27项。

三Windows入口各9项的分阶段矩阵 **27/27通过**，见 [原始命令与输出](evaluations/platform-windows.json)。大部分子项基于 `e3d80f6` 加当时实施工作树；zsh的search/Coc/AI在本轮工具发现修正后补验，修正归 `c4493af`。该JSON逐项保留revision_scope，不能将它描述为全部在最终提交重跑。三入口的Coc真实增长解除另在任务05保留定点证据。

zsh首次矩阵失败的具体根因：其PATH没有官方Node及WinGet rg目录，却能找到MSYS无扩展名node副本；Windows原生插件的字面node调用不能可靠使用它。共享platform发现层现在优先原生exe，并查标准Node安装根和WinGet Links，再由bootstrap将真实工具目录注入本Neovim进程PATH。测试没有导出个人Node/rg路径，也没有修改用户shell文件；最终zsh CocRestart、Copilot本地服务及实际搜索通过。

- macOS仍须在目标机器显式重建rocks/parser/fzf，并执行相同测试与交互工作流；任务21保留未完成。
- Copilot账号由本人完成授权，授权后的真实云端建议单独验收；本地服务初始化不能代替账号云端结果。
- 完整重启用于Lua、插件、PATH及原生产物变更；Coc设置改动使用CocRestart，分别验证，不以重复source模拟重启。

## 接续：dfa43ac最终运行状态

provider显式部署与中断恢复、Windows频率锁和Git观察器修正后，完整功能回归 **39/39通过**：[当前原始报告](evaluations/provider-final-regression.json)。前两次37/39（频率锁及Go单次请求超时）、38/39（Git观察器单次index读取错误）保留在provider-integration-first.json与provider-integration-second.json；定点与最终结果分列，不掩盖失败。真实安装中断恢复测试另执行通过，保留已有sentinel；此测试会显式安装固定包，故未混入日常不联网回归。

同源码及数据契约的本轮入口补验 **9/9通过**，每入口三项：provider停滞PATH/用户host/真实py3eval、未完成环境实际部署提示、Python定义/引用/rename/补全/类型诊断。三入口具体命令和输出见[本轮矩阵](evaluations/provider-windows.json)，不把它宣称为39项均在三个入口重跑。macOS及账号云端AI状态保持待验。

## AIPaaS Go 工作区定点验收

最终项目配置 `GOFLAGS=-mod=readonly`、项目既有代理。PowerShell（仓库根、CocRestart）、Git Bash（仓库根）、MSYS2 zsh（backend）三入口实际打开 build_upload.go；定义251行、悬浮、3处引用和go输出频道检查均通过，三次go.mod/go.sum字节一致。zsh按既有矩阵补基础Scoop/System32 PATH，未改shell配置。完整Go功能fixture顺序复验通过；未把它计入三入口全套回归。历史EOF未复现、初次探针/并发超时失败和修正过程见 [工作区加载故障](issues/2026-10-22-go-workspace-load.md)。macOS本轮仍无实机结果。
