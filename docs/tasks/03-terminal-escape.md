# 03：让终端Esc只退出输入模式

**What to build（交付行为）：** 在终端按Esc回到普通模式，保留shell和前台程序；退出或停止任务使用明确入口。

**Blocked by（阻塞依赖）：** 无（可开始）。

**Status：** done（Windows真实前台及默认登录shell交互通过，教程已同步；macOS归21待验）

**归属：** A；[治理SPEC](../spec.md) R02 / ID03；验收 AC04。

## 验收标准

- [x] 消除后载入映射覆盖，最终终端Esc不发送exit及其他文本。
- [x] 空闲shell和运行中的前台程序均可按Esc离开输入，再次进入后继续交互。
- [x] fj和原生终端退出输入方式仍可用；现有明确停止任务入口行为可解释。
- [x] 覆盖当前窗口和分屏终端，路径含空格时可启动；三个Windows入口行为一致。
- [x] 通过实际终端job状态与接收文本验证，同步终端教程、键位表及问题记录。

## 范围与交付记录

不改变用户登录shell配置，不擅自终止已有终端。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)

## 2026-10-22 实施回执

- 红：`python tests/keys_smoke.py --case terminal` 在旧Esc映射下报 `Esc did not leave terminal input`；真实前台程序收到文本而未回普通模式。
- 绿：最终Esc映射仅发送终端退出输入序列，`fj`保持可用。测试用真实终端job和读取CONIN$的Windows前台程序验证无文本、job存活及重新输入ping；当前窗口/分屏和含空格路径均通过。PowerShell、Git Bash、MSYS2 zsh三个入口的默认完整keys_smoke通过。
- 真实TUI：`python tests/keys_smoke.py --case idle-tui` 在PowerShell默认pwsh与Git Bash默认bash登录shell通过；zsh默认登录配置8秒内仍在加载Windows配置，未完成命令回显，不归因为Esc。设置仅测试子进程的`NVIM_KEYS_CLEAN_SHELL=1`后，以zsh -f -i真实TUI验证Esc、重新进入和echo通过。未修改用户登录shell配置。
- headless Windows闲置shell会遇到stdin EOF，故没有把它作为闲置shell验证；前台fixture读取CONIN$，可真实检验按键文本。默认zsh登录初始化耗时是保留的集成边界，须在平台总验收记录。
- 旧配置恢复方式：恢复前一个锁定提交中的映射；用户会重新获得旧Esc发送exit行为，因此不建议将旧按键作为日常使用。当前源码改动需完整退出再打开。

当前教程、速查与问题台账由主实施统一整合，本票暂不冒称全量交付完成。

### 默认zsh最终真实TUI复验

将测试命令等待上限设为30秒，终端Esc后job存活，i恢复输入，命令实际写入绝对路径fixture成功（最终单次工具总耗时4.76秒）。早前相对响应文件写到HOME，是登录shell改变cwd造成的测试假失败；已改绝对路径并清理核实属于本次测试的响应文件。PowerShell5.1重定向UTF-16LE也由测试规范化读取，生产配置无改动。最终按真实命令输出验证，不再仅匹配终端回显文本；测试进程树由本次runner跟踪收尾。
