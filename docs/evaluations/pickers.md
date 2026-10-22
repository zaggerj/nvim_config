# 搜索器隔离比较

2026-10-22，Windows、Neovim0.12.6，运行代码c4493af。执行专用benchmark虚拟环境中的 `python tests/picker_evaluation.py --runs 3`，需要 `scripts/benchmark-requirements.txt`。使用真实RPC UI attach 120×40，同一fixture按Telescope/fzf/Snacks交替三轮，独占Neovim性能窗口，无并发测量。候选不进入日常runtimepath，不改lazy-lock。完整9进程样本、revision、中位数及min/max见 [picker-comparison.json](picker-comparison.json)。81个行为ready与9个首UI flush断言全部通过。

| 项目 | Telescope | fzf-lua | Snacks |
| --- | ---: | ---: | ---: |
| commit | a0bbec2 | 5dca84e | 882c996 |
| 首UI flush启动墙钟ms | 138（129–142） | 140（131–214） | 142（135–246） |
| files首次结果ms | 138（137–145） | 465（422–466） | 119（114–123） |
| grep首次结果ms | 60（57–61） | 483（480–496） | 69（60–86） |
| 已加载后输入file0999到单一结果ms | 31（31–32） | 46（46–47） | 14（11–16） |
| 双选送quickfix | 2条，通过 | 2条，通过 | 2条，通过 |
| buffers / oldfiles / help / commands / keymaps | 全部有结果 | 全部有结果 | 全部有结果 |

表中为三样本中位数（最小–最大）。数据集为1000个Python文件加入口文件、脚本和被gitignore排除的cache；统一使用ripgrep输入过滤，Telescope启用真实fzf-native。候选files/grep配置复用当前排除.git、node_modules、__pycache__、.pnpm-store的策略。启动墙钟从Python调用创建进程到首次UI flush，包含最小隔离配置与RPC通信，不含shell启动或物理终端绘制，也不是日常整套配置启动。first_result计时自调用picker到首个结果，包含该picker首次模块加载；输入过滤在独立files picker打开500ms后真实输入，直到过滤剩一条。不清理用户缓存，first-observed不称真正冷启动。不同来源的总数与异步快照计数并不等价，未把首次回调条数作为扫描集合相等的证明。

结论：本轮保留Telescope。三轮显示Snacks的文件首次结果和过滤响应较快，Telescope的grep首次结果及多个常用来源响应更快，最小隔离启动三者接近且候选波动较大；没有一个候选在这些指标上全面占优。当前全部工作流可用，完整预览、插件键位迁移及macOS端到端验收还未完成。fzf-lua增加fzf外部可执行文件及多个Neovim辅助进程；本机用官方fzf0.74.5的Windowsamd64构建，放在 `stdpath(data)/tools/evaluations/fzf`，未改全局PATH。Telescope依赖的plenary当前README已宣布不再维护，这是持续维护成本，后续若Telescope兼容性中断应优先复评Snacks/fzf-lua；本次不因这个事实跳过行为比较。

Snacks的数据库模块在Windows默认下载SQLite3.48.0到 `stdpath(cache)/sqlite3.dll`，支持 `picker.db.sqlite3_path` 显式指定。源码使用系统PowerShell下载，macOS/Linux通过系统sqlite3加载；正式迁移须在部署步骤固定校验与平台发现，避免首个picker临时联网。此次关闭frecency，没有以自动下载成功作为部署通过。预览暂关闭用于finder口径，三种预览实现和大文件预览保护仍需迁移前专门验收。

试验装配问题已排除并留下原因：headless探针让fzf的Lua辅助进程源出现0结果，改真实RPC UI后正常；fzf buffers头部0/0时已有可见条目，探针改为识别真实buffer行；Windows缓存目录为Temp/nvim，最初fixture叫nvim-picker-*触发Snacks recent默认缓存路径排除，改为picker-*后recent正常。早期失败不作为候选缺陷或慢于8秒的结论。

已完成三轮交替功能与性能测量。后续正式迁移仍需校验完整扫描结果集合、预览、原有键位、Git状态与中文路径及双平台部署。隔离目录可回收，无日常配置需要回滚。
