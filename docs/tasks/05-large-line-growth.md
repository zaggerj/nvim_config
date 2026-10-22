# 05：补齐长单行编辑增长保护

**What to build（交付行为）：** 普通文件编辑或粘贴成超长单行时自动关闭该buffer昂贵分析，保留基本编辑且不影响其他buffer。

**Blocked by（阻塞依赖）：** 无（可开始）。

**Status：** done（Windows增长保护及真实Coc逐buffer生命周期回归通过；macOS归21待验）

**归属：** A；[治理SPEC](../spec.md) R03 / ID04；验收 AC05、AC09。

## 验收标准

- [x] 总量小于1MiB、单行30000字节的JS场景可触发保护，覆盖TextChanged和TextChangedI。
- [x] 保持大于1MiB、20000行及20000字节单行三类阈值语义，验证阈值两侧。
- [x] 输入、粘贴、撤销、读取及普通/大文件切换时，Coc、Copilot、Treesitter与折叠保护一致。
- [x] 编辑检查针对变更范围，不对每次按键全量扫描；用可复现输入记录检查成本。
- [x] 缩小后的恢复方式明确，至少保存重开可恢复普通功能；其他普通buffer仍能高亮及导航。
- [x] 扩展已有editor/AI回归并更新大文件设计、教程和R03证据。

## 范围与交付记录

不调整阈值掩盖问题，不以全局关闭插件替代逐buffer保护。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)

## 2026-10-22 实施回执

测试边界沿用用户已确认的配置后Neovim子进程与临时项目；未测试私有函数，没有模拟本项目内部模块。

- 红：新增长行增长回归，原配置在TextChanged路径报 `edited long line was not protected`。
- 绿：buffer变更回调只记录脏行范围，TextChanged/TextChangedI消费变更范围；30000字节单行、真实paste越过20000字节均停止高亮并关闭该buffer的服务标记。
- 边界：精确20000字节单行、1MiB与20000行保持普通模式，超过对应阈值进入保护；撤销后不立刻重启昂贵服务，缩小、保存、关闭buffer并重开恢复高亮。
- 多窗口：同一进程中普通19000行JS buffer保留高亮与普通服务状态，500次分散单行修改和编辑检查耗时约413ms；该值包含其他插件工作，不作为保护模块自身耗时或跨机器性能保证。
- 18的事件边界也按红绿推进：原配置无名空buffer触发代码插件、notes.txt触发代码插件两场景分别失败；修复后空buffer、空filetype、text及特殊buffer跳过NormalFile，调度后切到其他buffer也不误触发；普通JS首次进入仍触发。

执行：`python tests/large_file_growth_smoke.py`、同命令加 `--events-only`、现有editor_smoke/ai_smoke/rest_smoke均在Windows PowerShell通过；HTTP四类请求通过。新回归复用有界Neovim进程测试执行器验证无本次子进程遗留，测试文件语法与定点diff检查通过。未执行macOS实机验证；其他Windows入口交由主任务平台矩阵复核。没有修改插件规格或其他任务文件，没有提交Git。

主任务需要同步当前设计、教程与R03状态，完成后勾选最后一项并最终验收；原评审中的失败证据保留为历史。

## 2026-10-22 SPEC审查追加：已附加Coc Document未解除

原实施已覆盖阈值、禁用变量及高亮，但`b:coc_enabled=0`只阻止新Document初始化，不能释放已经附加的Coc Document。真实Coc公共API观察扩展的新增红测报`Already attached Coc document remains tracked after large-file growth`，旧验收范围不足，保留上方历史回执。

修复：保护时先设置buffer禁用变量，再在Coc服务已初始化的情况下通知其原生`CocAutocmd`事件`['BufUnload', bufnr]`，只执行Coc逐buffer文档关闭链。不触发Neovim的BufUnload自动命令，不卸载正在编辑的buffer，不执行全局CocDisable或detach。

源码证据绑定Coc提交`889f5e287e746973c978b383eea0f286571d8fe0`：`plugin/coc.vim:440`为真实BufUnload通知；`build/index.js:126439`的onBufUnload清理该buffer的创建状态并调用onBufDetach(buf,false)，继而detachBuffer移除Document并发close；`build/index.js:125914`的Document.detach释放监听、清空lines和变更定时器。`autoload/coc/util.vim:487`的coc_enabled检查让后续BufEnter创建保持不附加、无行内容。升级Coc必须复验此原生事件契约。

`tests/coc_large_growth_smoke.py`使用临时公共API观察扩展及真实Coc/TypeScript服务，三Windows入口全部通过：

- 小文件先真实attached，编辑为30000字节单行后恰好一次close，attached=false且lines=0。
- 大文件后续三次编辑及切走切回不发送文档change、不重新附加。
- 另一个buffer保持attached，真实定义请求及新编辑的change通知继续成功。
- 大文件缩小、保存、bwipeout后重开恢复普通filetype与Coc附加，同时另一buffer保持附加。

PowerShell最终单次约3.82秒，Git Bash约6.45秒、zsh约3.86秒（工具整段耗时，非性能指标）。测试执行器跟踪并收尾自己创建的进程树；初版测试夹具的嵌套vim.wait/RPC导致超时，已改为主流程显式轮询，没有归为产品缺陷。macOS未执行。
